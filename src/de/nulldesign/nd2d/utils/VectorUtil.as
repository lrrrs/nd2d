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

	import de.nulldesign.nd2d.display.Node2D;

	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class VectorUtil {
		
		public static const RAD_2_DEG:Number = 180 / Math.PI;
		public static const DEG_2_RAD:Number = Math.PI / 180;

        /**
         * Converts radians to degrees
         * @param rad radians
         * @return degrees
         */
        public static function rad2deg(rad:Number):Number {
            return rad * RAD_2_DEG;
        }

        /**
         * Converts degrees to radians
         * @param deg degrees
         * @return radians
         */
        public static function deg2rad(deg:Number):Number {
            return deg * DEG_2_RAD;
        }

        /**
         * Calculates the angle from a vector
         * @param x
         * @param y
         * @return angle in degrees
         */
        public static function rotationFromVector(x:Number, y:Number):Number {
            return Math.atan2(y, x) * RAD_2_DEG;
        }
		
		/**
		 * Calculates the distance between two Node2D
		 * @param n1 first Node2D
		 * @param n2 second Node2D
		 * @return distance between two Node2D
		 */
        public static function distance(n1:Node2D, n2:Node2D):Number {
			const p1:Vector3D = n1.position;
			const p2:Vector3D = n2.position;
			const dx:Number = p1.x - p2.x;
			const dy:Number = p1.y - p2.y;
			return Math.sqrt(dx * dx + dy * dy);
        }
    }
}
