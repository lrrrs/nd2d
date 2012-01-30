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

package de.nulldesign.nd2d.materials.texture.parser {

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ZwopTexParser extends ATextureAtlasParser {

		public function ZwopTexParser() {
		}

		override public function parse(xmlData:XML):void {

			var metadata:XML = getDict("metadata", xmlData);

			if(!metadata) {
				throw new Error("Unrecognised XML Format. Only the Zwoptex App XML is supported. The Flash app is not supported at the moment. Feel free to write a parser and commit it ;)");
			}

			var format:String = getValueFromDict("format", metadata);

			switch(format) {
				case "3":
					parseZwoptexDefault(xmlData);
					break;
				default:
					throw new Error("Unrecognised XML Format");
					break;
			}
		}

		private function parseZwoptexDefault(xmlData:XML):void {
			var type:String;
			var data:String;
			var array:Array;

			var topKeys:XMLList = xmlData.dict.key;
			var topDicts:XMLList = xmlData.dict.dict;

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
									case "textureRect":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											frames.push(new Rectangle(array[1], array[2], array[3], array[4]));
										} else {
											throw new Error("Error parsing descriptor format");
										}
									}
										break;
									case "spriteOffset":
									{
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											offsets.push(new Point(array[1], -array[2]));
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
						}
					}
						break;
				}
			}
		}
	}
}
