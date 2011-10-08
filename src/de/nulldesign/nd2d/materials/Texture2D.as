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

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    public class Texture2D {

        public var texture:Texture;
        public var bitmap:BitmapData;

        /*
         * These sizes are needed to calculate the UV offset in a texture,
         * because the GPU texturesize can differ from the provided bitmap (not a 2^n size)
         */
        public var originalTextureWidth:Number;
        public var originalTextureHeight:Number;

        public var textureWidth:Number;
        public var textureHeight:Number;

        protected var autoCleanUpResource:Boolean;

        public function Texture2D(bitmap:BitmapData /* ADD ATF FORMAT LATER */, autoCleanUpResource:Boolean = false) {

            this.autoCleanUpResource = autoCleanUpResource;

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
