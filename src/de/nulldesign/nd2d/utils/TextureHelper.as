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

package de.nulldesign.nd2d.utils {
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.materials.SpriteSheet;

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
        public static function generateTextureFromBitmap(context:Context3D, bmp:BitmapData,
                                                         useMipMaps:Boolean):Texture {

            var textureDimensions:Point = getTextureDimensionsFromBitmap(bmp);

            var newBmp:BitmapData = new BitmapData(textureDimensions.x, textureDimensions.y, true, 0x00000000);

            var sourceRect:Rectangle;
            var destPoint:Point;

            sourceRect = new Rectangle(0, 0, bmp.width, bmp.height);
            destPoint = new Point(textureDimensions.x * 0.5 - bmp.width * 0.5,
                                  textureDimensions.y * 0.5 - bmp.height / 2);

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
            var tmp:BitmapData = new BitmapData(src.width, src.height, true, 0x00000000);
            var transform:Matrix = new Matrix();

            while(ws >= 1 && hs >= 1) {
                tmp.draw(src, transform, null, null, null, true);
                dest.uploadFromBitmapData(tmp, level);
                transform.scale(0.5, 0.5);
                level++;
                ws >>= 1;
                hs >>= 1;
            }
            tmp.dispose();
        }

        public static function generateQuadFromTexture(bitmapTexture:BitmapData,
                                                       spriteSheet:SpriteSheet):Vector.<Face> {

            var faceList:Vector.<Face> = new Vector.<Face>(2, true);

            var texW:Number;
            var texH:Number;
            var uv1:UV;
            var uv2:UV;
            var uv3:UV;
            var uv4:UV;
            var v1:Vertex;
            var v2:Vertex;
            var v3:Vertex;
            var v4:Vertex;

            if(!spriteSheet) {

                var textureDimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmapTexture);

                texW = textureDimensions.x * 0.5;
                texH = textureDimensions.y * 0.5;

                uv1 = new UV(0, 0);
                uv2 = new UV(1, 0);
                uv3 = new UV(1, 1);
                uv4 = new UV(0, 1);

            } else {
                texW = spriteSheet.width * 0.5;
                texH = spriteSheet.height * 0.5;

                uv1 = new UV(spriteSheet.uvOffset.x, spriteSheet.uvOffset.y);
                uv2 = new UV(spriteSheet.uvOffset.x + spriteSheet.uvSize.x, spriteSheet.uvOffset.y);
                uv3 = new UV(spriteSheet.uvOffset.x + spriteSheet.uvSize.x,
                             spriteSheet.uvOffset.y + spriteSheet.uvSize.y);
                uv4 = new UV(spriteSheet.uvOffset.x, spriteSheet.uvOffset.y + spriteSheet.uvSize.y);
            }

            v1 = new Vertex(-texW, -texH, 0.0);
            v2 = new Vertex(texW, -texH, 0.0);
            v3 = new Vertex(texW, texH, 0.0);
            v4 = new Vertex(-texW, texH, 0.0);

            faceList[0] = new Face(v1, v2, v3, uv1, uv2, uv3);
            faceList[1] = new Face(v1, v3, v4, uv1, uv3, uv4);

            return faceList;
        }
    }
}
