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
	import com.bit101.components.HUISlider;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureOption;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class TextureAndRotationOptionsTest extends Scene2D {

		[Embed(source="/assets/crate.jpg")]
		private var crateTexture:Class;

		[Embed(source="/assets/spritechar1.png")]
		private var spriteTexture:Class;


		private var s:Sprite2D;
		private var s2:Sprite2D;
		private var s3:Sprite2D;

		private var container:Sprite;

		private var textureComboBox:ComboBox;
		private var mipMapComboBox:ComboBox;
		private var filteringComboBox:ComboBox;
		private var repeatComboBox:ComboBox;

		public function TextureAndRotationOptionsTest() {

			backgroundColor = 0x333333;

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		}

		private function removedFromStage(e:Event):void {
			if(container) {
				stage.removeChild(container);
			}
		}

		private function addedToStage(e:Event):void {

			if(!container) {

				container = new Sprite();
				stage.addChild(container);

				var slider:HUISlider;

				Style.LABEL_TEXT = 0xFFFFFF;

				slider = new HUISlider(container, 0, 130, "uvOffsetX", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 5.0;
				slider.value = 0.0;

				slider = new HUISlider(container, 0, 150, "uvOffsetY", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 5.0;
				slider.value = 0.0;

				slider = new HUISlider(container, 0, 170, "uvScaleX", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 5.0;
				slider.value = 1.0;

				slider = new HUISlider(container, 0, 190, "uvScaleY", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 5.0;
				slider.value = 1.0;

				slider = new HUISlider(container, 0, 330, "rotationX", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 360.0;
				slider.value = 0.0;

				slider = new HUISlider(container, 0, 350, "rotationY", sliderChanged);
				slider.minimum = 0.0;
				slider.maximum = 360.0;
				slider.value = 0.0;

				Style.LABEL_TEXT = 0x000000;

				mipMapComboBox = new ComboBox(container, 10, 210, "mipmapping", ["mipdisable", "mipnearest", "miplinear"]);
				mipMapComboBox.width = 120;
				mipMapComboBox.selectedIndex = 2;
				mipMapComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
				mipMapComboBox.numVisibleItems = 3;

				filteringComboBox = new ComboBox(container, 10, 240, "texture filtering", ["nearest", "linear"]);
				filteringComboBox.width = 120;
				filteringComboBox.selectedIndex = 1;
				filteringComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
				filteringComboBox.numVisibleItems = 2;

				repeatComboBox = new ComboBox(container, 10, 270, "texture repeat", ["repeat", "clamp"]);
				repeatComboBox.width = 120;
				repeatComboBox.selectedIndex = 0;
				repeatComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
				repeatComboBox.numVisibleItems = 2;

				textureComboBox = new ComboBox(container, 10, 300, "texture image", ["crate", "sprites"]);
				textureComboBox.width = 120;
				textureComboBox.selectedIndex = 0;
				textureComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
				textureComboBox.numVisibleItems = 2;

				onTextureOptionChange();

			} else {
				stage.addChild(container);
			}
		}

		private function onTextureOptionChange(e:Event = null):void {

			if(s) {
				s.dispose();
				removeChild(s);
				s2.dispose();
				removeChild(s2);
				s3.dispose();
				removeChild(s3);
			}

			var tex:Texture2D;
			if(textureComboBox.selectedIndex == 0) {
				tex = Texture2D.textureFromBitmapData(new crateTexture().bitmapData, true);
			} else {
				tex = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData, true);
			}

			s = new Sprite2D(tex);
			s.position = new Vector3D(stage.stageWidth / 2 - 300.0, stage.stageHeight / 2);
			s.scaleX = s.scaleY = 0.5;
			addChild(s);

			s2 = new Sprite2D(tex);
			s2.scaleX = s2.scaleY = 1.0;
			s2.position = new Vector3D(stage.stageWidth / 2 - 50, stage.stageHeight / 2);
			addChild(s2);

			s3 = new Sprite2D(tex);
			s3.scaleX = s3.scaleY = 1.5;
			s3.position = new Vector3D(stage.stageWidth / 2 + 300.0, stage.stageHeight / 2);
			addChild(s3);

			tex.textureOptions = 0;
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 0 ? TextureOption.MIPMAP_DISABLE : 0);
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 1 ? TextureOption.MIPMAP_NEAREST : 0);
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 2 ? TextureOption.MIPMAP_LINEAR : 0);
			tex.textureOptions |= (filteringComboBox.selectedIndex == 0 ? TextureOption.FILTERING_NEAREST : 0);
			tex.textureOptions |= (filteringComboBox.selectedIndex == 1 ? TextureOption.FILTERING_LINEAR : 0);
			tex.textureOptions |= (repeatComboBox.selectedIndex == 0 ? TextureOption.REPEAT_NORMAL : 0);
			tex.textureOptions |= (repeatComboBox.selectedIndex == 1 ? TextureOption.REPEAT_CLAMP : 0);
		}

		private function sliderChanged(e:Event):void {

			var slider:HUISlider = e.target as HUISlider;

			switch(slider.label) {
				case "uvOffsetX":
					s.material.uvOffsetX = s2.material.uvOffsetX = s3.material.uvOffsetX = slider.value;
					break;
				case "uvOffsetY":
					s.material.uvOffsetY = s2.material.uvOffsetY = s3.material.uvOffsetY = slider.value;
					break;
				case "uvScaleX":
					s.material.uvScaleX = s2.material.uvScaleX = s3.material.uvScaleX = slider.value;
					break;
				case "uvScaleY":
					s.material.uvScaleY = s2.material.uvScaleY = s3.material.uvScaleY = slider.value;
					break;
				case "rotationX":
					s.rotationX = s2.rotationX = s3.rotationX = slider.value;
					break;
				case "rotationY":
					s.rotationY = s2.rotationY = s3.rotationY = slider.value;
					break;
			}
		}


		override protected function step(elapsed:Number):void {
			if(s && s2 && s3) {
				s.rotation += 0.2;
				s2.rotation += 0.2;
				s3.rotation += 0.2;
			}
		}
	}
}
