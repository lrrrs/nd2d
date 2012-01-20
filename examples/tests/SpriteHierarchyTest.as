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
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class SpriteHierarchyTest extends Scene2D {

		[Embed(source="/assets/crate.jpg")]
		private var spriteTexture:Class;

		[Embed(source="/assets/spritechar2.png")]
		private var spriteTexture2:Class;

		private var s:Sprite2D;
		private var s2:Sprite2D;
		private var s3:Sprite2D;

		private var s4:Sprite2D;
		private var s5:Sprite2D;
		private var s6:Sprite2D;

		public function SpriteHierarchyTest() {

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

			s = new Sprite2D(tex);
			s.mouseEnabled = true;
			s.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addChild(s);

			s2 = new Sprite2D(tex);
			s2.mouseEnabled = true;
			s2.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s2.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			s2.x = 80;
			s2.y = 80;
			s2.scaleX = 0.5;
			s2.scaleY = 0.5;
			s.addChild(s2);

			var tex2:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture2().bitmapData);

			var sheet:SpriteSheet = new SpriteSheet(tex2.bitmapWidth, tex2.bitmapHeight, 24, 32, 5);
			sheet.addAnimation("up", [6, 7, 8], true);
			sheet.playAnimation("up", 0, true);

			s3 = new Sprite2D(tex2);
			s3.setSpriteSheet(sheet);
			s3.mouseEnabled = true;
			s3.usePixelPerfectHitTest = true;
			s3.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s3.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			s3.scaleX = s3.scaleY = 4.0;
			s2.addChild(s3);

			s3.blendMode = BlendModePresets.NORMAL_PREMULTIPLIED_ALPHA;

			s4 = new Sprite2D(tex);
			s5 = new Sprite2D(tex);
			s6 = new Sprite2D(tex);
			s4.mouseEnabled = s5.mouseEnabled = s6.mouseEnabled = true;
			s4.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s4.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			s5.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s5.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			s6.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			s6.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addChild(s4);
			addChild(s5);
			addChild(s6);
			s5.scaleX = s5.scaleY = 0.6;
			s6.scaleX = s6.scaleY = 0.3;
		}

		private function mouseOut(event:MouseEvent):void {
			event.target.tint = 0xffffff;
		}

		private function mouseOver(event:MouseEvent):void {
			event.target.tint = Math.random() * 0xffffff;

			/*
			var n:Node2D = event.target as Node2D;
			var p:Point = n.localToGlobal(new Point(n.mouseX, n.mouseY));
			trace("localToGlobal: " + p + " stage: " + n.mouseX + " // " + n.mouseY);
			p = n.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			trace("globalToLocal: " + p + " stage: " + stage.mouseX + " // " + stage.mouseY);
            */
		}

		override protected function step(elapsed:Number):void {
			/*
			camera.x = 50;
			camera.rotation = 30;
            */
			s.position = new Vector3D(stage.stageWidth / 2, stage.stageHeight / 2);
			s.rotation += 0.1;
			s2.rotation -= 0.5;
			s3.rotation -= 0.5;

			s4.x = s5.x = s6.x = stage.stageWidth * 0.5 + 320;
			s4.y = s5.y = s6.y = stage.stageHeight * 0.5;
		}
	}
}