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
	import de.nulldesign.nd2d.utils.ColorUtil;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;

	public class Quad2DColorMaterial extends AMaterial {

		private const VERTEX_SHADER:String =
				"m44 op, va0, vc0   \n" + // vertex * clipspace
						"mov v0, va1		\n";  // copy color

		private const FRAGMENT_SHADER:String =
				"mov oc, v0		\n";  // mult with colorOffset

		public function Quad2DColorMaterial() {
			drawCalls = 1;
		}

		override protected function prepareForRender(context:Context3D):void {
			super.prepareForRender(context);

			clipSpaceMatrix.identity();
			clipSpaceMatrix.append(modelMatrix);
			clipSpaceMatrix.append(viewProjectionMatrix);

			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_4); // color
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);
		}

		override protected function clearAfterRender(context:Context3D):void {
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
		}

		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {
			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_COLOR, 4);
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {
				shaderData = ShaderCache.getInstance().getShader(context, this, VERTEX_SHADER, FRAGMENT_SHADER, 6, 0);
			}
		}

		public function modifyColorInBuffer(bufferIdx:uint, r:Number, g:Number, b:Number, a:Number):void {

			if(!mVertexBuffer || mVertexBuffer.length == 0) return;
			const idx:uint = bufferIdx * shaderData.numFloatsPerVertex;

			mVertexBuffer[idx + 2] = r;
			mVertexBuffer[idx + 3] = g;
			mVertexBuffer[idx + 4] = b;
			mVertexBuffer[idx + 5] = a;

			needUploadVertexBuffer = true;
		}
	}
}
