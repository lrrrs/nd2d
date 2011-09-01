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

    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;

    public class Sprite2DMaterial extends AMaterial {
        /*
         [Embed (source="../shader/Sprite2DMaskMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
         private static const MaskMaterialVertexProgramClass:Class;

         [Embed (source="../shader/Sprite2DMaskMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
         private static const MaskMaterialFragmentProgramClass:Class;
         */
        [Embed (source="../shader/Sprite2DMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/Sprite2DMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialFragmentProgramClass:Class;

        [Embed (source="../shader/Sprite2DVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const VertexProgramClass:Class;

        private static var sprite2DProgramData:ProgramData;
        //private static var sprite2DMaskProgramData:ProgramData;

        public var texture:Texture;

        public var color:Vector3D = new Vector3D(1.0, 1.0, 1.0, 1.0);
        public var spriteSheet:ASpriteSheetBase;

        /*
         private var maskChanged:Boolean = false;

         private var _maskBitmap:BitmapData;

         public function get maskBitmap():BitmapData {
         return _maskBitmap;
         }

         //public var maskModelMatrix:Matrix3D;

         private var maskClipSpaceMatrix:Matrix3D = new Matrix3D();

         public function set maskBitmap(value:BitmapData):void {

         if(maskBitmap != value) {

         if(maskTexture) {
         maskTexture.dispose();
         maskTexture = null;
         }

         _maskBitmap = value;
         maskChanged = true;
         }
         }

         public var maskTexture:Texture;
         */
        public function Sprite2DMaterial(textureObject:Object) {

            if(textureObject is BitmapData) {
                var bmp:BitmapData = textureObject as BitmapData;
                spriteSheet = new SpriteSheet(bmp, bmp.width, bmp.height, 0);
            } else if(textureObject is SpriteSheet) {
                spriteSheet = textureObject as SpriteSheet;
            } else if(textureObject is TextureAtlas) {
                spriteSheet = textureObject as TextureAtlas;
            }

            drawCalls = 1;
        }


        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            texture = null;
            //maskTexture = null;
            sprite2DProgramData = null;
        }

        override protected function prepareForRender(context:Context3D):Boolean {
            /*
             if(maskChanged) {
             maskChanged = false;
             initProgram(context);
             }
             */
            super.prepareForRender(context);

            if(!texture && spriteSheet.bitmapData) {
                texture = TextureHelper.generateTextureFromBitmap(context, spriteSheet.bitmapData, true);
            }

            if(!texture) {
                // can happen after a device loss
                return false;
            }

            programData.parameterBufferHelper.setTextureByName("textureImage", texture);
            //context.setTextureAt(0, texture);

            programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.FRAGMENT, "color",
                                                                       Vector.<Number>([ color.x, color.y, color.z, color.w ]));

            var rect:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);

            if(spriteSheet) {

                rect = spriteSheet.getUVRectForFrame();

                var atlas:TextureAtlas = spriteSheet as TextureAtlas;

                if(atlas) {

                    var offset:Point = atlas.getOffsetForFrame();

                    clipSpaceMatrix.identity();
                    clipSpaceMatrix.appendScale(spriteSheet.spriteWidth * 0.5, spriteSheet.spriteHeight * 0.5, 1.0);
                    clipSpaceMatrix.append(modelMatrix);
                    clipSpaceMatrix.appendTranslation(offset.x, offset.y, 0.0);
                    clipSpaceMatrix.append(viewProjectionMatrix);

                } else {
                    refreshClipspaceMatrix();
                }
            } else {
                refreshClipspaceMatrix();
            }

            programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "uvOffsetAndScale",
                                                                       Vector.<Number>([ rect.x, rect.y, rect.width, rect.height ]));


            programData.parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX,
                                                                       "objectToClipSpaceTransform", clipSpaceMatrix,
                                                                       true);
            /*
             if(maskBitmap) {

             maskClipSpaceMatrix.identity();
             //maskClipSpaceMatrix.append(maskModelMatrix);
             //maskClipSpaceMatrix.append(viewProjectionMatrix);

             // test with inverted matrix... grr
             maskClipSpaceMatrix = clipSpaceMatrix.clone();
             maskClipSpaceMatrix.invert();

             if(!maskTexture && maskBitmap) {
             maskTexture = TextureHelper.generateTextureFromBitmap(context, maskBitmap, true);
             }

             if(maskTexture) {
             programData.parameterBufferHelper.setTextureByName("textureMaskImage", maskTexture);
             //context.setTextureAt(1, maskTexture);
             }

             programData.parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX,
             "maskObjectToClipSpaceTransform",
             maskClipSpaceMatrix, true);


             trace("mVertexBuffer: " + mVertexBuffer);

             trace("halfMaskSize: " + maskBitmap.width * 0.5+", "+ maskBitmap.height * 0.5);
             trace("invertedMaskSize: " + 1.0 / maskBitmap.width + ", " + 1.0 / maskBitmap.height);

             var v:Vector3D = new Vector3D(128, -128, 0, 1);

             v = clipSpaceMatrix.transformVector(v);
             trace("moved: " + v);

             v = maskClipSpaceMatrix.transformVector(v);
             trace("moved back: " + v);

             v = new Vector3D((v.x + (maskBitmap.width * 0.5)) * (1.0 / maskBitmap.width),
             (v.y + (maskBitmap.height * 0.5)) * (1.0 / maskBitmap.height),
             0.0, 1.0);

             trace("uv: " + v);

             programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "halfMaskSize",
             Vector.<Number>([maskBitmap.width * 0.5,
             maskBitmap.height * 0.5, 0.0, 0.0]));

             programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "invertedMaskSize",
             Vector.<Number>([1.0 / maskBitmap.width,
             1.0 / maskBitmap.height, 0.0, 0.0]));
             }
             */
            programData.parameterBufferHelper.update();

            vertexBufferHelper.setVertexBuffers();

            return true;
        }

        override protected function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
            /*
             if(maskTexture) {
             context.setTextureAt(1, null);
             } */
        }

        override protected function initProgram(context:Context3D):void {
            /*
             if(maskBitmap) {
             if(!sprite2DMaskProgramData) {
             sprite2DMaskProgramData = new ProgramData(context, VertexProgramClass,
             MaskMaterialVertexProgramClass,
             MaskMaterialFragmentProgramClass);
             }

             programData = sprite2DMaskProgramData;
             } else {
             */
            // program will be only created once and cached as static var in material
            if(!sprite2DProgramData) {
                sprite2DProgramData = new ProgramData(context, VertexProgramClass, MaterialVertexProgramClass,
                                                      MaterialFragmentProgramClass);
            }

            programData = sprite2DProgramData;
            //}
        }

        override public function cleanUp():void {
            super.cleanUp();
            if(texture) {
                texture.dispose();
                texture = null;
            }
            /*
             if(maskTexture) {
             maskTexture.dispose();
             maskTexture = null;
             } */
        }
    }
}
