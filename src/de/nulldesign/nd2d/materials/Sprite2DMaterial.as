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
/*
 package de.nulldesign.nd2d.materials {

 import de.nulldesign.nd2d.utils.TextureHelper;

 import flash.display.BitmapData;
 import flash.display3D.Context3D;
 import flash.display3D.Context3DProgramType;
 import flash.display3D.textures.Texture;
 import flash.geom.ColorTransform;
 import flash.geom.Point;
 import flash.geom.Rectangle;
 import flash.geom.Vector3D;

 public class Sprite2DMaterial extends AMaterial {

 [Embed (source="../shader/Sprite2DMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
 private static const MaterialVertexProgramClass:Class;

 [Embed (source="../shader/Sprite2DMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
 private static const MaterialFragmentProgramClass:Class;

 [Embed (source="../shader/Sprite2DVertexShader.pbasm", mimeType="application/octet-stream")]
 private static const VertexProgramClass:Class;

 private static var sprite2DProgramData:ProgramData;

 public var texture:Texture;
 public var textureWidth:Number;
 public var textureHeight:Number;

 public var colorTransform:ColorTransform;
 public var spriteSheet:ASpriteSheetBase;
 */
/**
 * Constructor of class Sprite2DMaterial
 * @param textureObject can be a BitmapData, SpriteSheet, TextureAtlas or Texture2D
 *//*
 public function Sprite2DMaterial(textureObject:Object) {

 if(textureObject is BitmapData) {
 var bmp:BitmapData = textureObject as BitmapData;
 spriteSheet = new SpriteSheet(bmp, bmp.width, bmp.height, 0);
 } else if(textureObject is SpriteSheet) {
 spriteSheet = textureObject as SpriteSheet;
 } else if(textureObject is TextureAtlas) {
 spriteSheet = textureObject as TextureAtlas;
 } else if(textureObject is Texture2D) {
 var t2D:Texture2D = textureObject as Texture2D;
 texture = t2D.texture;
 textureWidth = t2D.textureWidth;
 textureHeight = t2D.textureHeight;
 }

 drawCalls = 1;
 }

 override public function handleDeviceLoss():void {
 super.handleDeviceLoss();
 texture = null;
 sprite2DProgramData = null;
 }

 override protected function prepareForRender(context:Context3D):Boolean {

 super.prepareForRender(context);

 if(!texture && spriteSheet && spriteSheet.bitmapData) {
 texture = TextureHelper.generateTextureFromBitmap(context, spriteSheet.bitmapData, true);
 }

 if(!texture) {
 // can happen after a device loss
 return false;
 }

 programData.parameterBufferHelper.setTextureByName("textureImage", texture);

 programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.FRAGMENT, "colorMultiplier",
 Vector.<Number>([ colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier ]));

 var offsetFactor:Number = 1.0 / 255.0;

 programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.FRAGMENT, "colorOffset",
 Vector.<Number>([ colorTransform.redOffset * offsetFactor, colorTransform.greenOffset * offsetFactor, colorTransform.blueOffset * offsetFactor, colorTransform.alphaOffset * offsetFactor ]));


 var rect:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);

 if(spriteSheet) {

 rect = spriteSheet.getUVRectForFrame();

 var atlas:TextureAtlas = spriteSheet as TextureAtlas;

 if(atlas) {

 var offset:Point = atlas.getOffsetForFrame();

 clipSpaceMatrix.identity();
 clipSpaceMatrix.appendScale(spriteSheet.spriteWidth * 0.5, spriteSheet.spriteHeight * 0.5, 1.0);
 clipSpaceMatrix.appendTranslation(offset.x, offset.y, 0.0);
 clipSpaceMatrix.append(modelMatrix);
 clipSpaceMatrix.append(viewProjectionMatrix);

 } else {
 refreshClipspaceMatrix();
 }
 } else {
 refreshClipspaceMatrix();
 }

 programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "uvOffsetAndScale",
 Vector.<Number>([ rect.x, rect.y, rect.width, rect.height ]));


 programData.parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX, "objectToClipSpaceTransform", clipSpaceMatrix,
 true);

 programData.parameterBufferHelper.update();

 vertexBufferHelper.setVertexBuffers();

 return true;
 }

 override protected function clearAfterRender(context:Context3D):void {
 super.clearAfterRender(context);
 context.setTextureAt(0, null);
 }

 override protected function initProgram(context:Context3D):void {

 // program will be only created once and cached as static var in material
 if(!sprite2DProgramData) {
 sprite2DProgramData = new ProgramData(context, VertexProgramClass, MaterialVertexProgramClass, MaterialFragmentProgramClass);
 }

 programData = sprite2DProgramData;
 }

 override public function cleanUp():void {
 super.cleanUp();
 if(texture) {
 texture.dispose();
 texture = null;
 }
 }
 }
 }
 */

