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

package de.nulldesign.nd2d.geom {
    import flash.geom.Vector3D;

    public class Vertex extends Vector3D {

        private static var UI_COUNT:Number = 0;
        public var uid:Number = ++UI_COUNT;

        public var color:Number = 0xFFFFFF;
        public var faceRefs:Vector.<Face> = new Vector.<Face>();
        public var normal:Vector3D;

        public var targetVertex:Vertex;

        public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0, color:Number = NaN) {
            super(x, y, z, 1.0);
        }

        public function get r():Number {
            return (color >> 16) / 0xFF;
        }

        public function get g():Number {
            return (color >> 8 & 0xFF) / 0xFF;
        }

        public function get b():Number {
            return (color & 0xFF) / 0xFF;
        }

        public var a:Number = 1.0;

        override public function clone():Vector3D {
            return new Vertex(x, y, z, color);
        }
    }
}
