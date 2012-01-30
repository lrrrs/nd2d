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

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display.BitmapData;

	import flashx.textLayout.formats.TextAlign;

	/**
	 * BitmapFont2D
	 * <p>Displays monospaced fonts from a bitmap source.</p>
	 */
	public class BitmapFont2D extends Sprite2DCloud {

		private var charString:String;
		private var charSpacing:Number;

		private var textChanged:Boolean = false;

		private var _text:String;

		public function get text():String {
			return _text;
		}

		public function set text(value:String):void {
			if(text != value) {
				_text = value;
				textChanged = true;
			}
		}

		private var _textAlign:String = TextAlign.LEFT;

		public function get textAlign():String {
			return _textAlign;
		}

		public function set textAlign(value:String):void {
			_textAlign = value;
			if(_text != null) {
				textChanged = true;
			}
		}

		public function BitmapFont2D(fontTexture:Texture2D, charWidth:Number, charHeight:Number, charString:String, charSpacing:Number, maxTextLen:uint, spritesPackedWithoutSpaces:Boolean = false) {

			this.charString = charString;
			this.charSpacing = charSpacing;

			super(maxTextLen, fontTexture);
			setSpriteSheet(new SpriteSheet(fontTexture.bitmapWidth, fontTexture.bitmapHeight, charWidth, charHeight, 1, spritesPackedWithoutSpaces));
		}

		override protected function step(elapsed:Number):void {

			if(textChanged) {
				textChanged = false;

				const numSpaces:uint = text.split(" ").length - 1;
				const text_length:int = text.length;
				const childsNeeded:uint = text_length - numSpaces;

				while(numChildren < maxCapacity && numChildren < childsNeeded) {
					addChild(new Sprite2D());
				}

				while(numChildren > childsNeeded) {
					removeChildAt(0);
				}

				var s:Sprite2D;
				var curChar:String;
				var frame:int;
				var childIdx:uint = 0;
				var startX:Number = spriteSheet.spriteWidth >> 1;

				switch(textAlign) {

					case TextAlign.CENTER:
						startX -= (text_length * spriteSheet.spriteWidth) >> 1;
						break;

					case TextAlign.RIGHT:
						startX += -(text_length * spriteSheet.spriteWidth);
						break;
				}

				for(var i:int = 0; i < text_length; i++) {

					curChar = text.charAt(i);
					frame = Math.max(0, charString.indexOf(curChar));

					s = Sprite2D(children[childIdx]);
					s.spriteSheet.frame = frame;

					s.x = startX + charSpacing * i;
					s.y = 0.0;

					if(curChar != " ") {
						++childIdx;
					}
				}

				_width = s.x + spriteSheet.spriteWidth;
				_height = spriteSheet.spriteHeight;
			}
		}
	}
}
