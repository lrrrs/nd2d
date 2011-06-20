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
    import de.nulldesign.nd2d.materials.Sprite2DMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;

    /**
     * <p>2D sprite class</p>
     * One draw call is used per sprite.
     * If you have a lot of sprites with the same texture / spritesheet try to use a Sprite2DCould, it will be a lot faster.
     */
    public class Sprite2D extends Node2D {

        public var spriteSheet:SpriteSheet;

        protected var material:Sprite2DMaterial;
        protected var faceList:Vector.<Face>;

        /**
         * Constructor of class Sprite2D
         * @param bitmapTexture the sprite image
         * @param spriteSheet optional spritesheet. If a spritesheet is provided the bitmapTexture is ignored
         */
        public function Sprite2D(bitmapTexture:BitmapData = null, spriteSheet:SpriteSheet = null) {

            if(spriteSheet) {
                bitmapTexture = spriteSheet.bitmapData;
            }

            if(bitmapTexture) {
                setMaterial(new Sprite2DMaterial(bitmapTexture, spriteSheet));
            }
        }

        public function setSpriteSheet(spriteSheet:SpriteSheet):void
        {
            setMaterial(new Sprite2DMaterial(spriteSheet.bitmapData, spriteSheet));
        }

        public function setTexture(texture:Texture, width:Number, height:Number):void {
            _width = width;
            _height = height;

            if(texture) {
                material = new Sprite2DMaterial(null, null);
                material.texture = texture;
                faceList = TextureHelper.generateQuadFromDimensions(width, height);
            }
        }

        override public function get numTris():uint {
            return 2 + super.numTris;
        }

        override public function get drawCalls():uint {
            return material.drawCalls + super.drawCalls;
        }

        /**
         * @private
         */
        override internal function stepNode(elapsed:Number):void {

            super.stepNode(elapsed);

            if(spriteSheet)
                spriteSheet.update(timeSinceStartInSeconds);
        }

        protected function setMaterial(material:Sprite2DMaterial):void {

            _width = material.spriteSheet ? material.spriteSheet.width : material.bitmapData.width;
            _height = material.spriteSheet ? material.spriteSheet.height : material.bitmapData.height;

            this.material = material;
            this.spriteSheet = material.spriteSheet;
            faceList = TextureHelper.generateQuadFromTexture(material.bitmapData, material.spriteSheet);
        }

        override protected function draw(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            material.blendMode = blendMode;
            material.modelMatrix = worldModelMatrix;
            material.projectionMatrix = camera.projectionMatrix;
            material.viewProjectionMatrix = camera.getViewProjectionMatrix();

            // TODO optimize there is always a parent!
            if(invalidateColors || parent) {

                updateColors();

                material.color.x = r;
                material.color.y = g;
                material.color.z = b;
                material.color.w = a;
            }

            if(handleDeviceLoss) {
                material.handleDeviceLoss();
            }

            material.render(context, faceList, faceList.length);
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