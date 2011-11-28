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
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.events.Event;
	import flash.geom.Point;

	public class MassiveSpritesTest extends Scene2D {

		[Embed(source="/assets/particle_small.png")]
		private var cubeTexture:Class;

		private var sprites:Vector.<Sprite2D>;
		private var spriteCloud:Node2D;

		private var perlinBmp:BitmapData;

		private var maxParticles:uint = 6000;

		public function MassiveSpritesTest() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		protected function randomizeParticle(s:Sprite2D):void {
			s.x = Math.random() * stage.stageWidth;
			s.y = Math.random() * stage.stageHeight;
			s.vx = (Math.random() - Math.random()) * 15;
			s.vy = (Math.random() - Math.random()) * 15;
			s.alpha = 1.0;
		}

		protected function addedToStage(e:Event):void {

			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			sprites = new Vector.<Sprite2D>();
			var tex:Texture2D = Texture2D.textureFromBitmapData(new cubeTexture().bitmapData);
			var s:Sprite2D;

			// CPU 95%, FPS 60
			spriteCloud = new Sprite2DCloud(maxParticles, tex);

			// CPU 122%, FPS 46
			//spriteCloud = new Sprite2DBatch(tex);

			spriteCloud.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

			for(var i:int = 0; i < maxParticles; i++) {
				s = new Sprite2D();
				randomizeParticle(s);
				sprites[i] = s;
				spriteCloud.addChild(s);
			}

			addChild(spriteCloud);

			perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, false, false,
					BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);

			stage.addEventListener(Event.RESIZE, resizeStage);
		}

		protected function resizeStage(e:Event):void {

			if(stage) {
				perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
				perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, true, false,
						BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);
			}
		}

		override protected function step(elapsed:Number):void {

			var p:Number;
			var s:Sprite2D;
			var len:int = sprites.length;
			var r:uint;
			var g:uint;
			var b:uint;
			var mdiff:Point = new Point(0.0, 0.0);

			for(var i:int = 0; i < len; i++) {
				s = sprites[i];
				s.x += s.vx;
				s.y += s.vy;

				if(s.x < 0) {
					//s.x = 0;
					//s.vx *= -1;
					randomizeParticle(s);
				}

				if(s.x > stage.stageWidth) {
					//s.x = stage.stageWidth;
					//s.vx *= -1;
					randomizeParticle(s);
				}

				if(s.y < 0) {
					//s.y = 0;
					//s.vy *= -1;
					randomizeParticle(s);
				}

				if(s.y > stage.stageHeight) {
					//s.y = stage.stageHeight;
					//s.vy *= -1;
					randomizeParticle(s);
				}

				mdiff.x = stage.mouseX - s.x;
				mdiff.y = stage.mouseY - s.y;

				if(mdiff.length < 100.0) {
					s.vx -= mdiff.x * 0.02;
					s.vy -= mdiff.y * 0.02;
				}

				p = perlinBmp.getPixel(s.x, s.y);

				r = p >> 16;
				g = p >> 8 & 255;
				b = p & 255;

				s.vx += (r - b) * 0.003;
				s.vy += (g - b) * 0.003;

				// clip
				s.vx = Math.min(s.vx, 3);
				s.vy = Math.min(s.vy, 3);
				s.vx = Math.max(s.vx, -3);
				s.vy = Math.max(s.vy, -3);

				r = (s.x / stage.stageWidth) * 255;
				g = (s.y / stage.stageHeight) * 255;
				b = Math.abs(Math.round((s.vx + s.vy))) * 10;
				s.tint = (r << 16 | g << 8 | b);
				s.alpha -= 0.001;
			}
		}
	}
}