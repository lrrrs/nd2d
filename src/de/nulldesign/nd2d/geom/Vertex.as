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

package de.nulldesign.nd2d.geom {

	import flash.geom.Vector3D;

	public class Vertex extends Vector3D {

        private static var UID_COUNT:uint = 0;
        public const uid:Number = ++UID_COUNT;

		/**
		 * the color must be in ARGB format.
		 */
		public var color:uint = 0xFFFFFFFF;

		public var bufferIdx:int = -1;

        public function Vertex(x:Number = 0.0, y:Number = 0.0, z:Number = 0.0) {
            super(x, y, z, 1.0);
        }

        public function get a():Number {
            return ((color >> 24) & 0xFF) / 0xFF;
        }

		public function get r():Number {
            return ((color >> 16) & 0xFF) / 0xFF;
        }

        public function get g():Number {
            return ((color >> 8) & 0xFF) / 0xFF;
        }

        public function get b():Number {
            return (color & 0xFF) / 0xFF;
        }

        override public function clone():Vector3D {
            var v:Vertex = new Vertex(x, y, z);
			v.color = color;
            return v;
        }
    }
}
