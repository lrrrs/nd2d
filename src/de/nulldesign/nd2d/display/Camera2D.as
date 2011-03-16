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

package de.nulldesign.nd2d.display {
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    public class Camera2D {

        public var renderMatrix:Matrix3D = new Matrix3D();
        public var projectionMatrix:Matrix3D = new Matrix3D();
        public var viewMatrix:Matrix3D = new Matrix3D();

        public var sceneWidth:Number;
        public var sceneHeight:Number;
        protected var invalidated:Boolean = true;
        public var position:Vector3D;
        public var lookAt:Vector3D;
        public var roll:Number = 0.0;

        public function Camera2D(w:Number, h:Number) {
            sceneWidth = w;
            sceneHeight = h;

            projectionMatrix = makeOrtographicMatrix(0, w, 0, h);
            //projectionMatrix = makeProjectionMatrix(0.1, 1000.0, 90, sceneWidth / sceneHeight);
            //lookAt = new Vector3D(0.0, 0.0, 0.0);
            //position = new Vector3D(0, 0, -h / 2.0);
        }

        public function makeProjectionMatrix(zNear:Number, zFar:Number, fovDegrees:Number, aspect:Number):Matrix3D {
            var yval:Number = zNear * Math.tan(fovDegrees * (Math.PI / 360.0));
            var xval:Number = yval * aspect;

            return makeFrustumMatrix(-xval, xval, -yval, yval, zNear, zFar);
        }

        public function update():void {

            var up:Vector3D = new Vector3D();
            up.x = Math.sin(roll);
            up.y = -Math.cos(roll);
            up.z = 0;

            var forward:Vector3D = new Vector3D();
            forward.x = lookAt.x - position.x;
            forward.y = lookAt.y - position.y;
            forward.z = lookAt.z - position.z;
            forward.normalize();

            var right:Vector3D = up.crossProduct(forward);
            right.normalize();

            up = right.crossProduct(forward);
            up.normalize();

            var rawData:Vector.<Number> = new Vector.<Number>();
            rawData.push(-right.x, -right.y, -right.z, 0, up.x, up.y, up.z, 0, -forward.x, -forward.y, -forward.z, 0, 0, 0, 0, 1);

            viewMatrix = new Matrix3D(rawData);
            viewMatrix.transpose();
            viewMatrix.prependTranslation(-position.x, -position.y, -position.z);
            viewMatrix.invert();
        }

        protected function makeFrustumMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number):Matrix3D {
            return new Matrix3D(Vector.<Number>([
                (2 * zNear) / (right - left),
                0,
                (right + left) / (right - left),
                0,

                0,
                (2 * zNear) / (top - bottom),
                (top + bottom) / (top - bottom),
                0,

                0,
                0,
                zFar / (zNear - zFar),
                -1,

                0,
                0,
                (zNear * zFar) / (zNear - zFar),
                0
            ]));
        }

        public function makeOrtographicMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number = -1, zFar:Number = 1):Matrix3D {

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
                //update();

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
    }
}
