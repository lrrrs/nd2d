/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.utils {
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class TextureHelper {
        public function TextureHelper() {
        }

        /**
         * Will return a point that contains the width and height of the smallest possible texture size in 2^n
         * @param bmp
         * @return x = width, y = height of the texture
         */
        public static function getTextureDimensionsFromBitmap(bmp:BitmapData):Point {
            var textureWidth:Number = 2.0;
            var textureHeight:Number = 2.0;

            var bmpWidth:Number = bmp.width;
            var bmpHeight:Number = bmp.height;

            while (textureWidth < bmpWidth) {
                textureWidth <<= 1;
            }

            while (textureHeight < bmpHeight) {
                textureHeight <<= 1;
            }

            return new Point(textureWidth, textureHeight);
        }

        /**
         * Generates a texture from a bitmap. Will use the smallest possible size (2^n)
         * @param context
         * @param bmp
         * @return The generated texture
         */
        public static function generateTextureFromBitmap(context:Context3D, bmp:BitmapData):Texture {

            var textureDimensions:Point = getTextureDimensionsFromBitmap(bmp);

            var newBmp:BitmapData = new BitmapData(textureDimensions.x, textureDimensions.y, true, 0x00000000);

            var sourceRect:Rectangle;
            var destPoint:Point;

            sourceRect = new Rectangle(0, 0, bmp.width, bmp.height);
            destPoint = new Point(textureDimensions.x / 2 - bmp.width / 2, textureDimensions.y / 2 - bmp.height / 2);

            newBmp.copyPixels(bmp, sourceRect, destPoint);

            var texture:Texture = context.createTexture(textureDimensions.x, textureDimensions.y, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(newBmp);

            return texture;
        }
    }
}
