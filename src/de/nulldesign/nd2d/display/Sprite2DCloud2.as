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
    import de.nulldesign.nd2d.materials.Sprite2DCloudMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;

    public class Sprite2DCloud2 extends Node2D {

        protected var maxCapacity:uint;
        protected var spriteSheet:SpriteSheet;
        protected var bitmapTexture:BitmapData;
        protected var material:Sprite2DCloudMaterial;
        protected var faceList:Vector.<Face>;

        override public function get numTris():uint {
            return children.length * 2;
        }

        override public function get drawCalls():uint {
            return material.drawCalls;
        }

        public function Sprite2DCloud2(maxCapacity:uint, bitmapTexture:BitmapData = null,
                                       spriteSheet:SpriteSheet = null) {

            throw new Error("NOT FULLY IMPLEMENTED YET");

            this.maxCapacity = maxCapacity;
            this.bitmapTexture = bitmapTexture;
            this.spriteSheet = spriteSheet;

            if(spriteSheet) {
                this.bitmapTexture = spriteSheet.bitmapData;
            }

            init();
        }

        protected function init():void {
            this.material = new Sprite2DCloudMaterial(maxCapacity, children, bitmapTexture, spriteSheet);
            this.faceList = new Vector.<Face>(maxCapacity * 2, true);

            var idx:int = 0;
            var quadIdx:int = 0;

            for(var i:uint = 0; i < maxCapacity; ++i) {
                var quad:Vector.<Face> = TextureHelper.generateQuadFromTexture(bitmapTexture, spriteSheet);

                quad[0].idx = quadIdx;
                quad[1].idx = quadIdx;

                faceList[idx++] = quad[0];
                faceList[idx++] = quad[1];

                ++quadIdx;
            }
        }

        override protected function draw(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            super.draw(context, camera, handleDeviceLoss);

            material.blendMode = blendMode;
            material.modelMatrix = worldModelMatrix;
            material.viewProjectionMatrix = camera.getViewProjectionMatrix();
            material.render(context, faceList, numChildren * 2);
        }

        override internal function drawNode(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            if(!visible) {
                return;
            }

            if(invalidateMatrix) {
                updateMatrix();
            }

            worldModelMatrix.identity();
            worldModelMatrix.append(localModelMatrix);

            if(parent) {
                worldModelMatrix.append(parent.worldModelMatrix);
            }

            draw(context, camera, handleDeviceLoss);

            // don't draw childs here....
        }

        override public function addChildAt(child:Node2D, idx:uint):Node2D {

            if(!(child is Sprite2D)) {
                throw new Error("Sprite2DCloud accepts Sprite2D childs only");
            }

            if(children.length < maxCapacity) {

                super.addChildAt(child, idx);

                var c:Sprite2D = child as Sprite2D;
                c.mouseEnabled = false;

                // distribute spritesheets to sprites
                if(c && spriteSheet && !c.spriteSheet) {
                    c.spriteSheet = spriteSheet.clone();
                }
            }

            return child;
        }
    }
}
