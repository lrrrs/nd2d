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
        /*
        protected const DEFAULT_VERTEX_SHADER:String = "m44 op, va0, vc[va3.x]   \n" + // vertex * clipspace
                "mov v0, va1		\n" + // copy uv
                "mov v1, va2		\n"; // copy color

        protected const DEFAULT_FRAGMENT_SHADER:String = "mov ft0, v0\n" + // get interpolated uv coords
                "tex ft1, ft0, fs0 <2d,clamp,linear>\n" + // sample texture
                "mul ft1, ft1, v1\n" + // mult with color
                "mov oc, ft1\n";
        */
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

        override protected function prepareForRender(context:Context3D):Boolean {

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
                if(child.invalidateColors) child.updateColors();
                if(child.invalidateMatrix) child.updateMatrix();

                clipSpaceMatrix.identity();
                clipSpaceMatrix.append(modelMatrix);
                clipSpaceMatrix.append(child.localModelMatrix);
                clipSpaceMatrix.append(viewProjectionMatrix);

                var numConstantsPerSprite:uint = 6; // matrix + offset + color
                var numConstantsUsedForMatrix:uint = 4;

                context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, i * numConstantsPerSprite, clipSpaceMatrix, true);

                context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i * numConstantsPerSprite + numConstantsUsedForMatrix,
                                                      Vector.<Number>([ child.r, child.g, child.b, child.a ]));

                context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i * numConstantsPerSprite + numConstantsUsedForMatrix + 1,
                                                      Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));
            }

            vertexBufferHelper.setVertexBuffers();

            return true;
        }

        override protected function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {
            // TODO
        }
    }
}
