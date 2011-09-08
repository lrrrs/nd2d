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

package de.nulldesign.nd2d.display {

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.materials.ASpriteSheetBase;
    import de.nulldesign.nd2d.materials.Sprite2DMaskMaterial;
    import de.nulldesign.nd2d.materials.Sprite2DMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;

    /**
     * <p>2D sprite class</p>
     * One draw call is used per sprite.
     * If you have a lot of sprites with the same texture / spritesheet try to use a Sprite2DCould, it will be a lot faster.
     */
    public class Sprite2D extends Node2D {

        public var spriteSheet:ASpriteSheetBase;

        protected var material:Sprite2DMaterial;
        protected var faceList:Vector.<Face>;

        protected var mask:Sprite2D;

        /**
         * Constructor of class Sprite2D
         * @param textureObject can be a BitmapData, SpriteSheet or TextureAtlas
         */
        public function Sprite2D(textureObject:Object = null) {
            if(textureObject) {
                setMaterial(new Sprite2DMaterial(textureObject));
            }
        }

        public function setSpriteSheet(spriteSheet:SpriteSheet):void {
            setMaterial(new Sprite2DMaterial(spriteSheet));
        }

        public function setTexture(texture:Texture, width:Number, height:Number):void {
            _width = width;
            _height = height;

            if(!material) {
                material = new Sprite2DMaterial(null);
            }

            material.texture = texture;
            faceList = TextureHelper.generateQuadFromDimensions(width, height);
        }

        public function setMaterial(newMaterial:Sprite2DMaterial):void {

            if(material) {
                material.cleanUp();
            }

            if(newMaterial.spriteSheet) {
                _width = newMaterial.spriteSheet.spriteWidth;
                _height = newMaterial.spriteSheet.spriteHeight;
                faceList = TextureHelper.generateQuadFromSpriteSheet(newMaterial.spriteSheet);
            } else {
                _width = newMaterial.textureWidth;
                _height = newMaterial.textureHeight;
                faceList = TextureHelper.generateQuadFromDimensions(_width, _height);
            }

            this.spriteSheet = newMaterial.spriteSheet;
            this.material = newMaterial;
        }

        public function setMask(mask:Sprite2D):void {

            this.mask = mask;

            if(mask) {
                setMaterial(new Sprite2DMaskMaterial(spriteSheet));
            } else {
                setMaterial(new Sprite2DMaterial(spriteSheet));
            }
        }

        override public function get numTris():uint {
            return 2 + super.numTris;
        }

        override public function get drawCalls():uint {
            return material ? (material.drawCalls + super.drawCalls) : 0;
        }

        /**
         * @private
         */
        override internal function stepNode(elapsed:Number):void {

            super.stepNode(elapsed);

            if(spriteSheet) {
                spriteSheet.update(timeSinceStartInSeconds);
                _width = spriteSheet.spriteWidth;
                _height = spriteSheet.spriteHeight;
            }
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            if(material)
                material.handleDeviceLoss();
        }

        override protected function draw(context:Context3D, camera:Camera2D):void {

            material.blendMode = blendMode;
            material.modelMatrix = worldModelMatrix;
            material.projectionMatrix = camera.projectionMatrix;
            material.viewProjectionMatrix = camera.getViewProjectionMatrix();

            material.color.x = r;
            material.color.y = g;
            material.color.z = b;
            material.color.w = a;

            if(mask) {

                if(mask.invalidateMatrix) {
                    mask.updateMatrix();
                }

                var maskMat:Sprite2DMaskMaterial = Sprite2DMaskMaterial(material);
                maskMat.maskBitmap = mask.spriteSheet.bitmapData;
                maskMat.maskModelMatrix = mask.localModelMatrix;
                maskMat.maskAlpha = mask.alpha;
            }

            material.render(context, faceList, 0, faceList.length);
        }

        override public function cleanUp():void {
            if(material) {
                material.cleanUp();
            }

            super.cleanUp();
        }
    }
}