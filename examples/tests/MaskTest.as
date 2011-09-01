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

package tests {

    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;

    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;

    import flash.geom.Vector3D;

    public class MaskTest extends Scene2D {

        [Embed(source="/assets/crate.jpg")]
        private var spriteImage:Class;

        [Embed(source="/assets/circle_mask.png")]
        private var maskImage:Class;

        private var sprite:Sprite2D;
        private var mask:Sprite2D;

        public function MaskTest() {

            sprite = new Sprite2D(new spriteImage().bitmapData);
            addChild(sprite);

            mask = new Sprite2D(new maskImage().bitmapData);
            sprite.setMask(mask);

            // AS3 test for upper left vertex
            var v:Vector3D = new Vector3D(-128, -128, 0, 1);
            var clipSpaceMatrix:Matrix3D = new Matrix3D();
            var maskClipSpaceMatrix:Matrix3D = new Matrix3D();
            var maskBitmap:Rectangle = new Rectangle(0, 0, 256, 256);

            //maskClipSpaceMatrix.appendTranslation(-100, 0, 0);
            maskClipSpaceMatrix.invert();

            v = clipSpaceMatrix.transformVector(v);
            trace("moved to clipspace: " + v);

            // inverted matrix
            v = maskClipSpaceMatrix.transformVector(v);
            trace("moved to local mask space: " + v);

            v = new Vector3D((v.x + (maskBitmap.width * 0.5)) / maskBitmap.width,
                             (v.y + (maskBitmap.height * 0.5)) / maskBitmap.height, 0.0, 1.0);

            trace("cal local mask uv: " + v);
        }

        override protected function step(elapsed:Number):void {
            super.step(elapsed);

            statsRef.visible = false;

            sprite.x = camera.sceneWidth * 0.5;
            sprite.y = camera.sceneHeight * 0.5;
            sprite.rotation += 2.0;

            mask.x = mouseX;
            mask.y = mouseY;
        }
    }
}
