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
	import flash.utils.Dictionary;

	public class ATextureAtlasParser {

		protected var framesList:Vector.<Rectangle> = new Vector.<Rectangle>();
		protected var offsetList:Vector.<Point> = new Vector.<Point>();
		protected var frameNameToIndexMap:Dictionary = new Dictionary();

		public function ATextureAtlasParser() {

		}

		protected function getValueFromDict(key:String, xmlData:XML):String {
			var propKeys:XMLList = xmlData.key;
			var propAll:XMLList = xmlData.*;

			for(var m:uint = 0; m < propKeys.length(); m++) {

				var name:String = propKeys[m].toString();
				var type:String = propAll[propKeys[m].childIndex() + 1].name();
				var data:String = propAll[propKeys[m].childIndex() + 1];

				if(key == name) {
					return data;
				}
			}

			return null;
		}

		protected function getDict(name:String, xmlData:XML):XML {
			var topKeys:XMLList = xmlData.dict.key;
			var topDicts:XMLList = xmlData.dict.dict;

			// try to read the format
			for(var k:uint = 0; k < topKeys.length(); k++) {

				if(topKeys[k].toString() == name) {
					return topDicts[k];
				}
			}

			return null;
		}

		public function get frames():Vector.<Rectangle> {
			return framesList;
		}

		public function get offsets():Vector.<Point> {
			return offsetList;
		}

		public function get frameNameToIndex():Dictionary {
			return frameNameToIndexMap;
		}

		public function parse(data:XML):void {
		}
	}
}
