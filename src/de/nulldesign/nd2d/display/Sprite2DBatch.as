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
    import de.nulldesign.nd2d.materials.Sprite2DBatchMaterial;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display3D.Context3D;

    /**
     * Sprite2DBatch
     * Similar to a Sprite2DCloud. In general it's a bit slower than the cloud, but it supports mouseevents for
     * childs and adding or removing childs doesn't slow down the rendering, it's free.
     * So in particular cases it could be faster.
     */
    public class Sprite2DBatch extends Node2D {

        private var material:Sprite2DBatchMaterial;
        private var faceList:Vector.<Face>;

        public function Sprite2DBatch(textureObject:Object) {
            material = new Sprite2DBatchMaterial(textureObject);
            faceList = TextureHelper.generateQuadFromSpriteSheet(material.spriteSheet);
        }

        override public function get drawCalls():uint {
            return material.drawCalls;
        }

        override public function addChildAt(child:Node2D, idx:uint):Node2D {

            if(child is Sprite2DBatch) {
                throw new Error("You can't nest Sprite2DClouds");
            }

            var c:Sprite2D = child as Sprite2D;

            // distribute spritesheets to sprites
            if(c && material.spriteSheet) {
                c.spriteSheet = material.spriteSheet.clone();
            }

            return super.addChildAt(child, idx);
        }

        override internal function stepNode(elapsed:Number):void {

            step(elapsed);

            for each(var child:Node2D in children) {
                child.timeSinceStartInSeconds = timeSinceStartInSeconds;
                child.stepNode(elapsed);
            }

            // don't refresh own spritesheet
        }

        override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean):void {

            var myMatrixChanged:Boolean = false;

            if(!visible) {
                return;
            }

            if(invalidateColors) {
                updateColors();
            }

            if(invalidateMatrix) {
                updateMatrix();
                myMatrixChanged = true;
            }

            if(parentMatrixChanged || myMatrixChanged) {
                worldModelMatrix.identity();
                worldModelMatrix.append(localModelMatrix);

                if(parent) {
                    worldModelMatrix.append(parent.worldModelMatrix);
                }
            }

            draw(context, camera);

            // don't call draw on childs....
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            material.handleDeviceLoss();
        }

        override protected function draw(context:Context3D, camera:Camera2D):void {

            material.blendMode = blendMode;
            material.modelMatrix = worldModelMatrix;
            material.projectionMatrix = camera.projectionMatrix;
            material.viewProjectionMatrix = camera.getViewProjectionMatrix();
            material.renderBatch(context, faceList, children);
        }
    }
}
