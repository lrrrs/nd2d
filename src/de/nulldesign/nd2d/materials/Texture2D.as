/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 08.09.11 12:00
 */
package de.nulldesign.nd2d.materials {

    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    public class Texture2D {

        public var texture:Texture;
        public var bitmap:BitmapData;

        public var originalTextureWidth:Number;
        public var originalTextureHeight:Number;
        public var textureWidth:Number;
        public var textureHeight:Number;

        public function Texture2D(bitmap:BitmapData /* ADD ATF FORMAT LATER */) {
            if(bitmap) {
                this.bitmap = bitmap;
                this.originalTextureWidth = bitmap.width;
                this.originalTextureHeight = bitmap.height;

                var dimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmap);
                textureWidth = dimensions.x;
                textureHeight = dimensions.y;
            }
        }

        public function getTexture(context:Context3D, useMipMapping:Boolean):Texture {
            if(!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, bitmap, useMipMapping);
            }

            return texture;
        }

        public function cleanUp():void {
            if(texture) {
                texture.dispose();
                texture = null;
            }
        }
    }
}
