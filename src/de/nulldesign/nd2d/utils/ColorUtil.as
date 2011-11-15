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

package de.nulldesign.nd2d.utils {

    public class ColorUtil {
        public static function hex2rgb(h:uint):Object {
            return {r:h >> 16, g:h >> 8 & 255, b:h & 255};
        }

        public static function rgb2hex(r:uint, g:uint, b:uint):Number {
            return (r << 16 | g << 8 | b);
        }

        public static function mixColors(color1:Number, color2:Number, ratio:Number):Number {
            // clip to 0-1
            ratio = Math.max(0, ratio);
            ratio = Math.min(1, ratio);

            var col1:Object = hex2rgb(color1);
            var col2:Object = hex2rgb(color2);

            return rgb2hex(col1.r * (1 - ratio) + col2.r * ratio, col1.g * (1 - ratio) + col2.g * ratio,
                           col1.b * (1 - ratio) + col2.b * ratio);
        }

        public static function r(color:Number):Number {
            return (color >> 16) / 0xFF;
        }

        public static function g(color:Number):Number {
            return (color >> 8 & 0xFF) / 0xFF;
        }

        public static function b(color:Number):Number {
            return (color & 0xFF) / 0xFF;
        }

		public static function colorWithAlphaFromColor(color:uint, alpha:Number):uint {
			return color | ((alpha * 0xFF) << 24);
		}
    }
}