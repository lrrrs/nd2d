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
	import de.nulldesign.nd2d.events.SpriteSheetAnimationEvent;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	public class SpriteAnimTest extends Scene2D {

        [Embed(source="/assets/spritechar1.png")]
        private var spriteTexture:Class;

        private var s:Sprite2D;

        public function SpriteAnimTest() {

            var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);
			//var tex:Texture2D = Texture2D.textureFromATF(new spriteTexture());

            var sheet:SpriteSheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 24, 32, 5);
            sheet.addAnimation("up", [0, 1, 2], true);
            sheet.addAnimation("right", [3, 4, 5], true);
            sheet.addAnimation("down", [6, 7, 8], true);
            sheet.addAnimation("left", [9, 10, 11], true);
            sheet.playAnimation("up", 0, true, true);

            s = new Sprite2D(tex);
            s.setSpriteSheet(sheet);
			s.spriteSheet.addEventListener(SpriteSheetAnimationEvent.ANIMATION_FINISHED, function():void { trace("anim finished"); });
            addChild(s);
        }

        override protected function step(elapsed:Number):void {

            s.x = stage.stageWidth / 2;
            s.y = stage.stageHeight / 2;

            //camera.zoom = 12.0 + Math.sin(getTimer() / 500) * 11.0;
        }
    }
}