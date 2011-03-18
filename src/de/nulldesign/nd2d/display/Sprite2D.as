/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
 *
 *
 *  Licence Agreement
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 * /
 */

package de.nulldesign.nd2d.display {
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.materials.Sprite2DMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.geom.Point;

    /**
     * <p>2D sprite class</p>
     * One draw call is used per sprite.
     * If you have a lot of sprites with the same texture / spritesheet try to use a Sprite2DCould, it will be a lot faster.
     */
    public class Sprite2D extends Node2D {

        public var spriteSheet:SpriteSheet;

        protected var textureDimensions:Point;

        protected var material:Sprite2DMaterial;
        protected var faceList:Vector.<Face>;

        protected var v1:Vertex;
        protected var v2:Vertex;
        protected var v3:Vertex;
        protected var v4:Vertex;

        protected var uv1:UV;
        protected var uv2:UV;
        protected var uv3:UV;
        protected var uv4:UV;

        /**
         * Constructor of class Sprite2D
         * @param bitmapTexture the sprite image
         * @param spriteSheet optional spritesheet. If a spritesheet is provided the bitmapTexture is ignored
         */
        public function Sprite2D(bitmapTexture:BitmapData = null, spriteSheet:SpriteSheet = null) {
            this.spriteSheet = spriteSheet;

            if(spriteSheet) {
                bitmapTexture = spriteSheet.bitmapData;
            }

            if(bitmapTexture) {
                initWithBitmapData(bitmapTexture);
            }
        }

        protected function initWithBitmapData(bitmapTexture:BitmapData):void {

            _width = spriteSheet ? spriteSheet.width : bitmapTexture.width;
            _height = spriteSheet ? spriteSheet.height : bitmapTexture.height;

            material = new Sprite2DMaterial(bitmapTexture, spriteSheet);
            faceList = new Vector.<Face>();

            var texW:Number;
            var texH:Number;

            textureDimensions = TextureHelper.getTextureDimensionsFromBitmap(bitmapTexture);

            if(!spriteSheet) {
                texW = textureDimensions.x / 2.0;
                texH = textureDimensions.y / 2.0;

                uv1 = new UV(0, 0);
                uv2 = new UV(1, 0);
                uv3 = new UV(1, 1);
                uv4 = new UV(0, 1);

            } else {
                texW = spriteSheet.width / 2.0;
                texH = spriteSheet.height / 2.0;

                uv1 = new UV(spriteSheet.uvOffset.x, spriteSheet.uvOffset.y);
                uv2 = new UV(spriteSheet.uvOffset.x + spriteSheet.uvSize.x, spriteSheet.uvOffset.y);
                uv3 = new UV(spriteSheet.uvOffset.x + spriteSheet.uvSize.x,
                             spriteSheet.uvOffset.y + spriteSheet.uvSize.y);
                uv4 = new UV(spriteSheet.uvOffset.x, spriteSheet.uvOffset.y + spriteSheet.uvSize.y);
            }

            v1 = new Vertex(-texW, -texH, 0.0);
            v2 = new Vertex(texW, -texH, 0.0);
            v3 = new Vertex(texW, texH, 0.0);
            v4 = new Vertex(-texW, texH, 0.0);

            faceList[0] = new Face(v1, v2, v3, uv1, uv2, uv3);
            faceList[1] = new Face(v1, v3, v4, uv1, uv3, uv4);
        }

        override public function get numTris():uint {
            return 2;
        }

        override protected function step(t:Number):void {
            if(spriteSheet)
                spriteSheet.update(t);
        }

        override protected function draw(context:Context3D, camera:Camera2D):void {

            super.draw(context, camera);

            material.blendMode = blendMode;
            material.modelViewMatrix = modelViewMatrix;
            material.projectionMatrix = camera.getProjectionMatrix();

            // TODO optimize there is always a parent!
            if(refreshColors || parent) {

                updateColors();

                material.color.x = r;
                material.color.y = g;
                material.color.z = b;
                material.color.w = a;
            }

            material.render(context, faceList, 2);
        }

        /*
         override public function draw(context:Context3D, camera:Camera):void {

         super.draw(context, camera);

         if (!vertexBuffer || refreshColors) {

         refreshColors = false;

         var texW:Number = bitmapTexture.width / 2;
         var texH:Number = bitmapTexture.height / 2;

         // extract rgb
         var r:Number = (tint >> 16) / 255;
         var g:Number = (tint >> 8 & 255) / 255;
         var b:Number = (tint & 255) / 255;

         vertexBuffer = context.createVertexBuffer(4, 8); // 4 verts. x,y, u,v, r,g,b,a
         vertexBuffer.uploadFromVector(Vector.<Number>([
         -texW, -texH, 0, 0, r, g, b, alpha,
         texW, -texH, 1, 0, r, g, b, alpha,
         texW,  texH, 1, 1, r, g, b, alpha,
         -texW,  texH, 0, 1, r, g, b, alpha]), 0, 4);

         indexBuffer = context.createIndexBuffer(6);
         indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
         }

         if (!texture) {
         texture = context.createTexture(bitmapTexture.width, bitmapTexture.height, Context3DTextureFormat.BGRA, false);
         texture.uploadFromBitmapData(bitmapTexture, 0);
         }

         if (!program) {
         var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
         vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER);

         var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
         colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, DEFAULT_FRAGMENT_SHADER);

         program = context.createProgram();
         program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
         }

         context.setTextureAt(0, texture);
         context.setProgram(program);
         context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
         context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
         context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // color
         context.setDepthTest(false, Context3DCompareMode.NEVER);
         context.setCulling(Context3DTriangleFace.NONE);

         if (additive) {
         context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
         } else {
         context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         }

         context.drawTriangles(indexBuffer, 0, 2);

         context.setTextureAt(0, null);
         context.setVertexBufferAt(0, null); // vertex
         context.setVertexBufferAt(1, null); // uv
         context.setVertexBufferAt(2, null); // color
         }
         */
    }
}