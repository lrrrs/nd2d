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

	import de.nulldesign.nd2d.utils.TextureHelper;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.utils.ByteArray;

	public class Texture2D {

		private var _textureOptions:uint = TextureOption.QUALITY_ULTRA;

		public function get textureOptions():uint {
			return _textureOptions;
		}

		public function set textureOptions(value:uint):void {
			if(_textureOptions != value) {
				_textureOptions = value;
				textureFilteringOptionChanged = true;
			}
		}

		public var texture:Texture;
		public var bitmap:BitmapData;
		public var compressedBitmap:ByteArray;

		/*
		 * These sizes are needed to calculate the UV offset in a texture.
		 * because the GPU texturesize can differ from the provided bitmap (not a 2^n size)
		 * This is the BitmapData's or the ATF textures original size
		 */
		public var bitmapWidth:Number;
		public var bitmapHeight:Number;

		public var textureWidth:Number;
		public var textureHeight:Number;

		public var hasPremultipliedAlpha:Boolean = true;
		public var textureFilteringOptionChanged:Boolean = true;

		protected var autoCleanUpResources:Boolean;

		/**
		 * Texture2D object
		 * @param autoCleanUpResources if you set it to true, the bitmap or the ATF texture will be disposed after creating the texture. This will save memory, but ND2D is not able to recover from a device loss then (Which is unlikely on a mobile device, but not on a desktop machine)
		 */
		public function Texture2D(autoCleanUpResources:Boolean = false) {
			this.autoCleanUpResources = autoCleanUpResources;
		}

		public static function textureFromBitmapData(bitmap:BitmapData, autoCleanUpResources:Boolean = false):Texture2D {

			var t:Texture2D = new Texture2D(autoCleanUpResources);

			if(bitmap) {
				t.bitmap = bitmap;
				t.bitmapWidth = bitmap.width;
				t.bitmapHeight = bitmap.height;

				var dimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmap);
				t.textureWidth = dimensions.x;
				t.textureHeight = dimensions.y;
				t.hasPremultipliedAlpha = true
			}

			return t;
		}

		public static function textureFromATF(atf:ByteArray, autoCleanUpResources:Boolean = false):Texture2D {

			var t:Texture2D = new Texture2D(autoCleanUpResources);

			if(atf) {

				var w:int = Math.pow(2, atf[7]);
				var h:int = Math.pow(2, atf[8]);

				t.compressedBitmap = atf;
				t.textureWidth = t.bitmapWidth = w;
				t.textureHeight = t.bitmapHeight = h;
				t.hasPremultipliedAlpha = false;
			}

			return t;
		}

		public static function textureFromSize(textureWidth:uint, textureHeight:uint):Texture2D {

			var size:Point = TextureHelper.getTextureDimensionsFromSize(textureWidth, textureHeight);
			var t:Texture2D = new Texture2D();
			t.textureWidth = size.x;
			t.textureHeight = size.y;
			t.bitmapWidth = size.x;
			t.bitmapHeight = size.y;

			return t;
		}

		public function getTexture(context:Context3D):Texture {
			if(!texture) {

				if(compressedBitmap) {
					texture = TextureHelper.generateTextureFromByteArray(context, compressedBitmap);
				} else if(bitmap) {
					var useMipMapping:Boolean = (_textureOptions & TextureOption.MIPMAP_LINEAR) + (_textureOptions & TextureOption.MIPMAP_NEAREST) > 0;
					texture = TextureHelper.generateTextureFromBitmap(context, bitmap, useMipMapping);
				} else {
					texture = context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
				}

				if(autoCleanUpResources) {
					if(bitmap) {
						bitmap.dispose();
						bitmap = null;
					}

					compressedBitmap = null;
				}
			}

			return texture;
		}

		public function dispose():void {
			if(texture) {
				texture.dispose();
				texture = null;
			}
		}
	}
}
