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
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	public class BatchTest extends Scene2D {

		[Embed(source="/assets/crate.jpg")]
		private var spriteImage:Class;

		[Embed(source="/assets/spritechar2.png")]
		private var spriteTexture2:Class;

		private var batch:Node2D;

		private var batch2:Sprite2DBatch;
		private var batchNode:Node2D;

		public function BatchTest() {

			backgroundColor = 0xCCCCCC;

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteImage().bitmapData);
			var tex2:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture2().bitmapData);

			var sheet:SpriteSheet = new SpriteSheet(tex2.bitmapWidth, tex2.bitmapHeight, 24, 32, 5);
			sheet.addAnimation("up", [6, 7, 8], true);
			sheet.playAnimation("up", 0, true);

			batch = new Sprite2DBatch(tex);
			addChild(batch);

			var s:Sprite2D = new Sprite2D();
			s.x = s.y = 200.0;
			batch.addChild(s);

			s = new Sprite2D();
			s.x = s.y = 400.0;
			s.alpha = 0.9;
			batch.addChild(s);

			var prevChild:Sprite2D = s;
			var s2:Sprite2D;

			for(var i:int = 0; i < 5; i++) {
				s2 = new Sprite2D();
				s2.x = s2.y = 128.0;
				s2.scaleX = s2.scaleY = 0.8;
				s2.alpha = 0.9;
				s2.rotation = 60.0;
				prevChild.addChild(s2);

				prevChild = s2;
			}

			// batch with node2d test
			batch2 = new Sprite2DBatch(tex2);
			batch2.setSpriteSheet(sheet);
			addChild(batch2);

			batchNode = new Node2D();
			batchNode.x = 800.0;
			batchNode.y = 300.0;
			batch2.addChild(batchNode);

			s = new Sprite2D();
			s.x = 700.0;
			s.y = 300.0;
			batch2.addChild(s);
			s.spriteSheet.playAnimation("up");

			s = new Sprite2D();
			s.x = 100.0;
			s.scaleX = s.scaleY = 0.5;
			batchNode.addChild(s);
			s.spriteSheet.playAnimation("up");

			s2 = new Sprite2D();
			s2.x = 50.0;
			s2.scaleX = s2.scaleY = 3.0;
			s.addChild(s2);
			s2.spriteSheet.playAnimation("up");
		}

		override protected function step(elapsed:Number):void {
			super.step(elapsed);

			for(var i:int = 0; i < batch.children.length; i++) {
				var child:Node2D = batch.getChildAt(i);
				child.rotation += 1.0 + i;
			}

			batchNode.x += Math.sin(timeSinceStartInSeconds) * 3.0;
			batchNode.rotation += 1.0;
		}
	}
}
