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
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.Event;

	public class StarFieldTest extends Scene2D {

        [Embed(source="/assets/starfield.jpg")]
        private var starFieldTexture:Class;

        [Embed(source="/assets/starfield.png")]
        private var starFieldTexture2:Class;

        private var starfield1:Sprite2D;

        private var starfield2:Sprite2D;

        public function StarFieldTest() {

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);

            starfield1 = new Sprite2D(Texture2D.textureFromBitmapData(new starFieldTexture().bitmapData));
            addChild(starfield1);

            starfield2 = new Sprite2D(Texture2D.textureFromBitmapData(new starFieldTexture2().bitmapData));
            starfield2.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;
            addChild(starfield2);
        }

        private function addedToStage(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            starfield1.width = stage.stageWidth;
            starfield1.scaleY = starfield1.scaleX;
            starfield1.x = stage.stageWidth / 2;
            starfield1.y = stage.stageHeight / 2;

            starfield2.width = stage.stageWidth;
            starfield2.scaleY = starfield2.scaleX;
            starfield2.x = stage.stageWidth / 2;
            starfield2.y = stage.stageHeight / 2;
        }

        override protected function step(elapsed:Number):void {
            starfield1.material.uvOffsetX -= (stage.stageWidth * 0.5 - mouseX) * 0.00002;
            starfield1.material.uvOffsetY -= (stage.stageHeight * 0.5 - mouseY) * 0.00002;
            starfield2.material.uvOffsetX -= (stage.stageWidth * 0.5 - mouseX) * 0.00004;
            starfield2.material.uvOffsetY -= (stage.stageHeight * 0.5 - mouseY) * 0.00004;
        }
    }
}