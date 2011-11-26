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

package de.nulldesign.nd2d.utils {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class TextureHelper {
		public function TextureHelper() {
		}

		/**
		 * Will return a point that contains the width and height of the smallest possible texture size in 2^n
		 * @param w width
		 * @param h height
		 * @return x = width, y = height of the texture
		 */
		public static function getTextureDimensionsFromSize(w:Number, h:Number):Point {
			var textureWidth:Number = 2.0;
			var textureHeight:Number = 2.0;

			while(textureWidth < w) {
				textureWidth <<= 1;
			}

			while(textureHeight < h) {
				textureHeight <<= 1;
			}

			return new Point(textureWidth, textureHeight);
		}

		/**
		 * Will return a point that contains the width and height of the smallest possible texture size in 2^n
		 * @param bmp
		 * @return x = width, y = height of the texture
		 */
		public static function getTextureDimensionsFromBitmap(bmp:BitmapData):Point {
			return getTextureDimensionsFromSize(bmp.width, bmp.height);
		}

		/**
		 * Generates a texture from a bitmap. Will use the smallest possible size (2^n)
		 * @param context
		 * @param bmp
		 * @return The generated texture
		 */
		public static function generateTextureFromByteArray(context:Context3D, atf:ByteArray):Texture {

			var w:int = Math.pow(2, atf[7]);
			var h:int = Math.pow(2, atf[8]);
			//var numTextures:int = atf[9];
			var textureFormat:String = (atf[6] == 2 ? Context3DTextureFormat.COMPRESSED : Context3DTextureFormat.BGRA);

			var texture:Texture = context.createTexture(w, h, textureFormat, false);
			texture.uploadCompressedTextureFromByteArray(atf, 0, false);

			return texture;
		}

		/**
		 * Generates a texture from a bitmap. Will use the smallest possible size (2^n)
		 * @param context
		 * @param bmp
		 * @return The generated texture
		 */
		public static function generateTextureFromBitmap(context:Context3D, bmp:BitmapData, useMipMaps:Boolean):Texture {

			var textureDimensions:Point = getTextureDimensionsFromBitmap(bmp);

			var newBmp:BitmapData = new BitmapData(textureDimensions.x, textureDimensions.y, true, 0x00000000);

			var sourceRect:Rectangle;
			var destPoint:Point;

			sourceRect = new Rectangle(0, 0, bmp.width, bmp.height);
			destPoint = new Point(textureDimensions.x * 0.5 - bmp.width * 0.5, textureDimensions.y * 0.5 - bmp.height * 0.5);

			newBmp.copyPixels(bmp, sourceRect, destPoint);

			var texture:Texture = context.createTexture(textureDimensions.x, textureDimensions.y, Context3DTextureFormat.BGRA, false);

			if(useMipMaps) {
				uploadTextureWithMipmaps(texture, newBmp);
			} else {
				texture.uploadFromBitmapData(newBmp);
				//texture.uploadFromByteArray(data, 0);
			}

			return texture;
		}

		public static function uploadTextureWithMipmaps(dest:Texture, src:BitmapData):void {
			var ws:int = src.width;
			var hs:int = src.height;
			var level:int = 0;
			var tmp:BitmapData = new BitmapData(src.width, src.height, true, 0x00000000);
			var transform:Matrix = new Matrix();

			while(ws >= 1 || hs >= 1) {

				tmp.fillRect(tmp.rect, 0x00000000);
				tmp.draw(src, transform, null, null, null, true);

				dest.uploadFromBitmapData(tmp, level);

				//dest.uploadFromByteArray(data, 0, mip);

				transform.scale(0.5, 0.5);
				level++;
				ws >>= 1;
				hs >>= 1;
			}

			tmp.dispose();
		}

		public static function generateQuadFromDimensions(width:Number, height:Number):Vector.<Face> {
			var faceList:Vector.<Face> = new Vector.<Face>(2, true);

			var texW:Number = width * 0.5;
			var texH:Number = height * 0.5;
			var uv1:UV;
			var uv2:UV;
			var uv3:UV;
			var uv4:UV;
			var v1:Vertex;
			var v2:Vertex;
			var v3:Vertex;
			var v4:Vertex;

			uv1 = new UV(0, 0);
			uv2 = new UV(1, 0);
			uv3 = new UV(1, 1);
			uv4 = new UV(0, 1);

			v1 = new Vertex(-texW, -texH, 0.0);
			v2 = new Vertex(texW, -texH, 0.0);
			v3 = new Vertex(texW, texH, 0.0);
			v4 = new Vertex(-texW, texH, 0.0);

			faceList[0] = new Face(v1, v2, v3, uv1, uv2, uv3);
			faceList[1] = new Face(v1, v3, v4, uv1, uv3, uv4);

			return faceList;
		}
	}
}
