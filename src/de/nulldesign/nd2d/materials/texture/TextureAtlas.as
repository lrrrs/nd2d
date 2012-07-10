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

	import de.nulldesign.nd2d.materials.texture.parser.ATextureAtlasParser;
	import de.nulldesign.nd2d.materials.texture.parser.TexturePackerParser;
	import de.nulldesign.nd2d.materials.texture.parser.ZwopTexParser;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class TextureAtlas extends ASpriteSheetBase {

		/**
		 * spritesPackedWithoutSpace set to true to get rid of pixel bleeding for packed atlases without spaces: http://www.nulldesign.de/2011/08/30/nd2d-pixel-bleeding/
		 * @param sheetWidth
		 * @param sheetHeight
		 * @param xmlData
		 * @param parser
		 * @param fps
		 * @param spritesPackedWithoutSpace
		 */
		public function TextureAtlas(sheetWidth:Number, sheetHeight:Number, xmlData:XML, parser:ATextureAtlasParser, fps:uint, spritesPackedWithoutSpace:Boolean = false) {
			this.fps = fps;
			this.spritesPackedWithoutSpace = spritesPackedWithoutSpace;
			this._sheetWidth = sheetWidth;
			this._sheetHeight = sheetHeight;

			if(xmlData) {
				parse(xmlData, parser);
			}
		}

		override public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {

			if(keyFrames[0] is String) {

				// make indices out of names
				var keyFramesIndices:Array = [];

				for(var i:int = 0; i < keyFrames.length; i++) {
					keyFramesIndices.push(frameNameToIndex[keyFrames[i]]);
				}

				animationMap[name] = new SpriteSheetAnimation(keyFramesIndices, loop);

			} else {
				animationMap[name] = new SpriteSheetAnimation(keyFrames, loop);
			}
		}

		/**
		 * paeser switch
		 * @param value
		 */
		protected function parse(value:XML, parser:ATextureAtlasParser):void {

			parser.parse(value);

			frameNameToIndex = parser.frameNameToIndex;
			frames = parser.frames;
			offsets = parser.offsets;

			uvRects = new Vector.<Rectangle>(frames.length, true);
			frame = 0;
		}

		override public function clone():ASpriteSheetBase {

			var t:TextureAtlas = new TextureAtlas(_sheetWidth, _sheetHeight, null, null, fps, spritesPackedWithoutSpace);

			t.animationMap = animationMap;
			t.activeAnimation = activeAnimation;
			t.frames = frames;
			t.offsets = offsets;
			t.frameNameToIndex = frameNameToIndex;
			t.uvRects = uvRects;
			t.frame = frame;

			return t;
		}
	}
}
