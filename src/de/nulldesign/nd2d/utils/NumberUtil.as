/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.utils {
    public class NumberUtil {

        /**
         * generates a random number between 0 and 1
         * @return
         */
        public static function rnd0_1():Number {
            return Math.random();
        }

        /**
         * generates a random number between -1 and 1
         * @return
         */
        public static function rndMinus1_1():Number {
            return Math.random() - Math.random();
        }

        /**
         * generates a random number between min and max
         * @param min
         * @param max
         * @return the random number
         */
        public static function rndMinMax(min:Number, max:Number):Number {
            return min + Math.random() * (max - min);
        }
    }
}
