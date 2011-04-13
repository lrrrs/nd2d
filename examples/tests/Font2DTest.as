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

package tests {
    import de.nulldesign.nd2d.display.Font2D;
    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Scene2D;

    import de.nulldesign.nd2d.utils.ColorUtil;

    import de.nulldesign.nd2d.utils.NumberUtil;

    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.utils.getTimer;

    import flashx.textLayout.formats.TextAlign;

    public class Font2DTest extends Scene2D {

        [Embed(source="/assets/kromagrad_16x16.png")]
        private var fontTexture:Class;

        private var fontChars:String = " !\"©♥%<'()^+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        private var font:Font2D;
        private var counter:Font2D;

        public function Font2DTest() {

            backGroundColor = 0x333333;
            addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
        }

        private function addedToStage(event:Event):void {

            var fontBmp:BitmapData = new fontTexture().bitmapData;

            font = new Font2D(fontBmp, 16, 16, fontChars, 20, 300);
            font.text = "HELLO FOLKS!         ND2D JUST GOT NICE BITMAP FONTS.      DON'T YOU JUST ♥ IT? :)";
            font.x = stage.stageWidth;
            addChild(font);

            counter = new Font2D(fontBmp, 16, 16, fontChars, 16, 10);
            counter.textAlign = TextAlign.CENTER;
            addChild(counter);
        }

        override protected function step(t:Number):void {

            counter.x = stage.stageWidth * 0.5;
            counter.y = 20.0;
            counter.text = String(getTimer());

            font.x -= 3.0;
            font.y = stage.stageHeight * 0.5;

            if(font.x < -font.width) {
              font.x = stage.stageWidth;
            }

            var n:Node2D;
            for(var i:int = 0; i < font.children.length; i++) {
                n = font.children[i];
                n.y = Math.sin(i * 0.5 + t * 2.0) * 40.0;
                n.rotation = n.y;

                if(i == 50) {
                  n.tint = ColorUtil.mixColors(0xff0000, 0x00ff00, NumberUtil.sin0_1(t));
                }
            }
        }
    }
}
