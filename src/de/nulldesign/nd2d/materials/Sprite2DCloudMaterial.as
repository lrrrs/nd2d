/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 06.04.11 14:28
 */
package de.nulldesign.nd2d.materials {
    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    public class Sprite2DCloudMaterial extends AMaterial {

        [Embed (source="../shader/Sprite2DCloudMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/Sprite2DCloudMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialFragmentProgramClass:Class;

        [Embed (source="../shader/Sprite2DCloudVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const VertexProgramClass:Class;

        protected var texture:Texture;
        protected var bitmapData:BitmapData;

        protected var spriteSheet:SpriteSheet;
        protected var maxCapacity:uint;
        protected var childList:Vector.<Node2D>;

        public function Sprite2DCloudMaterial(maxCapacity:uint, childList:Vector.<Node2D>, bitmapData:BitmapData,
                                              spriteSheet:SpriteSheet = null) {
            this.maxCapacity = maxCapacity;
            this.bitmapData = bitmapData;
            this.spriteSheet = spriteSheet;
            this.childList = childList;
            this.drawCalls = 1;
        }

        override protected function prepareForRender(context:Context3D):void {

            super.prepareForRender(context);

            if(!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, bitmapData, true);
            }

            // TODO SET TEXTURE BY NAME!!!
            context.setTextureAt(0, texture);

            var child:Sprite2D;
            var spriteSheet:SpriteSheet;
            var offset:Point;

            for(var i:uint = 0; i < childList.length; i++) {

                child = Sprite2D(childList[i]);
                spriteSheet = child.spriteSheet;
                offset = spriteSheet.getOffsetForFrame();

                // TODO update properties internally
                if(child.refreshColors) child.updateColors();
                if(child.refreshPosition) child.refreshMatrix();

                clipSpaceMatrix.identity();
                clipSpaceMatrix.append(modelViewMatrix);
                clipSpaceMatrix.append(child.localModelMatrix);
                clipSpaceMatrix.append(projectionMatrix);

                /*
                 objectToClipSpaceTransform
                 color
                 uvOffset
                 */

                var numConstantsPerSprite:uint = 6; // matrix + offset + color
                var numConstantsUsedForMatrix:uint = 4;

                context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, i * numConstantsPerSprite, clipSpaceMatrix, true);

                context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i * numConstantsPerSprite + numConstantsUsedForMatrix,
                                                      Vector.<Number>([ child.r, child.g, child.b, child.a ]));

                context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i * numConstantsPerSprite + numConstantsUsedForMatrix + 1,
                                                      Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));

                /*
                 if(i == 0) {
                 parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX,
                 "objectToClipSpaceTransform0", clipSpaceMatrix,
                 true);
                 } else {

                 parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX,
                 "objectToClipSpaceTransform1", clipSpaceMatrix,
                 true);
                 }


                 parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "uvOffset",
                 Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));

                 parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "color",
                 Vector.<Number>([ child.r, child.g, child.b, child.a ]));
                 */
            }

            parameterBufferHelper.update();

            vertexBufferHelper.setVertexBuffers();

            // not finished....
        }

        override protected function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {
            if(!program) {
                vertexProgram = readFile(VertexProgramClass);
                materialVertexProgram = readFile(MaterialVertexProgramClass);
                materialFragmentProgram = readFile(MaterialFragmentProgramClass);
            }

            super.initProgram(context);
        }
    }
}
