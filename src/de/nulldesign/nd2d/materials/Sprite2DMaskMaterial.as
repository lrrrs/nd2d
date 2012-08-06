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
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Sprite2DMaskMaterial extends Sprite2DMaterial {

		protected const DEFAULT_VERTEX_SHADER:String = "m44 vt0, va0, vc0              \n" + // vertex(va0) * clipspace
				"m44 vt1, vt0, vc4              \n" + // clipsace to local pos in mask
				"add vt1.xy, vt1.xy, vc8.xy     \n" + // add half masksize to local pos
				"div vt1.xy, vt1.xy, vc8.zw     \n" + // local pos / masksize
				"mov vt2, va1                   \n" + // copy uv
				"mul vt2.xy, vt2.xy, vc9.zw     \n" + // mult with uv-scale
				"add vt2.xy, vt2.xy, vc9.xy     \n" + // add uv offset
				"mov v0, vt2                    \n" + // copy uv
				"mov v1, vt1                    \n" + // copy mask uv
				"mov op, vt0                    \n";  // output position


		protected const DEFAULT_FRAGMENT_SHADER:String =
				"tex ft0, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>  \n" + // sample texture
						"mul ft0, ft0, fc0                              \n" + // mult with colorMultiplier
						"add ft0, ft0, fc1                              \n" + // mult with colorOffset
						"tex ft1, v1, fs1 <2d,miplinear,linear,clamp>   \n" + // sample mask
						"sub ft2, fc2, ft1                              \n" + // (1 - maskcolor)
						"mov ft3, fc3                                   \n" + // save maskalpha
						"sub ft3, fc2, ft3                              \n" + // (1 - maskalpha)
						"mul ft3, ft2, ft3                              \n" + // (1 - maskcolor) * (1 - maskalpha)
						"add ft3, ft1, ft3                              \n" + // finalmaskcolor = maskcolor + (1 - maskcolor) * (1 - maskalpha));
						"mul oc, ft0, ft3                               \n"; // mult mask color with tex color and output it

		public var maskModelMatrix:Matrix3D;
		public var maskTexture:Texture2D;
		public var maskAlpha:Number;

		protected var maskDimensions:Point;
		protected var maskClipSpaceMatrix:Matrix3D = new Matrix3D();

		public function Sprite2DMaskMaterial() {
			super();
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			maskTexture.texture = null;
			shaderData = null;
		}

		override protected function prepareForRender(context:Context3D):void {

			super.prepareForRender(context);

			context.setTextureAt(0, texture.getTexture(context));
			context.setTextureAt(1, maskTexture.getTexture(context));
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv

			var uvOffsetAndScale:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);

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

			maskClipSpaceMatrix.identity();
			maskClipSpaceMatrix.append(maskModelMatrix);
			maskClipSpaceMatrix.append(viewProjectionMatrix);
			maskClipSpaceMatrix.invert();

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, maskClipSpaceMatrix, true);

			programConstVector[0] = maskTexture.textureWidth >> 1;
			programConstVector[1] = maskTexture.textureHeight >> 1;
			programConstVector[2] = maskTexture.textureWidth;
			programConstVector[3] = maskTexture.textureHeight;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, programConstVector);

			programConstVector[0] = uvOffsetAndScale.x;
			programConstVector[1] = uvOffsetAndScale.y;
			programConstVector[2] = uvOffsetAndScale.width;
			programConstVector[3] = uvOffsetAndScale.height;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 9, programConstVector);

			programConstVector[0] = colorTransform.redMultiplier;
			programConstVector[1] = colorTransform.greenMultiplier;
			programConstVector[2] = colorTransform.blueMultiplier;
			programConstVector[3] = colorTransform.alphaMultiplier;

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, programConstVector);

			var offsetFactor:Number = 1.0 / 255.0;
			programConstVector[0] = colorTransform.redOffset * offsetFactor;
			programConstVector[1] = colorTransform.greenOffset * offsetFactor;
			programConstVector[2] = colorTransform.blueOffset * offsetFactor;
			programConstVector[3] = colorTransform.alphaOffset * offsetFactor;

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, programConstVector);

			programConstVector[0] = 1.0;
			programConstVector[1] = 1.0;
			programConstVector[2] = 1.0;
			programConstVector[3] = 1.0;

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, programConstVector);

			programConstVector[0] = maskAlpha;
			programConstVector[1] = maskAlpha;
			programConstVector[2] = maskAlpha;
			programConstVector[3] = maskAlpha;

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, programConstVector);
		}

		override protected function clearAfterRender(context:Context3D):void {
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}

		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {
				shaderData = ShaderCache.getInstance().getShader(context, this, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER, 4, texture.textureOptions);
			}
		}

		override public function dispose():void 
		{
			if(maskTexture) {
				maskTexture.dispose();
				maskTexture = null;
			}
			
			super.dispose();
		}
	}
}
