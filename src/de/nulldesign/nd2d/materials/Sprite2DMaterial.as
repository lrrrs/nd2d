/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.materials {
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;

    public class Sprite2DMaterial extends AMaterial {

        [Embed (source="../shader/Sprite2DVertexShader.pbasm", mimeType="application/octet-stream")]
        protected static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/Sprite2DFragmentShader.pbasm", mimeType="application/octet-stream")]
        protected static const MaterialFragmentProgramClass:Class;

        [Embed (source="../shader/DefaultVertexShader.pbasm", mimeType="application/octet-stream")]
        protected static const VertexProgramClass:Class;

        public var texture:Texture;
        public var bitmapData:BitmapData;

        public var color:Vector3D = new Vector3D(1.0, 1.0, 1.0, 1.0);

        protected var spriteSheet:SpriteSheet;

        public function Sprite2DMaterial(bitmapData:BitmapData, spriteSheet:SpriteSheet = null) {
            this.bitmapData = bitmapData;
            this.spriteSheet = spriteSheet;
        }

        override public function prepareForRender(context:Context3D):void {

            super.prepareForRender(context);

            if (!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, bitmapData);
            }

            // TODO SET TEXTURE BY NAME!!!
            context.setTextureAt(0, texture);

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.FRAGMENT,
                    "color",
                    Vector.<Number>([ color.x, color.y, color.z, color.w ]));

            var offset:Point = new Point();

            if (spriteSheet) {
                var rowIdx:uint = spriteSheet.frame % spriteSheet.numSheetsPerRow;
                var colIdx:uint = Math.floor(spriteSheet.frame / spriteSheet.numSheetsPerRow);

                offset.x = spriteSheet.uvSize.x * rowIdx;
                offset.y = spriteSheet.uvSize.y * colIdx;
            }

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX,
                    "uvOffset",
                    Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));

            parameterBufferHelper.update();

            vertexBufferHelper.setVertexBuffers();
        }

        override public function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {
            if (!program) {
                vertexProgram = readFile(VertexProgramClass);
                materialVertexProgram = readFile(MaterialVertexProgramClass);
                materialFragmentProgram = readFile(MaterialFragmentProgramClass);
            }

            super.initProgram(context);
        }
    }
}
