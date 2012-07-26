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

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Sprite2DBatchMaterial extends Sprite2DMaterial {

		protected const DEFAULT_VERTEX_SHADER:String =
				"m44 op, va0, vc[va2.x]             \n" + // vertex * clipspace[idx]
						"mov vt0, va1                       \n" + // save uv in temp register
						"mul vt0.xy, vt0.xy, vc[va2.w].zw   \n" + // mult with uv-scale
						"add vt0.xy, vt0.xy, vc[va2.w].xy   \n" + // add uv offset
						"mov v0, vt0                        \n" + // copy uv
						"mov v1, vc[va2.y]	                \n" + // copy colorMultiplier[idx]
						"mov v2, vc[va2.z]	                \n"; // copy colorOffset[idx]

		/*
		 protected const DEFAULT_VERTEX_SHADER:String =
		 "m44 op, va0, vc[va2.x]     \n" + // vertex * clipspace[idx]
		 "add vt0, va1, vc[va2.z]    \n" + // add uvoffset[idx] to uv coords
		 "mov v0, vt0                \n" + // copy uv
		 "mov v1, vc[va2.y]	        \n"; // copy color[idx]
		 */

		protected const DEFAULT_FRAGMENT_SHADER:String =
				"tex ft0, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>  \n" + // sample texture from interpolated uv coords
						"mul ft0, ft0, v1                               \n" + // mult with colorMultiplier
						"add oc, ft0, v2                               \n"; // add with colorOffset

		protected var constantsPerSprite:uint = 7; // matrix, colorMultiplier, colorOffset, uvoffset
		protected var constantsPerMatrix:uint = 4;

		protected const BATCH_SIZE:uint = 126 / constantsPerSprite;
		protected var batchLen:uint = 0;

		protected var currentNodeIsTinted:Boolean = false;

		public static const VERTEX_IDX:String = "PB3D_IDX";

		public function Sprite2DBatchMaterial() {
			super();
		}

		override protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

			if(vertexBuffer) {
				return;
			}

			// use first two faces and extend facelist to max. batch size
			var f0:Face = faceList[0];
			var f1:Face = faceList[1];
			var newF0:Face;
			var newF1:Face;

			var newFaceList:Vector.<Face> = new Vector.<Face>(BATCH_SIZE * 2, true);

			for(var i:int = 0; i < BATCH_SIZE; i++) {
				newF0 = f0.clone();
				newF1 = f1.clone();

				newF0.idx = i;
				newF1.idx = i;

				newFaceList[i * 2] = newF0;
				newFaceList[i * 2 + 1] = newF1;
			}

			super.generateBufferData(context, newFaceList);
		}

		override public function render(context:Context3D, faceList:Vector.<Face>, startTri:uint, numTris:uint):void {
			throw new Error("please call renderBatch for this material");
		}

		override protected function prepareForRender(context:Context3D):void {

			context.setProgram(shaderData.shader);
			context.setBlendFactors(blendMode.src, blendMode.dst);
			context.setTextureAt(0, texture.getTexture(context));
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
			context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // idx
		}

		public function renderBatch(context:Context3D, faceList:Vector.<Face>, childList:Vector.<Node2D>):void {

			drawCalls = 0;
			numTris = 0;
			batchLen = 0;
			currentNodeIsTinted = nodeTinted;
			previousTintedState = currentNodeIsTinted;

			generateBufferData(context, faceList);
			prepareForRender(context);

			processAndRenderNodes(context, childList);

			if(batchLen != 0) {
				context.drawTriangles(indexBuffer, 0, batchLen * 2);
				++drawCalls;
			}

			clearAfterRender(context);
		}

		protected function setupShader(context:Context3D):void {
			shaderData = null;
			initProgram(context);
			context.setProgram(shaderData.shader);
		}

		protected function drawCurrentBatch(context:Context3D):void {
			context.drawTriangles(indexBuffer, 0, batchLen * 2);
			batchLen = 0;
			++drawCalls;
		}

		protected function processAndRenderNodes(context:Context3D, childList:Vector.<Node2D>):void {

			if(!childList || childList.length == 0) return;

			var childNode:Node2D;
			var child:Sprite2D;
			const colorMultiplierAndOffset:Vector.<Number> = new Vector.<Number>(8, true);
			const uvoffset:Vector.<Number> = new Vector.<Number>(4, true);
			var i:int = -1;
			const n:int = childList.length;
			const offsetFactor:Number = 1.0 / 255.0;
			currentNodeIsTinted = nodeTinted || childList[0].nodeIsTinted;

			while(++i < n) {

				childNode = childList[i];
				child = childNode as Sprite2D;

				if(child && child.visible) {

					if(child.invalidateColors) child.updateColors();
					if(child.invalidateMatrix) child.updateLocalMatrix();

					child.updateWorldMatrix();

					currentNodeIsTinted = nodeTinted || child.nodeIsTinted;

					if(currentNodeIsTinted != previousTintedState) {
						drawCurrentBatch(context);
						setupShader(context);
					}

					var uvOffsetAndScale:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);

					if(spriteSheet) {

						uvOffsetAndScale = child.spriteSheet.getUVRectForFrame(texture.textureWidth, texture.textureHeight);

						var offset:Point = child.spriteSheet.getOffsetForFrame();

						clipSpaceMatrix.identity();
						clipSpaceMatrix.appendScale(child.spriteSheet.spriteWidth >> 1, child.spriteSheet.spriteHeight >> 1, 1.0);
						clipSpaceMatrix.appendTranslation(offset.x, offset.y, 0.0);
						clipSpaceMatrix.append(child.worldModelMatrix);
						clipSpaceMatrix.append(viewProjectionMatrix);

					} else {
						clipSpaceMatrix.identity();
						clipSpaceMatrix.appendScale(texture.textureWidth >> 1, texture.textureHeight >> 1, 1.0);
						clipSpaceMatrix.append(child.worldModelMatrix);
						clipSpaceMatrix.append(viewProjectionMatrix);
					}

					colorMultiplierAndOffset[0] = child.combinedColorTransform.redMultiplier;
					colorMultiplierAndOffset[1] = child.combinedColorTransform.greenMultiplier;
					colorMultiplierAndOffset[2] = child.combinedColorTransform.blueMultiplier;
					colorMultiplierAndOffset[3] = child.combinedColorTransform.alphaMultiplier;
					colorMultiplierAndOffset[4] = child.combinedColorTransform.redOffset * offsetFactor;
					colorMultiplierAndOffset[5] = child.combinedColorTransform.greenOffset * offsetFactor;
					colorMultiplierAndOffset[6] = child.combinedColorTransform.blueOffset * offsetFactor;
					colorMultiplierAndOffset[7] = child.combinedColorTransform.alphaOffset * offsetFactor;

					uvoffset[0] = uvOffsetAndScale.x;
					uvoffset[1] = uvOffsetAndScale.y;
					uvoffset[2] = uvOffsetAndScale.width;
					uvoffset[3] = uvOffsetAndScale.height;

					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,
							batchLen * constantsPerSprite, clipSpaceMatrix, true);

					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
							batchLen * constantsPerSprite + constantsPerMatrix,
							colorMultiplierAndOffset);

					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
							batchLen * constantsPerSprite + constantsPerMatrix + 2,
							uvoffset);

					++batchLen;

					numTris += 2;

					if(batchLen == BATCH_SIZE) {
						drawCurrentBatch(context);
					}

					processAndRenderNodes(context, child.children);

				} else if(childNode.visible) {

					// let's try to process the childs...

					if(childNode.invalidateColors) childNode.updateColors();
					if(childNode.invalidateMatrix) childNode.updateLocalMatrix();

					// TODO check if parent matrix changed?
					childNode.updateWorldMatrix();

					processAndRenderNodes(context, childNode.children);
				}

				previousTintedState = currentNodeIsTinted;
			}
		}

		override protected function clearAfterRender(context:Context3D):void {
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {
				shaderData = ShaderCache.getInstance().getShader(context, this, DEFAULT_VERTEX_SHADER, currentNodeIsTinted ? DEFAULT_FRAGMENT_SHADER : FRAGMENT_SHADER_NO_TINT_ALPHA, 8, texture.textureOptions, currentNodeIsTinted ? 0 : 1000);
			}
		}

		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_IDX, 4);
		}

		override protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String, floatFormat:int):void {

			if(semanticsID == VERTEX_IDX) {
				// first float will be used for matrix index
				buffer.push(face.idx * constantsPerSprite);
				// second, colorMultiplier idx
				buffer.push(face.idx * constantsPerSprite + constantsPerMatrix);
				// second, colorOffset idx
				buffer.push(face.idx * constantsPerSprite + constantsPerMatrix + 1);
				// third uv offset idx
				buffer.push(face.idx * constantsPerSprite + constantsPerMatrix + 2);

			} else {
				super.fillBuffer(buffer, v, uv, face, semanticsID, floatFormat);
			}
		}

		override public function dispose():void 
		{
			super.dispose();
		}
	}
}
