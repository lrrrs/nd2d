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

package de.nulldesign.nd2d.materials {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Sprite2DMaterial extends AMaterial {

		protected const VERTEX_SHADER:String = "m44 op, va0, vc0   \n" + // vertex * clipspace
				"mov vt0, va1  \n" + // save uv in temp register
				"mul vt0.xy, vt0.xy, vc4.zw   \n" + // mult with uv-scale
				"add vt0.xy, vt0.xy, vc4.xy   \n" + // add uv offset
				"mov v0, vt0 \n"; // copy uv

		protected const FRAGMENT_SHADER:String =
				"tex ft0, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>\n" + // sample texture from interpolated uv coords
						"mul ft0, ft0, fc0\n" + // mult with colorMultiplier
						"add oc, ft0, fc1\n"; // mult with colorOffset

		protected const FRAGMENT_SHADER_NO_TINT_ALPHA:String = "tex oc, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>\n";

		public var texture:Texture2D;
		public var spriteSheet:ASpriteSheetBase;
		public var colorTransform:ColorTransform;

		/**
		 * Use this property to animate a texture
		 */
		public var uvOffsetX:Number = 0.0;

		/**
		 * Use this property to animate a texture
		 */
		public var uvOffsetY:Number = 0.0;

		/**
		 * Use this property to repeat/scale a texture. Your texture has to be a power of two (256x128, etc)
		 */
		public var uvScaleX:Number = 1.0;

		/**
		 * Use this property to repeat/scale a texture. Your texture has to be a power of two (256x128, etc)
		 */
		public var uvScaleY:Number = 1.0;


		public function Sprite2DMaterial() {
			drawCalls = 1;
		}

		override protected function prepareForRender(context:Context3D):void {

			super.prepareForRender(context);

			var uvOffsetAndScale:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);
			var textureObj:Texture = texture.getTexture(context);

			if(spriteSheet) {

				uvOffsetAndScale = spriteSheet.getUVRectForFrame(texture.textureWidth, texture.textureHeight);

				var offset:Point = spriteSheet.getOffsetForFrame();

				clipSpaceMatrix.identity();
				clipSpaceMatrix.appendScale(spriteSheet.spriteWidth >> 1, spriteSheet.spriteHeight >> 1, 1.0);
				clipSpaceMatrix.appendTranslation(offset.x, offset.y, 0.0);
				clipSpaceMatrix.append(modelMatrix);
				clipSpaceMatrix.append(viewProjectionMatrix);

			} else {
				clipSpaceMatrix.identity();
				clipSpaceMatrix.appendScale(texture.textureWidth >> 1, texture.textureHeight >> 1, 1.0);
				clipSpaceMatrix.append(modelMatrix);
				clipSpaceMatrix.append(viewProjectionMatrix);
			}

			context.setTextureAt(0, textureObj);
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

			programConstVector[0] = uvOffsetAndScale.x + uvOffsetX;
			programConstVector[1] = uvOffsetAndScale.y + uvOffsetY;
			programConstVector[2] = uvOffsetAndScale.width * uvScaleX;
			programConstVector[3] = uvOffsetAndScale.height * uvScaleY;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, programConstVector);

			if(nodeTinted) {

				var offsetFactor:Number = 1.0 / 255.0;

				programConstVector[0] = colorTransform.redMultiplier;
				programConstVector[1] = colorTransform.greenMultiplier;
				programConstVector[2] = colorTransform.blueMultiplier;
				programConstVector[3] = colorTransform.alphaMultiplier;

				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, programConstVector);

				programConstVector[0] = colorTransform.redOffset * offsetFactor;
				programConstVector[1] = colorTransform.greenOffset * offsetFactor;
				programConstVector[2] = colorTransform.blueOffset * offsetFactor;
				programConstVector[3] = colorTransform.alphaOffset * offsetFactor;

				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, programConstVector);
			}
		}

		override protected function clearAfterRender(context:Context3D):void {
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
		}

		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {
				shaderData = ShaderCache.getInstance().getShader(context, this, VERTEX_SHADER, nodeTinted ? FRAGMENT_SHADER : FRAGMENT_SHADER_NO_TINT_ALPHA, 4, texture.textureOptions, nodeTinted ? 0 : 1000);
			}
		}

		public function modifyVertexInBuffer(bufferIdx:uint, x:Number, y:Number):void {

			if(!mVertexBuffer || mVertexBuffer.length == 0) return;
			const idx:uint = bufferIdx * shaderData.numFloatsPerVertex;

			mVertexBuffer[idx] = x;
			mVertexBuffer[idx + 1] = y;

			needUploadVertexBuffer = true;
		}
	}
}