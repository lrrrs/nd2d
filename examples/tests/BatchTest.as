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

    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.Sprite2DBatch;

    public class BatchTest extends Scene2D {

        [Embed(source="/assets/crate.jpg")]
        private var spriteImage:Class;

        private var batch:Node2D;

        public function BatchTest() {

            batch = new Sprite2DBatch(new spriteImage().bitmapData);
            addChild(batch);

            var s:Sprite2D = new Sprite2D();
            s.x = s.y = 200.0;
            batch.addChild(s);

            s = new Sprite2D();
            s.x = s.y = 400.0;
            s.tint = 0xff9900;
            s.alpha = 0.5;
            batch.addChild(s);
        }

        override protected function step(elapsed:Number):void {
            super.step(elapsed);

            for(var i:int = 0; i < batch.children.length; i++) {
                var child:Node2D = batch.getChildAt(i);
                child.rotation += 1.0 + 1.0 * i;
            }
        }
    }
}
