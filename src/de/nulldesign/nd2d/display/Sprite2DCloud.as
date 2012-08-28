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

package de.nulldesign.nd2d.display {

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.Shader2D;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.StatsObject;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import de.nulldesign.nd2d.utils.VectorUtil;

	/**
	 * Sprite2DCloud
	 * <p>Use a sprite cloud to batch sprites with the same Texture, SpriteSheet or TextureAtlas. The SpriteSheet or TextureAtlas is cloned and passed to each child.
	 * So you can control each child individually.
	 * All sprites will be rendered in one single draw call. It uses more CPU resources, than the Sprite2DBatch, but can be a lot faster on slow GPU machines.</p>
	 *
	 * Limitations:
	 * <ul>
	 * <li>Mouseevents are disabled and won't work for childs</li>
	 * <li>Reordering childs (add, remove) is very expensive. Try to avoid it! A Sprite2DBatch might work better in this case</li>
	 * <li>Subchilds are not rendered. The cloud will only render it's own childs, you can't nest nodes deeper with a cloud.</li>
	 * <li>rotationX,Y won't work for Sprite2DCloud childs</li>
	 * </ul>
	 *
	 * <p>If you have a SpriteSheet or TextureAtlas for your batch, make sure to add animations BEFORE you add any childs to the batch, because the SpriteSheet/TextureAtlas get's cloned and is copied to each added child</p>
	 */
	public class Sprite2DCloud extends Node2D {

		protected var faceList:Vector.<Face>;
		protected var spriteSheet:ASpriteSheetBase;
		protected var texture:Texture2D;

		protected var v1:Vertex;
		protected var v2:Vertex;
		protected var v3:Vertex;
		protected var v4:Vertex;

		protected var uv1:UV;
		protected var uv2:UV;
		protected var uv3:UV;
		protected var uv4:UV;

		protected const numFloatsPerVertex:uint = 12;

		protected const DEFAULT_VERTEX_SHADER:String =
				"m44 op, va0, vc0   \n" + // vertex * clipspace
						"mov v0, va1		\n" + // copy uv
						"mov v1, va2		\n" + // copy colorMultiplier
						"mov v2, va3		\n"; // copy colorOffset

		protected const DEFAULT_FRAGMENT_SHADER:String =
				"tex ft0, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>\n" + // sample texture from interpolated uv coords
						"mul ft0, ft0, v1\n" + // mult with colorMultiplier
						"add oc, ft0, v2\n";  // add with colorOffset

		protected const FRAGMENT_SHADER_SHORT:String = "tex oc, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>\n";

		protected var shaderData:Shader2D;
		protected var indexBuffer:IndexBuffer3D;
		protected var vertexBuffer:VertexBuffer3D;
		protected var mVertexBuffer:Vector.<Number>;
		protected var mIndexBuffer:Vector.<uint>;
		protected var uvInited:Boolean = false;
		protected var maxCapacity:uint;
		protected var isInvalidatedColors:Boolean = false;

		protected var clipSpaceMatrix:Matrix3D = new Matrix3D();

		public function Sprite2DCloud(maxCapacity:uint, textureObject:Texture2D) {

			texture = textureObject;
			faceList = TextureHelper.generateQuadFromDimensions(2, 2);

			v1 = faceList[0].v1;
			v2 = faceList[0].v2;
			v3 = faceList[0].v3;
			v4 = faceList[1].v3;

			uv1 = faceList[0].uv1;
			uv2 = faceList[0].uv2;
			uv3 = faceList[0].uv3;
			uv4 = faceList[1].uv3;

			this.maxCapacity = maxCapacity;

			mVertexBuffer = new Vector.<Number>(maxCapacity * numFloatsPerVertex * 4, true);
			mIndexBuffer = new Vector.<uint>(maxCapacity * 6, true);
		}

		public function setSpriteSheet(value:ASpriteSheetBase):void {
			this.spriteSheet = value;
		}

		override public function get numTris():uint {
			return children.length * 2;
		}

		override public function get drawCalls():uint {
			return 1;
		}

		override public function addChildAt(child:Node2D, idx:uint):Node2D {

			if(child is Sprite2DCloud) {
				throw new Error("You can't nest Sprite2DClouds");
			}

			if(children.length < maxCapacity || getChildIndex(child) != -1) {

				super.addChildAt(child, idx);

				var c:Sprite2D = child as Sprite2D;

				// distribute spritesheets to sprites
				if(spriteSheet && !c.spriteSheet) {
					c.setSpriteSheet(spriteSheet.clone());
				}

				if(texture && !c.texture) {
					c.setTexture(texture);
				}

				for(var i:int = 0; i < children.length; i++) {
					c = children[i] as Sprite2D;
					c.invalidateColors = true;
					c.invalidateMatrix = true;
				}
				uvInited = false;

				return child;
			}

			return null;
		}

		override public function removeChildAt(idx:uint):void {

			if(idx < children.length) {
				super.removeChildAt(idx);

				var c:Sprite2D;
				for(var i:int = 0; i < children.length; i++) {
					c = children[i] as Sprite2D;
					c.invalidateColors = true;
					c.invalidateMatrix = true;
				}

				uvInited = false;
			}
		}

		override public function swapChildren(child1:Node2D, child2:Node2D):void {
			super.swapChildren(child1, child2);
			child1.invalidateColors = true;
			child1.invalidateMatrix = true;
			if(Sprite2D(child1).spriteSheet) {
				Sprite2D(child1).spriteSheet.frameUpdated = true;
			}

			child2.invalidateColors = true;
			child2.invalidateMatrix = true;
			if(Sprite2D(child2).spriteSheet) {
				Sprite2D(child2).spriteSheet.frameUpdated = true;
			}
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();

			texture.texture = null;
			shaderData = null;
			vertexBuffer = null;
			indexBuffer = null;
			uvInited = false;

			for each(var c:Sprite2D in children)
				c.invalidateColors = c.invalidateMatrix = true;
		}

		override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

			if(!visible) {
				return;
			}

			var myMatrixChanged:Boolean = false;

			if(invalidateMatrix) {
				updateLocalMatrix();
				myMatrixChanged = true;
			}

			if(parentMatrixChanged || myMatrixChanged) {
				updateWorldMatrix();
			}

			draw(context, camera);
			statsObject.totalDrawCalls += drawCalls;
			statsObject.totalTris += numTris;
		}

		override public function updateColors() : void {
			super.updateColors();
			isInvalidatedColors = true;
		}

		override protected function draw(context:Context3D, camera:Camera2D):void {

			if(children.length == 0) return;
			
			clipSpaceMatrix.identity();
			clipSpaceMatrix.append(worldModelMatrix);
			clipSpaceMatrix.append(camera.getViewProjectionMatrix(false));

			if(!shaderData) {
				shaderData = ShaderCache.getInstance().getShader(context, this, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER, numFloatsPerVertex, texture.textureOptions);
			}

			var vIdx:uint = 0;
			var rMultiplier:Number;
			var gMultiplier:Number;
			var bMultiplier:Number;
			var aMultiplier:Number;
			var rOffset:Number;
			var gOffset:Number;
			var bOffset:Number;
			var aOffset:Number;
			var uvOffsetAndScale:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);
			var rot:Number;
			var cr:Number;
			var sr:Number;
			var i:int = -1;
			var child:Sprite2D;
			const n:uint = children.length;
			var sx:Number;
			var sy:Number;
			var pivotX: Number, pivotY: Number;
			var offsetX: Number,  offsetY: Number;
			var somethingChanged:Boolean = false;
			var atlasOffset:Point = new Point();
			const offsetFactor:Number = 1.0 / 255.0;
			var isChildInvalidatedColors : Boolean = false;
			const halfTextureWidth : Number = texture.textureWidth >> 1;
			const halfTextureHeight : Number = texture.textureHeight >> 1;

    		if(invalidateColors) {
				updateColors();
				isInvalidatedColors = true;
			}

			while(++i < n) {

				child = Sprite2D(children[i]);

				spriteSheet = child.spriteSheet;

				isChildInvalidatedColors = false;
				if(child.invalidateColors && !isInvalidatedColors) {
					child.updateColors();
					isChildInvalidatedColors = true;
				}

				if(child.visible) {
					rMultiplier = child.combinedColorTransform.redMultiplier;
					gMultiplier = child.combinedColorTransform.greenMultiplier;
					bMultiplier = child.combinedColorTransform.blueMultiplier;
					aMultiplier = child.combinedColorTransform.alphaMultiplier;
					rOffset = child.combinedColorTransform.redOffset * offsetFactor;
					gOffset = child.combinedColorTransform.greenOffset * offsetFactor;
					bOffset = child.combinedColorTransform.blueOffset * offsetFactor;
					aOffset = child.combinedColorTransform.alphaOffset * offsetFactor;
				} else {
					// fake visibility, it's faster
					rMultiplier = 0.0;
					gMultiplier = 0.0;
					bMultiplier = 0.0;
					aMultiplier = 0.0;
					rOffset = 0.0;
					gOffset = 0.0;
					bOffset = 0.0;
					aOffset = 0.0;
				}

				var initUV:Boolean = !uvInited;

				if(spriteSheet && (initUV || spriteSheet.frameUpdated)) {
					spriteSheet.frameUpdated = false;
					uvOffsetAndScale = spriteSheet.getUVRectForFrame(texture.textureWidth, texture.textureHeight);
					
					initUV = true;
				}

				if(initUV) {
					// v1
					mVertexBuffer[vIdx + 2] = uvOffsetAndScale.width * uv1.u + uvOffsetAndScale.x;
					mVertexBuffer[vIdx + 3] = uvOffsetAndScale.height * uv1.v + uvOffsetAndScale.y;

					// v2
					mVertexBuffer[vIdx + 14] = uvOffsetAndScale.width * uv2.u + uvOffsetAndScale.x;
					mVertexBuffer[vIdx + 15] = uvOffsetAndScale.height * uv2.v + uvOffsetAndScale.y;

					// v3
					mVertexBuffer[vIdx + 26] = uvOffsetAndScale.width * uv3.u + uvOffsetAndScale.x;
					mVertexBuffer[vIdx + 27] = uvOffsetAndScale.height * uv3.v + uvOffsetAndScale.y;

					// v4
					mVertexBuffer[vIdx + 38] = uvOffsetAndScale.width * uv4.u + uvOffsetAndScale.x;
					mVertexBuffer[vIdx + 39] = uvOffsetAndScale.height * uv4.v + uvOffsetAndScale.y;

					somethingChanged = true;
				}

				if(child.invalidateMatrix) {
					if(spriteSheet) {
						sx = child.scaleX * (spriteSheet.spriteWidth >> 1);
						sy = child.scaleY * (spriteSheet.spriteHeight >> 1);
						atlasOffset = spriteSheet.getOffsetForFrame();
					} else {
						sx = child.scaleX * halfTextureWidth;
						sy = child.scaleY * halfTextureHeight;
						atlasOffset.x = 0.0;
						atlasOffset.y = 0.0;
					}

					rot = VectorUtil.deg2rad(child.rotation);
					cr = Math.cos(rot);
					sr = Math.sin(rot);

					pivotX = child.pivot.x;
					pivotY = child.pivot.y;

					offsetX = child.x + atlasOffset.x;
					offsetY = child.y + atlasOffset.y;

					// v1
					mVertexBuffer[vIdx] = (v1.x * sx - pivotX) * cr - (v1.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 1] = (v1.x * sx - pivotX) * sr + (v1.y * sy - pivotY) * cr + offsetY;

					// v2
					mVertexBuffer[vIdx + 12] = (v2.x * sx - pivotX) * cr - (v2.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 13] = (v2.x * sx - pivotX) * sr + (v2.y * sy - pivotY) * cr + offsetY;

					// v3
					mVertexBuffer[vIdx + 24] = (v3.x * sx - pivotX) * cr - (v3.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 25] = (v3.x * sx - pivotX) * sr + (v3.y * sy - pivotY) * cr + offsetY;

					// v4
					mVertexBuffer[vIdx + 36] = (v4.x * sx - pivotX) * cr - (v4.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 37] = (v4.x * sx - pivotX) * sr + (v4.y * sy - pivotY) * cr + offsetY;

					somethingChanged = true;
				}

				if(isInvalidatedColors || isChildInvalidatedColors || child.invalidateVisibility) {

					// v1
					mVertexBuffer[vIdx + 4] = rMultiplier;
					mVertexBuffer[vIdx + 5] = gMultiplier;
					mVertexBuffer[vIdx + 6] = bMultiplier;
					mVertexBuffer[vIdx + 7] = aMultiplier;
					mVertexBuffer[vIdx + 8] = rOffset;
					mVertexBuffer[vIdx + 9] = gOffset;
					mVertexBuffer[vIdx + 10] = bOffset;
					mVertexBuffer[vIdx + 11] = aOffset;

					// v2
					mVertexBuffer[vIdx + 16] = rMultiplier;
					mVertexBuffer[vIdx + 17] = gMultiplier;
					mVertexBuffer[vIdx + 18] = bMultiplier;
					mVertexBuffer[vIdx + 19] = aMultiplier;
					mVertexBuffer[vIdx + 20] = rOffset;
					mVertexBuffer[vIdx + 21] = gOffset;
					mVertexBuffer[vIdx + 22] = bOffset;
					mVertexBuffer[vIdx + 23] = aOffset;

					// v3
					mVertexBuffer[vIdx + 28] = rMultiplier;
					mVertexBuffer[vIdx + 29] = gMultiplier;
					mVertexBuffer[vIdx + 30] = bMultiplier;
					mVertexBuffer[vIdx + 31] = aMultiplier;
					mVertexBuffer[vIdx + 32] = rOffset;
					mVertexBuffer[vIdx + 33] = gOffset;
					mVertexBuffer[vIdx + 34] = bOffset;
					mVertexBuffer[vIdx + 35] = aOffset;

					// v4
					mVertexBuffer[vIdx + 40] = rMultiplier;
					mVertexBuffer[vIdx + 41] = gMultiplier;
					mVertexBuffer[vIdx + 42] = bMultiplier;
					mVertexBuffer[vIdx + 43] = aMultiplier;
					mVertexBuffer[vIdx + 44] = rOffset;
					mVertexBuffer[vIdx + 45] = gOffset;
					mVertexBuffer[vIdx + 46] = bOffset;
					mVertexBuffer[vIdx + 47] = aOffset;

					somethingChanged = true;
				}

				vIdx += 48;

				child.invalidateMatrix = child.invalidateVisibility = false;
			}

			uvInited = true;
			isInvalidatedColors = false;

			if(!vertexBuffer) {
				vertexBuffer = context.createVertexBuffer(mVertexBuffer.length / numFloatsPerVertex, numFloatsPerVertex);
			}

			// reupload changed vertexbuffer...
			if(somethingChanged) {
				vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / numFloatsPerVertex);
			}

			if(!indexBuffer) {

				var refIdx:uint = 0;
				var iIdx:uint = 0;
				var idx:int = -1;

				while(++idx < maxCapacity) {
					mIndexBuffer[iIdx] = refIdx;
					mIndexBuffer[iIdx + 1] = refIdx + 1;
					mIndexBuffer[iIdx + 2] = refIdx + 2;
					mIndexBuffer[iIdx + 3] = refIdx + 2;
					mIndexBuffer[iIdx + 4] = refIdx + 3;
					mIndexBuffer[iIdx + 5] = refIdx;

					refIdx += 4;
					iIdx += 6;
				}

				indexBuffer = context.createIndexBuffer(mIndexBuffer.length);
				indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer.length);
			}

			context.setTextureAt(0, texture.getTexture(context));
			context.setProgram(shaderData.shader);
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
			context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // colorMultiplier
			context.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4); // colorOffset

			context.setBlendFactors(blendMode.src, blendMode.dst);

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

			context.drawTriangles(indexBuffer, 0, 2 * children.length);

			context.setTextureAt(0, null);

			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
			context.setVertexBufferAt(3, null);
		}
		
		override public function dispose():void
		{
			if (shaderData)
				shaderData = null;
			
			if(indexBuffer)
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}
			
			if(vertexBuffer)
			{
				vertexBuffer.dispose();
				vertexBuffer = null;
			}

			super.dispose();
		}
	}
}