/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: https://github.com/nulldesign/nd2d
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

package de.nulldesign.nd2d.utils {
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix;
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

            while(textureWidth < bmpWidth) {
                textureWidth <<= 1;
            }

            while(textureHeight < bmpHeight) {
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
        public static function generateTextureFromBitmap(context:Context3D,
                                                         bmp:BitmapData,
                                                         useMipMaps:Boolean):Texture {

            var textureDimensions:Point = getTextureDimensionsFromBitmap(bmp);

            var newBmp:BitmapData = new BitmapData(textureDimensions.x, textureDimensions.y, true, 0x00000000);

            var sourceRect:Rectangle;
            var destPoint:Point;

            sourceRect = new Rectangle(0, 0, bmp.width, bmp.height);
            destPoint = new Point(textureDimensions.x / 2 - bmp.width / 2, textureDimensions.y / 2 - bmp.height / 2);

            newBmp.copyPixels(bmp, sourceRect, destPoint);

            var texture:Texture = context.createTexture(textureDimensions.x, textureDimensions.y,
                                                        Context3DTextureFormat.BGRA, false);

            if(useMipMaps) {
                uploadTextureWithMipmaps(texture, newBmp);
            } else {
                texture.uploadFromBitmapData(newBmp);
            }

            return texture;
        }

        public static function uploadTextureWithMipmaps(dest:Texture, src:BitmapData):void {
            var ws:int = src.width;
            var hs:int = src.height;
            var level:int = 0;
            var tmp:BitmapData = new BitmapData(src.width, src.height);
            var transform:Matrix = new Matrix();

            while(ws > 1 && hs > 1) {
                tmp.draw(src, transform, null, null, null, true);
                dest.uploadFromBitmapData(tmp, level);
                transform.scale(0.5, 0.5);
                level++;
                ws >>= 1;
                hs >>= 1;
            }
            tmp.dispose();
        }
    }
}
