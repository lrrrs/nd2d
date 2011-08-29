/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 03.07.11 14:42
 */
package de.nulldesign.nd2d.display {

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.materials.Sprite2DCloudMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;

    public class Sprite2DBatch extends Node2D {

        private var material:Sprite2DCloudMaterial;
        private var faceList:Vector.<Face>;

        public function Sprite2DBatch(textureObject:Object) {
            material = new Sprite2DCloudMaterial(textureObject);
            faceList = TextureHelper.generateQuadFromSpriteSheet(material.spriteSheet);
        }

        override public function get drawCalls():uint {
            return 1; // todo
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

            /*
            material.color.x = r;
            material.color.y = g;
            material.color.z = b;
            material.color.w = a;
            */

            if(handleDeviceLoss) {
                material.handleDeviceLoss();
            }

            material.renderBatch(context, faceList, children);
        }
    }
}
