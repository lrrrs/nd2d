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

        public function setSpriteSheet(spriteSheet:SpriteSheet):void {
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

            _width = material.spriteSheet ? material.spriteSheet.spriteWidth : material.bitmapData.width;
            _height = material.spriteSheet ? material.spriteSheet.spriteHeight : material.bitmapData.height;

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

            material.render(context, faceList, 0, faceList.length);
        }
    }
}