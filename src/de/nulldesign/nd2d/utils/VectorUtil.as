/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.utils {

    public class VectorUtil {

        /**
         * Converts radian to degrees
         * @param rad
         * @return
         */
        public static function rad2deg(rad:Number):Number {
            return rad * (180 / Math.PI);
        }

        /**
         * Converts degree to radian
         * @param deg
         * @return
         */
        public static function deg2rad(deg:Number):Number {
            return deg * (Math.PI / 180);
        }

        /**
         * calculates the angle from a vector
         * @param x
         * @param y
         * @return
         */
        public static function rotationFromVector(x:Number, y:Number):Number {
            return Math.atan2(y, x) / Math.PI * 180;
        }
    }
}
