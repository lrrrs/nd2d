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

	public class Face {

        public var idx:uint = 0;

        public var v1:Vertex;
        public var v2:Vertex;
        public var v3:Vertex;

        public var uv1:UV;
        public var uv2:UV;
        public var uv3:UV;

        public function Face(v1:Vertex, v2:Vertex, v3:Vertex, uv1:UV = null, uv2:UV = null, uv3:UV = null) {

            this.v1 = v1;
            this.v2 = v2;
            this.v3 = v3;

            this.uv1 = uv1;
            this.uv2 = uv2;
            this.uv3 = uv3;
        }

        public function getNormal():Vector3D {
            return getNormalFromVertices(v1, v2, v3);
        }

        public static function getNormalFromVertices(vert1:Vertex, vert2:Vertex, vert3:Vertex):Vector3D {
            var ab:Vertex;
            var ac:Vertex;
            var n:Vector3D;

            ab = new Vertex(vert2.x - vert1.x, vert2.y - vert1.y, vert2.z - vert1.z);
            ac = new Vertex(vert2.x - vert3.x, vert2.y - vert3.y, vert2.z - vert3.z);

            n = ac.crossProduct(ab);
            n.normalize();
            return n;
        }

        public function clone():Face {
            return new Face(v1.clone() as Vertex, v2.clone() as Vertex, v3.clone() as Vertex, uv1 ? uv1.clone() : null,
                            uv2 ? uv2.clone() : null, uv3 ? uv3.clone() : null);
        }

        public function toString():String {
            return "Face: " + v1 + "/" + v2 + "/" + v3 + " / " + uv1 + " / " + uv2 + " / " + uv3;
        }
    }
}
