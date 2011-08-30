/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 03.07.11 14:42
 */
package de.nulldesign.nd2d.display {

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.materials.Sprite2DBatchMaterial;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display3D.Context3D;

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

        override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean,
                                            handleDeviceLoss:Boolean):void {

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

            draw(context, camera, handleDeviceLoss);

            // don't call draw on childs....
        }

        override protected function draw(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            material.blendMode = blendMode;
            material.modelMatrix = worldModelMatrix;
            material.projectionMatrix = camera.projectionMatrix;
            material.viewProjectionMatrix = camera.getViewProjectionMatrix();

            if(handleDeviceLoss) {
                material.handleDeviceLoss();
            }

            material.renderBatch(context, faceList, children);
        }
    }
}
