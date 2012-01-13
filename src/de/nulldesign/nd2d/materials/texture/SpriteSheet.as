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

package de.nulldesign.nd2d.materials.texture {

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SpriteSheet extends ASpriteSheetBase {

		private var nullOffset:Point = new Point();

		/**
		 *
		 * @param sheetWidth
		 * @param sheetHeight
		 * @param spriteWidth
		 * @param spriteHeight
		 * @param fps
		 * @param spritesPackedWithoutSpace set to true to get rid of pixel bleeding for packed sprites without spaces: http://www.nulldesign.de/2011/08/30/nd2d-pixel-bleeding/
		 */
		public function SpriteSheet(sheetWidth:Number, sheetHeight:Number, spriteWidth:Number, spriteHeight:Number, fps:uint, spritesPackedWithoutSpace:Boolean = false) {
			this.fps = fps;
			this.spritesPackedWithoutSpace = spritesPackedWithoutSpace;

			_spriteWidth = spriteWidth;
			_spriteHeight = spriteHeight;
			_sheetWidth = sheetWidth;
			_sheetHeight = sheetHeight;

			generateSheet();
		}

		private function generateSheet():void {
			var numSheetsPerRow:int = Math.round(_sheetWidth / spriteWidth);
			var numRows:int = Math.round(_sheetHeight / spriteHeight);
			var numSheets:int = numSheetsPerRow * numRows;
			var rowIdx:uint;
			var colIdx:uint;

			uvRects = new Vector.<Rectangle>(numSheets, true);
			frames = new Vector.<Rectangle>();
			uvRects = new Vector.<Rectangle>(numSheets, true);

			for(var i:int = 0; i < numSheets; i++) {
				rowIdx = i % numSheetsPerRow;
				colIdx = Math.floor(i / numSheetsPerRow);

				frames.push(new Rectangle((spriteWidth * rowIdx),
						(spriteHeight * colIdx),
						_spriteWidth,
						_spriteHeight));
			}

			frame = 0;
		}

		override public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {
			animationMap[name] = new SpriteSheetAnimation(keyFrames, loop);
		}

		override public function getOffsetForFrame():Point {
			return nullOffset;
		}

		override public function clone():ASpriteSheetBase {

			var s:SpriteSheet = new SpriteSheet(_sheetWidth, _sheetHeight, _spriteWidth, _spriteHeight, fps, spritesPackedWithoutSpace);

			for(var name:String in animationMap) {
				var anim:SpriteSheetAnimation = animationMap[name];
				s.addAnimation(name, anim.frames.concat(), anim.loop);
			}

			s.frame = frame;

			return s;
		}
	}
}
