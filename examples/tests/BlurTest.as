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
	import de.nulldesign.nd2d.materials.Sprite2DBlurMaterial;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureOption;
	import de.nulldesign.nd2d.materials.texture.TextureOption;
	import de.nulldesign.nd2d.utils.NumberUtil;

	public class BlurTest extends Scene2D {

		[Embed(source="/assets/nd_logo.png")]
		private var crateBitmap:Class;

		[Embed(source="/assets/spritechar1.png")]
		private var spriteBitmap:Class;

		private var sprite:Sprite2D;
		private var sprite2:Sprite2D;
		private var sprite3:Sprite2D;
		private var blurMaterial:Sprite2DBlurMaterial;
		private var blurMaterial2:Sprite2DBlurMaterial;
		private var blurMaterial3:Sprite2DBlurMaterial;

		public function BlurTest() {

			backgroundColor = 0x666666;

			var tex1:Texture2D = Texture2D.textureFromBitmapData(new crateBitmap().bitmapData);
			tex1.textureOptions = TextureOption.FILTERING_LINEAR | TextureOption.MIPMAP_LINEAR | TextureOption.REPEAT_CLAMP;

			var tex2:Texture2D = Texture2D.textureFromBitmapData(new spriteBitmap().bitmapData);
			tex2.textureOptions = TextureOption.FILTERING_NEAREST | TextureOption.MIPMAP_DISABLE | TextureOption.REPEAT_CLAMP;

			var sheet:SpriteSheet = new SpriteSheet(tex2.bitmapWidth, tex2.bitmapHeight, 24, 32, 5);
			sheet.addAnimation("test", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
			sheet.playAnimation("test", 0, true);

			sprite = new Sprite2D(tex1);
			addChild(sprite);

			sprite2 = new Sprite2D(tex2);
			addChild(sprite2);
			sprite2.setSpriteSheet(sheet);
			sprite2.scaleX = sprite2.scaleY = 4.0;

			sprite3 = new Sprite2D(tex2);
			addChild(sprite3);

			blurMaterial = new Sprite2DBlurMaterial();
			sprite.setMaterial(blurMaterial);

			blurMaterial2 = new Sprite2DBlurMaterial();
			sprite2.setMaterial(blurMaterial2);

			blurMaterial3 = new Sprite2DBlurMaterial();
			sprite3.setMaterial(blurMaterial3);
		}

		override protected function step(elapsed:Number):void {

			super.step(elapsed);

			sprite.x = camera.sceneWidth * 0.5 - sprite.width;
			sprite.y = camera.sceneHeight * 0.5;
			sprite.rotation += 5.0;

			sprite2.x = camera.sceneWidth * 0.5 + sprite2.width;
			sprite2.y = camera.sceneHeight * 0.5;

			sprite3.x = sprite2.x + sprite2.width * 2.0;
			sprite3.y = sprite2.y;

			//var blur:Number = NumberUtil.sin0_1(timeSinceStartInSeconds * 5.0) * 20.0;
			var blurX:Number = (stage.mouseX / stage.stageWidth) * 20.0;
			var blurY:Number = (stage.mouseY / stage.stageHeight) * 20.0;

			blurMaterial.setBlur(blurX, blurY);
			blurMaterial2.setBlur(blurX, blurY);
			blurMaterial3.setBlur(blurX, blurY);
		}
	}
}
