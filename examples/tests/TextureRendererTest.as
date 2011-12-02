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

	import de.nulldesign.nd2d.display.Grid2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.TextureRenderer;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import tests.objects.MorphGrid;

	public class TextureRendererTest extends Scene2D {

		[Embed(source="../assets/crate.jpg")]
		private var spriteTexture:Class;

		private var s:Sprite2D;
		private var s2:Sprite2D;
		private var texturedGrid:Grid2D;

		private var texRenderer:TextureRenderer;

		public function TextureRendererTest() {

			var b:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

			s = new Sprite2D(b);
			s2 = new Sprite2D(b);
			s2.scaleX = s2.scaleY = 0.5;

			s.addChild(s2);
			//s.visible = false;

			var renderTexture:Texture2D = Texture2D.textureFromSize(256, 256);

			texRenderer = new TextureRenderer(s, renderTexture);

			addChild(s);
			addChild(texRenderer);

			texturedGrid = new MorphGrid(12, 12, renderTexture, 0.05);
			texturedGrid.tint = 0x99ff00;
			addChild(texturedGrid);
		}

		override protected function step(elapsed:Number):void {
			s.x = stage.stageWidth * 0.5 - s.width * 0.55;
			s.y = stage.stageHeight * 0.5;

			//s.rotation += 1;
			s2.rotation += 1;

			texturedGrid.x = stage.stageWidth * 0.5 + texturedGrid.width * 0.55;
			texturedGrid.y = stage.stageHeight * 0.5;
		}
	}
}
