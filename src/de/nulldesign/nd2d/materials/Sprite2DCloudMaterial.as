/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 06.04.11 14:28
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
    import flash.geom.Rectangle;

    public class Sprite2DCloudMaterial extends Sprite2DMaterial {

        protected const DEFAULT_VERTEX_SHADER:String = "m44 op, va0, vc[va2.x]   \n" + // vertex * clipspace[idx]
                "add vt0, va1, vc[va2.z]\n" + "mov v0, vt0		\n" + // copy uv
                "mov v1, vc[va2.y]	\n"; // copy color from array

        protected const DEFAULT_FRAGMENT_SHADER:String = "mov ft0, v0\n" + // get interpolated uv coords
                "tex ft1, ft0, fs0 <2d,clamp,linear,nomip>\n" + // sample texture
                "mul ft1, ft1, v1\n" + // mult with color
                "mov oc, ft1\n";

        protected var constantsPerSprite:uint = 6; // matrix, color, uvoffset
        protected var constantsPerMatrix:uint = 4;

        protected static var cloudProgramData:ProgramData;

        protected const BATCH_SIZE:uint = 126 / constantsPerSprite;

        public function Sprite2DCloudMaterial(textureObject:Object) {
            super(textureObject);
        }

        override protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

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

        public function renderBatch(context:Context3D, faceList:Vector.<Face>, childList:Vector.<Node2D>):void {

            drawCalls = Math.ceil(childList.length / BATCH_SIZE);

            generateBufferData(context, faceList);

            if(prepareForRender(context)) {

                var batchLen:uint = 0;

                for(var i:uint = 0; i < childList.length; i++) {

                    var child:Sprite2D;

                    child = Sprite2D(childList[i]);

                    if(child.visible) {

                        if(child.invalidateColors) child.updateColors();
                        if(child.invalidateMatrix) child.updateMatrix();

                        clipSpaceMatrix.identity();
                        clipSpaceMatrix.append(modelMatrix);
                        clipSpaceMatrix.append(child.localModelMatrix);
                        clipSpaceMatrix.append(viewProjectionMatrix);

                        var uvRect:Rectangle = spriteSheet.getUVRectForFrame();

                        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite, clipSpaceMatrix, true);

                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite + constantsPerMatrix,
                                                              Vector.<Number>([ child.r,  child.g, child.b, child.a]));

                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              batchLen * constantsPerSprite + constantsPerMatrix + 1,
                                                              Vector.<Number>([ uvRect.x, uvRect.y]));
                        ++batchLen;

                        if(batchLen == BATCH_SIZE) {
                            context.drawTriangles(indexBuffer, 0, batchLen * 2);
                            batchLen = 0;
                        }
                    }
                }

                if(batchLen > 0)
                    context.drawTriangles(indexBuffer, 0, batchLen * 2);

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
                // third uv offset
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
