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
package de.nulldesign.nd2d.materials {

    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.Bitmap;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.utils.ByteArray;

    public class Texture2D {

        public var texture:Texture;
        public var bitmap:BitmapData;
        public var compressedBitmap:ByteArray;

        /*
         * These sizes are needed to calculate the UV offset in a texture.
         * because the GPU texturesize can differ from the provided bitmap (not a 2^n size)
         * This is the BitmapData's or the ATF textures original size
         */
        public var bitmapWidth:Number;
        public var bitmapHeight:Number;

        public var textureWidth:Number;
        public var textureHeight:Number;

        protected var autoCleanUpResources:Boolean;

        /**
         * Texture2D object
         * @param autoCleanUpResources if you set it to true, the bitmap or the ATF texture will be disposed after creating the texture. This will save memory, but ND2D is not able to recover from a device loss then (Which is unlikely on a mobile device, but not on a desktop machine)
         */
        public function Texture2D(autoCleanUpResources:Boolean = false) {
            this.autoCleanUpResources = autoCleanUpResources;
        }

        public static function textureFromBitmapData(bitmap:BitmapData, autoCleanUpResources:Boolean = false):Texture2D {

            var t:Texture2D = new Texture2D(autoCleanUpResources);

            if(bitmap) {
                t.bitmap = bitmap;
                t.bitmapWidth = bitmap.width;
                t.bitmapHeight = bitmap.height;

                var dimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmap);
                t.textureWidth = dimensions.x;
                t.textureHeight = dimensions.y;
            }

            return t;
        }

        public static function textureFromATF(atf:ByteArray, bitmapWidth:Number, bitmapHeight:Number, autoCleanUpResources:Boolean = false):Texture2D {

			throw new Error("Not yet fully implemented... No rush, the ATF isn't public yet ;)");

			var t:Texture2D = new Texture2D(autoCleanUpResources);

            if(atf) {
                t.compressedBitmap = atf;
                t.bitmapWidth = bitmapWidth;
                t.bitmapHeight = bitmapHeight;

                var dimensions:Point = TextureHelper.getTextureDimensionsFromSize(bitmapWidth, bitmapHeight);
                t.textureWidth = dimensions.x;
                t.textureHeight = dimensions.y;
            }

            return t;
        }

        public function getTexture(context:Context3D, useMipMapping:Boolean):Texture {
            if(!texture) {
                // TODO generate from ATF
                texture = TextureHelper.generateTextureFromBitmap(context, bitmap, useMipMapping);

                if(autoCleanUpResources) {
                    bitmap.dispose();
                    bitmap = null;
                }
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
