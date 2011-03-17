/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
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

package de.nulldesign.nd2d.display {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    public class Camera2D {

        protected var renderMatrix:Matrix3D = new Matrix3D();
        protected var projectionMatrix:Matrix3D = new Matrix3D();
        protected var viewMatrix:Matrix3D = new Matrix3D();

        protected var _sceneWidth:Number;
        protected var _sceneHeight:Number;
        protected var position:Vector3D;

        protected var invalidated:Boolean = true;

        public function Camera2D(w:Number, h:Number) {
            _sceneWidth = w;
            _sceneHeight = h;
            projectionMatrix = makeOrtographicMatrix(0, w, 0, h);
        }

        public function makeOrtographicMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number = -1,
                                              zFar:Number = 1):Matrix3D {

            return new Matrix3D(Vector.<Number>([
                                                    2 / (right - left), 0, 0,  0,
                                                    0,  2 / (top - bottom), 0, 0,
                                                    0,  0, 1 / (zFar - zNear), 0,
                                                    0, 0, 0, 1
                                                ]));
        }

        public function getProjectionMatrix():Matrix3D {

            if(invalidated) {
                invalidated = false;

                viewMatrix.identity();
                viewMatrix.appendTranslation(-sceneWidth / 2 + x, -sceneHeight / 2 + y, 0.0);
                viewMatrix.appendScale(zoom, zoom, 1.0);
                viewMatrix.appendRotation(_rotation, Vector3D.Z_AXIS);

                renderMatrix.identity();
                renderMatrix.append(viewMatrix);
                renderMatrix.append(projectionMatrix);
            }

            return renderMatrix;
        }

        private var _x:Number = 0.0;

        public function get x():Number {
            return _x;
        }

        public function set x(value:Number):void {
            invalidated = true;
            _x = value;
        }

        private var _y:Number = 0.0;

        public function get y():Number {
            return _y;
        }

        public function set y(value:Number):void {
            invalidated = true;
            _y = value;
        }

        private var _zoom:Number = 1.0;

        public function get zoom():Number {
            return _zoom;
        }

        public function set zoom(value:Number):void {
            invalidated = true;
            _zoom = value;
        }

        private var _rotation:Number = 0.0;

        public function get rotation():Number {
            return _rotation;
        }

        public function set rotation(value:Number):void {
            _rotation = value;
        }

        public function get sceneWidth():Number {
            return _sceneWidth;
        }

        public function get sceneHeight():Number {
            return _sceneHeight;
        }
    }
}
