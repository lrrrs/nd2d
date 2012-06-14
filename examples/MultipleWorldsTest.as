/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
 *  Getting started: https://github.com/nulldesign/nd2d/wiki
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

package {

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.World2D;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	[SWF(width="800", height="600", frameRate="60", backgroundColor="#333333")]
	public class MultipleWorldsTest extends Sprite {

		[Embed(source="/assets/spritechar1.png")]
		private var spriteTexture:Class;

		private var world1:World2D;
		private var world2:World2D;

		public function MultipleWorldsTest() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			world1 = new World2D(Context3DRenderMode.AUTO, 60, new Rectangle(20.0, 20.0, 320.0, 240.0), 0);
			addChild(world1);
			world2 = new World2D(Context3DRenderMode.SOFTWARE, 60, new Rectangle(360.0, 20.0, 320.0, 240.0), 1);
			addChild(world2);

			var scene1:Scene2D = new Scene2D();
			scene1.backgroundColor = 0xAAAAAA;
			world1.setActiveScene(scene1);
			var scene2:Scene2D = new Scene2D();
			scene2.backgroundColor = 0xEEEEEE;
			world2.setActiveScene(scene2);

			var tex1:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);
			var tex2:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

			var sheet1:SpriteSheet = new SpriteSheet(tex1.bitmapWidth, tex1.bitmapHeight, 24, 32, 10);
			sheet1.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
			sheet1.playAnimation("blah", 0, true, false);

			var sheet2:SpriteSheet = new SpriteSheet(tex2.bitmapWidth, tex2.bitmapHeight, 24, 32, 10);
			sheet2.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
			sheet2.playAnimation("blah", 0, true, false);

			var s1:Sprite2D = new Sprite2D(tex1);
			s1.setSpriteSheet(sheet1);
			s1.position = new Vector3D(100.0, 100.0);
			scene1.addChild(s1);

			var s2:Sprite2D = new Sprite2D(tex2);
			s2.setSpriteSheet(sheet2);
			s2.position = new Vector3D(100.0, 100.0);
			scene2.addChild(s2);

			world1.start();
			world2.start();
		}
	}
}