package de.nulldesign.nd2d.materials {

    import com.adobe.utils.AGALMiniAssembler;

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class Sprite2DMaterial extends AMaterial {

        private const VERTEX_SHADER:String = "m44 op, va0, vc0   \n" + // vertex * clipspace
                "mov vt0, va1  \n" + // save uv in temp register
                "mul vt0.xy, vt0.xy, vc4.zw   \n" + // mult with uv-scale
                "add vt0.xy, vt0.xy, vc4.xy   \n" + // add uv offset
                "mov v0, vt0 \n"; // copy uv

        private const FRAGMENT_SHADER:String = "mov ft0, v0\n" + // get interpolated uv coords
                "tex ft1, ft0, fs0 <2d,clamp,linear,nomip>\n" + // sample texture
                "mul ft1, ft1, fc0\n" + // mult with colorMultiplier
                "add ft1, ft1, fc1\n" + // mult with colorOffset
                "mov oc, ft1\n";

        private static var sprite2DProgramData:ProgramData;

        public var texture:Texture;
        public var textureWidth:Number;
        public var textureHeight:Number;

        public var colorTransform:ColorTransform;
        public var spriteSheet:ASpriteSheetBase;

        public function Sprite2DMaterial(textureObject:Object) {

            if(textureObject is BitmapData) {
                var bmp:BitmapData = textureObject as BitmapData;
                spriteSheet = new SpriteSheet(bmp, bmp.width, bmp.height, 0);
            } else if(textureObject is SpriteSheet) {
                spriteSheet = textureObject as SpriteSheet;
            } else if(textureObject is TextureAtlas) {
                spriteSheet = textureObject as TextureAtlas;
            } else if(textureObject is Texture2D) {
                var t2D:Texture2D = textureObject as Texture2D;
                texture = t2D.texture;
                textureWidth = t2D.textureWidth;
                textureHeight = t2D.textureHeight;
            }

            drawCalls = 1;
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            texture = null;
            sprite2DProgramData = null;
        }

        override protected function prepareForRender(context:Context3D):Boolean {

            super.prepareForRender(context);

            if(!texture && spriteSheet && spriteSheet.bitmapData) {
                texture = TextureHelper.generateTextureFromBitmap(context, spriteSheet.bitmapData, true);
            }

            if(!texture) {
                // can happen after a device loss
                return false;
            }

            var rect:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);

            if(spriteSheet) {

                rect = spriteSheet.getUVRectForFrame();

                var atlas:TextureAtlas = spriteSheet as TextureAtlas;

                if(atlas) {

                    var offset:Point = atlas.getOffsetForFrame();

                    clipSpaceMatrix.identity();
                    clipSpaceMatrix.appendScale(spriteSheet.spriteWidth * 0.5, spriteSheet.spriteHeight * 0.5, 1.0);
                    clipSpaceMatrix.appendTranslation(offset.x, offset.y, 0.0);
                    clipSpaceMatrix.append(modelMatrix);
                    clipSpaceMatrix.append(viewProjectionMatrix);

                } else {
                    refreshClipspaceMatrix();
                }
            } else {
                refreshClipspaceMatrix();
            }

            context.setProgram(programData.program);
            context.setBlendFactors(blendMode.src, blendMode.dst);
            context.setTextureAt(0, texture);
            context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
            context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([ rect.x,
                                                                                                      rect.y,
                                                                                                      rect.width,
                                                                                                      rect.height]));

            var offsetFactor:Number = 1.0 / 255.0;
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,
                                                  Vector.<Number>([ colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier ]));
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,
                                                  Vector.<Number>([ colorTransform.redOffset * offsetFactor, colorTransform.greenOffset * offsetFactor, colorTransform.blueOffset * offsetFactor, colorTransform.alphaOffset * offsetFactor ]));

            return true;
        }

        override protected function clearAfterRender(context:Context3D):void {
            context.setTextureAt(0, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }

        override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

            fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
            fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
        }

        override protected function initProgram(context:Context3D):void {

            // program will be only created once and cached as static var in material
            if(!sprite2DProgramData) {
                var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

                var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);

                var program:Program3D = context.createProgram();
                program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);

                sprite2DProgramData = new ProgramData(program, 4);
            }

            programData = sprite2DProgramData;
        }

        override public function cleanUp():void {
            super.cleanUp();
            if(texture) {
                texture.dispose();
                texture = null;
            }
        }

        public function modifyVertexInBuffer(bufferIdx:uint, x:Number, y:Number):void {

            if(!mVertexBuffer || mVertexBuffer.length == 0) return;
            var idx:uint = bufferIdx * programData.numFloatsPerVertex;

            mVertexBuffer[idx] = x;
            mVertexBuffer[idx + 1] = y;

            needUploadVertexBuffer = true;
        }
    }
}

