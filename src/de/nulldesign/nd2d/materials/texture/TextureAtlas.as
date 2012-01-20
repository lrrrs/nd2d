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

	public class TextureAtlas extends ASpriteSheetBase {

		protected var xmlData:XML;

		/**
		 *
		 * @param sheetWidth
		 * @param sheetHeight
		 * @param cocos2DXML
		 * @param fps
		 * @param spritesPackedWithoutSpace set to true to get rid of pixel bleeding for packed atlases without spaces: http://www.nulldesign.de/2011/08/30/nd2d-pixel-bleeding/
		 */
		public function TextureAtlas(sheetWidth:Number, sheetHeight:Number, cocos2DXML:XML, fps:uint, spritesPackedWithoutSpace:Boolean = false) {
			this.fps = fps;
			this.xmlData = cocos2DXML;
			this.spritesPackedWithoutSpace = spritesPackedWithoutSpace;
			this._sheetWidth = sheetWidth;
			this._sheetHeight = sheetHeight;

			if(xmlData) {
				parseCocos2DXML(xmlData);
			}
		}

		override public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {

			if(keyFrames[i] is String) {

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
		 * Parser code "borrowed" from: http://blog.kaourantin.net/?p=110
		 * @param cocos2DXML
		 */
		protected function parseCocos2DXML(cocos2DXML:XML):void {

			var type:String;
			var data:String;
			var array:Array;

			var topKeys:XMLList = cocos2DXML.dict.key;
			var topDicts:XMLList = cocos2DXML.dict.dict;

			for(var k:uint = 0; k < topKeys.length(); k++) {
				switch(topKeys[k].toString()) {
					case "frames":
					{
						var frameKeys:XMLList = topDicts[k].key;
						var frameDicts:XMLList = topDicts[k].dict;

						for(var l:uint = 0; l < frameKeys.length(); l++) {

							var keyName:String = frameKeys[l];
							var propKeys:XMLList = frameDicts[l].key;
							var propAll:XMLList = frameDicts[l].*;

							frameNameToIndex[keyName] = l;

							for(var m:uint = 0; m < propKeys.length(); m++) {

								type = propAll[propKeys[m].childIndex() + 1].name();
								data = propAll[propKeys[m].childIndex() + 1];

								switch(propKeys[m].toString()) {
									case "frame":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											frames.push(new Rectangle(array[1], array[2], array[3], array[4]));
										} else {
											throw new Error("Error parsing descriptor format");
										}
									}
										break;
									case "offset":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											// our coordinate system is different than the cocos one
											offsets.push(new Point(array[1], -array[2]));
										} else {
											throw new Error("Error parsing descriptor format");
										}
									}
										break;
									case "sourceSize":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											sourceSizes.push(new Point(array[1], array[2]));
										} else {
											throw new Error("Error parsing descriptor format");
										}
									}
										break;
									case "sourceColorRect":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											sourceColorRects.push(new Rectangle(array[1], array[2], array[3], array[4]));
										} else {
											throw new Error("Error parsing descriptor format");
										}
									}
										break;
									case "rotated":
									{
										if(type != "false") {
											throw new Error("Rotated elements not supported (yet)");
										}
									}
										break;
								}
							}
							/*
							// calculate real offset
							const idx:uint = sourceColorRects.length - 1;
							const offset:Point = offsets[idx];
							const sourceFrame:Rectangle = frames[idx];
							const sourceColorRect:Rectangle = sourceColorRects[idx];
							const sourceSize:Point = sourceSizes[idx];
							const newOffset:Point = new Point((sourceSize.x - sourceFrame.width) / 2 - sourceColorRect.x, (sourceSize.y - sourceFrame.height) / 2 - sourceColorRect.y);

							offset.x = -newOffset.x;
							offset.y = -newOffset.y;
							*/
						}
					}
						break;
				}
			}

			const frames_length:int = frames.length;
			if(frames_length == 0) {
				throw new Error("Error parsing descriptor format");
			}

			uvRects = new Vector.<Rectangle>(frames_length, true);
			frame = 0;

			/*
			 Frame:
			 Top-Left originating rectangle of the sprite's pixel texture coordinates. Cocos2'd will convert these to UV coordinates (0-1) when loading based on the texture size.

			 Offset:
			 Zwoptex trim's transparency off sprites. Because of this sprite's need to be offset to ensure their texture is drawn in correct alignment to their original size.

			 Source Color Rect:
			 This is the Top-Left originating rectangle that is the valid pixel data of the sprite. Say you have a 512x512 sprite that only has 10x10 pixels of data inside of it located at 500x500. The source color rect could be {500,500,10,10}.

			 Format:
			 Version number related to what version of Zwoptex was used so cocos2d knows how to parse the plist properly.
			 Flash Version: 0
			 Desktop Version 0-0.4b: 1
			 Desktop Version 1.x: 2
			 */
		}

		override public function clone():ASpriteSheetBase {

			var t:TextureAtlas = new TextureAtlas(_sheetWidth, _sheetHeight, xmlData, fps, spritesPackedWithoutSpace);

			for(var name:String in animationMap) {
				var anim:SpriteSheetAnimation = animationMap[name];
				t.addAnimation(name, anim.frames.concat(), anim.loop);
			}

			t.frame = frame;

			return t;
		}
	}
}
