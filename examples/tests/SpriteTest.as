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
	import de.nulldesign.nd2d.utils.ColorUtil;

	import flash.utils.getTimer;

	public class SpriteTest extends Scene2D {

        [Embed(source="../assets/crate.jpg")]
        private var spriteTexture:Class;

        private var s:Sprite2D;
        private var s2:Sprite2D;
        private var s3:Sprite2D;

        public function SpriteTest() {

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

            s = new Sprite2D(tex);
            addChild(s);

            s2 = new Sprite2D(tex);
            addChild(s2);

            s3 = new Sprite2D(tex);
            addChild(s3);
        }

        override protected function step(elapsed:Number):void {

            s.x = stage.stageWidth / 2;
            s.y = stage.stageHeight / 2;

            s.rotation += 2;
            //s.scaleX = s.scaleY = 2.0 + Math.sin(getTimer() * 0.001);
            s.tint = ColorUtil.rgb2hex(255 * (0.5 + Math.sin(getTimer() * 0.002) * 0.5),
                                       255 * (0.5 + Math.cos(getTimer() * 0.001) * 0.5),
                                       255 * (0.5 + Math.sin(getTimer() * 0.003) * 0.5));

            s2.x = stage.stageWidth / 2 - s2.width / 1.5;
            s2.y = stage.stageHeight / 2;
            s2.rotation += 2;
            s2.alpha = 0.5 + Math.sin(getTimer() * 0.001) * 0.5;

            s3.x = stage.stageWidth / 2 + s3.width / 1.5;
            s3.y = stage.stageHeight / 2;
            s3.rotation -= 1;
            s3.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

            camera.x = Math.sin(getTimer() / 5000) * 20.0;
            camera.y = Math.cos(getTimer() / 5000) * 20.0;
            camera.rotation += 4.0;
            camera.zoom = 1.0 + Math.sin(getTimer() / 3000) * 0.3;
        }
    }
}