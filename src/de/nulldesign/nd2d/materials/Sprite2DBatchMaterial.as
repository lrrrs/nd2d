/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.materials {

    import com.adobe.utils.AGALMiniAssembler;

    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Sprite2DBatchMaterial extends Sprite2DMaterial {

        protected const DEFAULT_VERTEX_SHADER:String = "m44 op, va0, vc[va2.x]             \n" + // vertex * clipspace[idx]
                "mov vt0, va1                       \n" + // save uv in temp register
                "mul vt0.xy, vt0.xy, vc[va2.z].zw   \n" + // mult with uv-scale
                "add vt0.xy, vt0.xy, vc[va2.z].xy   \n" + // add uv offset
                "mov v0, vt0                        \n" + // copy uv
                "mov v1, vc[va2.y]	                \n"; // copy color[idx]

        /*
         protected const DEFAULT_VERTEX_SHADER:String =
         "m44 op, va0, vc[va2.x]     \n" + // vertex * clipspace[idx]
         "add vt0, va1, vc[va2.z]    \n" + // add uvoffset[idx] to uv coords
         "mov v0, vt0                \n" + // copy uv
         "mov v1, vc[va2.y]	        \n"; // copy color[idx]
         */

        protected const DEFAULT_FRAGMENT_SHADER:String = "mov ft0, v0                                \n" + // get interpolated uv coords
                "tex ft1, ft0, fs0 <2d,clamp,linear,nomip>  \n" + // sample texture
                "mul ft1, ft1, v1                           \n" + // mult with color
                "mov oc, ft1                                \n";

        protected var constantsPerSprite:uint = 6; // matrix, color, uvoffset
        protected var constantsPerMatrix:uint = 4;

        protected static var cloudProgramData:ProgramData;

        protected const BATCH_SIZE:uint = 126 / constantsPerSprite;

        public function Sprite2DBatchMaterial(textureObject:Object) {
            super(textureObject);
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            cloudProgramData = null;
        }

        override protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

            if(vertexBuffer) {
                return;
            }

            // use first two faces and extend facelist to max. batch size
            var f0:Face = faceList[0];
            var f1:Face = faceList[1];
            var newF0:Face;
            var newF1:Face;

            var newFaceList:Vector.<Face> = new Vector.<Face>(BATCH_SIZE * 2, true);

            for(var i:int = 0; i < BATCH_SIZE; i++) {
                newF0 = f0.clone();
                newF1 = f1.clone();

                newF0.idx = i;
                newF1.idx = i;

                newFaceList[i * 2] = newF0;
                newFaceList[i * 2 + 1] = newF1;
            }

            super.generateBufferData(context, newFaceList);
        }

        override public function render(context:Context3D, faceList:Vector.<Face>, startTri:uint, numTris:uint):void {
            throw new Error("please call renderBatch for this material");
        }

        override protected function prepareForRender(context:Context3D):Boolean {

            if(!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, spriteSheet.bitmapData, false);
            }

            context.setProgram(programData.program);
            context.setBlendFactors(blendMode.src, blendMode.dst);
            context.setTextureAt(0, texture);
            context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
            context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
            context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_3); // idx

            return true;
        }

        public function renderSingle(context:Context3D, faceList:Vector.<Face>, child:Node2D):void {
            renderBatch(context, faceList, Vector.<Node2D>([child]));
        }

        public function renderBatch(context:Context3D, faceList:Vector.<Face>, childList:Vector.<Node2D>):void {

            drawCalls = 0;
            generateBufferData(context, faceList);

            if(prepareForRender(context)) {

                var batchLen:uint = 0;
                var child:Sprite2D;
                var color:Vector.<Number> = new Vector.<Number>(4, true);
                var uvoffset:Vector.<Number> = new Vector.<Number>(4, true);
                var i:int = -1;
                var n:int = childList.length;
                var uvOffsetAndScale:Rectangle;
                var atlasOffset:Point;
                var atlas:TextureAtlas;

                while(++i < n) {

                    child = Sprite2D(childList[i]);

                    if(child.visible) {

                        if(child.invalidateColors) child.updateColors();
                        if(child.invalidateMatrix) child.updateMatrix();

                        atlas = child.spriteSheet as TextureAtlas;

                        if(atlas) {

                            atlasOffset = atlas.getOffsetForFrame();

                            clipSpaceMatrix.identity();
                            clipSpaceMatrix.appendScale(atlas.spriteWidth * 0.5, atlas.spriteHeight * 0.5, 1.0);
                            clipSpaceMatrix.appendTranslation(atlasOffset.x, atlasOffset.y, 0.0);
                            clipSpaceMatrix.append(child.localModelMatrix);
                            clipSpaceMatrix.append(modelMatrix);
                            clipSpaceMatrix.append(viewProjectionMatrix);

                        } else {

                            clipSpaceMatrix.identity();
                            clipSpaceMatrix.append(child.localModelMatrix);
                            clipSpaceMatrix.append(modelMatrix);
                            clipSpaceMatrix.append(viewProjectionMatrix);
                        }

                        color[0] = child.r;
                        color[1] = child.g;
                        color[2] = child.b;
                        color[3] = child.a;

                        uvOffsetAndScale = child.spriteSheet.getUVRectForFrame();

                        uvoffset[0] = uvOffsetAndScale.x;
                        uvoffset[1] = uvOffsetAndScale.y;
                        uvoffset[2] = uvOffsetAndScale.width;
                        uvoffset[3] = uvOffsetAndScale.height;

                        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite, clipSpaceMatrix, true);

                        // TODO set in fragment instead?
                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite + constantsPerMatrix,
                                                              color);

                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite + constantsPerMatrix + 1,
                                                              uvoffset);

                        ++batchLen;

                        if(batchLen == BATCH_SIZE || i == n - 1) {
                            context.drawTriangles(indexBuffer, 0, batchLen * 2);
                            batchLen = 0;
                            ++drawCalls;
                        }
                    }
                }

                clearAfterRender(context);
            }
        }

        override protected function clearAfterRender(context:Context3D):void {
            context.setTextureAt(0, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
        }

        override protected function initProgram(context:Context3D):void {

            if(!cloudProgramData) {
                var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER);

                var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, DEFAULT_FRAGMENT_SHADER);

                cloudProgramData = new ProgramData(null, null, null, null);
                cloudProgramData.numFloatsPerVertex = 7;
                cloudProgramData.program = context.createProgram();
                cloudProgramData.program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
            }

            programData = cloudProgramData;
        }

        override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV,
                                              face:Face):void {

            fillBuffer(buffer, v, uv, face, "PB3D_POSITION", 2);
            fillBuffer(buffer, v, uv, face, "PB3D_UV", 2);
            fillBuffer(buffer, v, uv, face, "PB3D_IDX", 3);
        }

        override protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String,
                                               floatFormat:int):void {

            if(semanticsID == "PB3D_IDX") {
                // first float will be used for matrix index
                buffer.push(face.idx * constantsPerSprite);
                // second, color idx
                buffer.push(face.idx * constantsPerSprite + constantsPerMatrix);
                // third uv offset idx
                buffer.push(face.idx * constantsPerSprite + constantsPerMatrix + 1);

            } else {
                super.fillBuffer(buffer, v, uv, face, semanticsID, floatFormat);
            }
        }

        override public function cleanUp():void {
            super.cleanUp();
        }
    }
}
