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
	import de.nulldesign.nd2d.materials.shader.Shader2D;
	import de.nulldesign.nd2d.utils.NodeBlendMode;

	import flash.display.Shader;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;

	public class AMaterial {

		// cameras view projectionmatrix
		public var viewProjectionMatrix:Matrix3D;

		// models modelmatrix
		public var modelMatrix:Matrix3D;

		public var clipSpaceMatrix:Matrix3D = new Matrix3D();

		public var numTris:int = 0;
		public var drawCalls:int = 0;

		public var blendMode:NodeBlendMode = BlendModePresets.NORMAL_PREMULTIPLIED_ALPHA;

		public var needUploadVertexBuffer:Boolean = false;

		protected var indexBuffer:IndexBuffer3D;
		protected var vertexBuffer:VertexBuffer3D;

		protected var mIndexBuffer:Vector.<uint>;
		protected var mVertexBuffer:Vector.<Number>;

		protected var shaderData:Shader2D;
		protected var programConstVector:Vector.<Number> = new Vector.<Number>(4);

		public var nodeTinted:Boolean = false;
		protected var previousTintedState:Boolean = false;

		public static const VERTEX_POSITION:String = "PB3D_POSITION";
		public static const VERTEX_UV:String = "PB3D_UV";
		public static const VERTEX_COLOR:String = "PB3D_COLOR";

		public function AMaterial() {

		}

		protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

			if(vertexBuffer) {
				return;
			}

			initProgram(context);

			var i:int;
			const numFaces:int = faceList.length;
			var numIndices:int;

			mIndexBuffer = new Vector.<uint>();
			mVertexBuffer = new Vector.<Number>();

			var duplicateCheck:Dictionary = new Dictionary();
			var tmpUID:String;
			var indexBufferIdx:uint = 0;
			var face:Face;

			// generate index + vertexbuffer
			// integrated check if the vertex / uv combination is already in the buffer and skip these vertices
			for(i = 0; i < numFaces; i++) {

				face = faceList[i];

				tmpUID = face.v1.uid + "." + face.uv1.uid;

				if(duplicateCheck[tmpUID] == undefined) {
					addVertex(context, mVertexBuffer, face.v1, face.uv1, face);
					duplicateCheck[tmpUID] = indexBufferIdx;
					mIndexBuffer.push(indexBufferIdx);
					face.v1.bufferIdx = indexBufferIdx;
					++indexBufferIdx;
				} else {
					mIndexBuffer.push(duplicateCheck[tmpUID]);
				}

				tmpUID = face.v2.uid + "." + face.uv2.uid;

				if(duplicateCheck[tmpUID] == undefined) {
					addVertex(context, mVertexBuffer, face.v2, face.uv2, face);
					duplicateCheck[tmpUID] = indexBufferIdx;
					mIndexBuffer.push(indexBufferIdx);
					face.v2.bufferIdx = indexBufferIdx;
					++indexBufferIdx;
				} else {
					mIndexBuffer.push(duplicateCheck[tmpUID]);
				}

				tmpUID = face.v3.uid + "." + face.uv3.uid;

				if(duplicateCheck[tmpUID] == undefined) {
					addVertex(context, mVertexBuffer, face.v3, face.uv3, face);
					duplicateCheck[tmpUID] = indexBufferIdx;
					mIndexBuffer.push(indexBufferIdx);
					face.v3.bufferIdx = indexBufferIdx;
					++indexBufferIdx;
				} else {
					mIndexBuffer.push(duplicateCheck[tmpUID]);
				}
			}

			duplicateCheck = null;
			numIndices = mVertexBuffer.length / shaderData.numFloatsPerVertex;

			// GENERATE BUFFERS
			vertexBuffer = context.createVertexBuffer(numIndices, shaderData.numFloatsPerVertex);
			vertexBuffer.uploadFromVector(mVertexBuffer, 0, numIndices);

			if(!indexBuffer) {

				const mIndexBuffer_length:int = mIndexBuffer.length;
				indexBuffer = context.createIndexBuffer(mIndexBuffer_length);
				indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer_length);

				numTris = int(mIndexBuffer_length / 3);
			}
		}

		protected function prepareForRender(context:Context3D):void {

			if(previousTintedState != nodeTinted) {
				shaderData = null;
				initProgram(context);
				previousTintedState = nodeTinted;
			}

			context.setProgram(shaderData.shader);
			context.setBlendFactors(blendMode.src, blendMode.dst);

			if(needUploadVertexBuffer) {
				needUploadVertexBuffer = false;
				vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / shaderData.numFloatsPerVertex);
			}
		}

		public function handleDeviceLoss():void {
			indexBuffer = null;
			vertexBuffer = null;
			mIndexBuffer = null;
			mVertexBuffer = null;
			shaderData = null;
			needUploadVertexBuffer = true;
		}

		public function render(context:Context3D, faceList:Vector.<Face>, startTri:uint, numTris:uint):void {
			generateBufferData(context, faceList);
			prepareForRender(context);
			context.drawTriangles(indexBuffer, startTri * 3, numTris);
			clearAfterRender(context);
		}

		protected function clearAfterRender(context:Context3D):void {
			// implement in concrete material
			throw new Error("You have to implement clearAfterRender for your material");
		}

		protected function initProgram(context:Context3D):void {
			// implement in concrete material
			throw new Error("You have to implement initProgram for your material");
		}

		protected function refreshClipspaceMatrix():Matrix3D {
			clipSpaceMatrix.identity();
			clipSpaceMatrix.append(modelMatrix);
			clipSpaceMatrix.append(viewProjectionMatrix);
			return clipSpaceMatrix;
		}

		protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {
			// implement in concrete material
			throw new Error("You have to implement addVertex for your material");
		}

		protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String, floatFormat:int):void {

			if(semanticsID == VERTEX_POSITION) {

				buffer.push(v.x, v.y);

				if(floatFormat >= 3)
					buffer.push(v.z);

				if(floatFormat == 4)
					buffer.push(v.w);
			}

			if(semanticsID == VERTEX_UV) {

				buffer.push(uv.u, uv.v);

				if(floatFormat == 3)
					buffer.push(0.0);

				if(floatFormat == 4)
					buffer.push(0.0, 0.0);
			}

			if(semanticsID == VERTEX_COLOR) {
				buffer.push(v.r, v.g, v.b);

				if(floatFormat == 4)
					buffer.push(v.a);
			}
		}

		public function dispose():void 
		{
			if(indexBuffer) {
				indexBuffer.dispose();
				indexBuffer = null;
			}
			if(vertexBuffer) {
				vertexBuffer.dispose();
				vertexBuffer = null;
			}
			if(shaderData) {
				shaderData = null;
			}
		}
	}
}
