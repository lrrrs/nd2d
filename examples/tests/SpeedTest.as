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

	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class SpeedTest extends Scene2D {

		private var comboBox:ComboBox;
		private var label:Label;

		[Embed(source="/assets/spritechar2.png")]
		private var spriteTexture:Class;

		private var spriteCloud:Sprite2DCloud;
		private var spriteBatch:Sprite2DBatch;

		private var tex:Texture2D;
		private var sheet:SpriteSheet;

		private var selectedTestIdx:int = -1;
		private var numChilds:uint = 0;
		private var maxCloudSize:uint = 16000;

		public function SpeedTest() {

			backgroundColor = 0x666666;

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}

		private function removedFromStage(e:Event):void {
			if(comboBox) {
				stage.removeChild(comboBox);
			}

			if(label) {
				stage.removeChild(label);
			}
		}

		private function addedToStage(e:Event):void {

			if(!comboBox) {

				Style.LABEL_TEXT = 0x000000;

				comboBox = new ComboBox(stage, 0, 130, "select test", ["Sprite2D shared Texture", "Sprite2DCloud", "Sprite2DBatch", "Sprite2D individual Textures", "clear"]);
				comboBox.width = 150;
				comboBox.addEventListener(Event.SELECT, onTestSelect);
				comboBox.numVisibleItems = 5;

				label = new Label(stage, 5, 150);
				label.textField.textColor = 0xFFFFFF;

				tex = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

				sheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 24, 32, 10);
				sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
				sheet.playAnimation("blah");

			} else {
				stage.addChild(comboBox);
				stage.addChild(label);
			}
		}

		private function onTestSelect(e:Event):void {
			// clean up
			for each(var n:Node2D in children) {
				var s:Sprite2D = n as Sprite2D;
				if(s && s.texture && s.texture != tex) {
					s.texture.dispose();
				}

				n.dispose();
			}
			removeAllChildren();

			numChilds = 0;

			if(spriteBatch) {
				spriteBatch.dispose();
				spriteBatch = null;
			}

			if(spriteCloud) {
				spriteCloud.dispose();
				spriteCloud = null;
			}

			selectedTestIdx = comboBox.selectedIndex;

			switch(selectedTestIdx) {
				case 1:
					spriteCloud = new Sprite2DCloud(maxCloudSize, tex);
					spriteCloud.setSpriteSheet(sheet);
					addChild(spriteCloud);
					break;
				case 2:
					spriteBatch = new Sprite2DBatch(tex);
					spriteBatch.setSpriteSheet(sheet);
					addChild(spriteBatch);
					break;
			}
		}


		override protected function step(elapsed:Number):void {
			super.step(elapsed);

			if(Main.stats.measuredFPS >= 60.0) {

				var s:Sprite2D;

				switch(selectedTestIdx) {
					case 0:
						++numChilds;
						s = new Sprite2D(tex);
						s.setSpriteSheet(sheet.clone());
						s.x = stage.stageWidth * Math.random();
						s.y = stage.stageHeight * Math.random();
						addChild(s);
						s.spriteSheet.playAnimation("blah");
						break;

					case 1:
						if(numChilds < maxCloudSize) {
							++numChilds;
							s = new Sprite2D();
							s.x = stage.stageWidth * Math.random();
							s.y = stage.stageHeight * Math.random();
							spriteCloud.addChild(s);
							s.spriteSheet.playAnimation("blah");
						}
						break;

					case 2:
						++numChilds;
						s = new Sprite2D();
						s.x = stage.stageWidth * Math.random();
						s.y = stage.stageHeight * Math.random();
						spriteBatch.addChild(s);
						s.spriteSheet.playAnimation("blah");
						break;

					case 3:
						++numChilds;
						var rndTex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData, true);
						var c:ColorTransform = new ColorTransform();
						c.redMultiplier = Math.random();
						c.greenMultiplier = Math.random();
						c.blueMultiplier = Math.random();
						rndTex.bitmap.colorTransform(rndTex.bitmap.rect, c);

						s = new Sprite2D(rndTex);
						s.setSpriteSheet(sheet.clone());
						s.x = stage.stageWidth * Math.random();
						s.y = stage.stageHeight * Math.random();
						s.spriteSheet.playAnimation("blah");
						addChild(s);
						break;
				}

				label.text = "numChildren: " + String(numChilds);
			}

			var n:Node2D;

			switch(selectedTestIdx) {
				case 0:
				case 3:
					for each(n in children) {
						n.rotation += 10.0;
					}
					break;
				case 1:
					for each(n in spriteCloud.children) {
						n.rotation += 10.0;
					}
					break;
				case 2:
					for each(n in spriteBatch.children) {
						n.rotation += 10.0;
					}
					break;
			}
		}
	}
}
