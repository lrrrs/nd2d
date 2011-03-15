/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
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

            return rgb2hex(col1.r * (1 - ratio) + col2.r * ratio, col1.g * (1 - ratio) + col2.g * ratio, col1.b * (1 - ratio) + col2.b * ratio);
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
    }
}