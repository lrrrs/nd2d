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

	import com.adobe.utils.AGALMiniAssembler;

	import de.nulldesign.nd2d.display.Camera2D;

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.Shader2D;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;

	import flash.display.Shader;
	import flash.display.Stage;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * http://www.gamerendering.com/2008/10/11/gaussian-blur-filter-shader/
	 */
	public class Sprite2DBlurMaterial extends Sprite2DMaterial {

		protected const HORIZONTAL_FRAGMENT_SHADER:String =
			// -4
				"mov ft0, v0								\n" +
						"sub ft0.x, ft0.x, fc3.y					\n" +
						"tex ft1, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft1, ft1, fc2.x						\n" +

					// -3
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.y						\n" +
						"add ft1, ft1, ft2							\n" +

					// -2
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.z						\n" +
						"add ft1, ft1, ft2							\n" +

					// -1
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.w						\n" +
						"add ft1, ft1, ft2							\n" +

					// 0
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc3.x						\n" +
						"add ft1, ft1, ft2							\n" +

					// 1
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.w						\n" +
						"add ft1, ft1, ft2							\n" +

					// 2
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.z						\n" +
						"add ft1, ft1, ft2							\n" +

					// 3
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.y						\n" +
						"add ft1, ft1, ft2							\n" +

					// 4
						"add ft0.x, ft0.x, fc3.z					\n" +
						"tex ft2, ft0, fs0 <TEXTURE_SAMPLING_OPTIONS>		\n" +
						"mul ft2, ft2, fc2.x						\n" +
						"add ft1, ft1, ft2							\n" +

						"mul ft1, ft1, fc0							\n" +
						"add oc, ft1, fc1							\n";

		protected var VERTICAL_FRAGMENT_SHADER:String;

		protected var horizontalShader:Shader2D;
		protected var verticalShader:Shader2D;

		protected const MAX_BLUR:uint = 4;

		protected var blurredTexture:Texture;
		protected var blurredTexture2:Texture;
		protected var blurredTextureCam:Camera2D = new Camera2D(1, 1);
		protected var activeRenderToTexture:Texture;

		protected var blurX:uint;
		protected var blurY:uint;

		protected const BLUR_DIRECTION_HORIZONTAL:uint = 0;
		protected const BLUR_DIRECTION_VERTICAL:uint = 1;

		protected var fragmentData:Vector.<Number>;

		public function Sprite2DBlurMaterial(blurX:uint = 4, blurY:uint = 4) {

			super();

			VERTICAL_FRAGMENT_SHADER = HORIZONTAL_FRAGMENT_SHADER.replace("sub ft0.x, ft0.x, fc3.y", "sub ft0.y, ft0.y, fc3.y");
			var reg:RegExp = /add ft0.x, ft0.x, fc3.z/g;
			VERTICAL_FRAGMENT_SHADER = VERTICAL_FRAGMENT_SHADER.replace(reg, "add ft0.y, ft0.y, fc3.z");

			fragmentData = new Vector.<Number>(8, true);
			setBlur(blurX, blurY);
		}

		public function setBlur(blurX:uint = 4, blurY:uint = 4):void {
			this.blurX = blurX;
			this.blurY = blurY;

			drawCalls = Math.max(1, Math.ceil(blurX / MAX_BLUR) + Math.ceil(blurY / MAX_BLUR));
		}

		protected function updateBlurKernel(radius:uint, direction:uint):void {

			fragmentData[0] = 0.0; //0.05; // fc2.x
			fragmentData[1] = 0.0; //0.09; // fc2.y
			fragmentData[2] = 0.0; //0.12; // fc2.z
			fragmentData[3] = 0.0; //0.15; // fc2.w
			fragmentData[4] = 1.0; //0.16; // fc3.x
			// movement: minus 4 and plus 1 several times...
			fragmentData[5] = 4.0 * (1.0 / (direction == BLUR_DIRECTION_HORIZONTAL ? texture.textureWidth : texture.textureHeight)); // fc3.y
			fragmentData[6] = 1.0 * (1.0 / (direction == BLUR_DIRECTION_HORIZONTAL ? texture.textureWidth : texture.textureHeight)); // fc3.z
			fragmentData[7] = 0.0;  // fc3.w

			// http://stackoverflow.com/questions/1696113/how-do-i-gaussian-blur-an-image-without-using-any-in-built-gaussian-functions
			if(radius == 0) return;

			var kernelLen:uint = radius * 2 + 1;
			var r:Number = -radius;
			var kernel:Array = [];
			var twoRadiusSquaredRecip:Number = 1.0 / (2.0 * radius * radius);
			var sqrtTwoPiTimesRadiusRecip:Number = 1.0 / (Math.sqrt(2.0 * Math.PI) * radius);
			var kernelSum:Number = 0.0;
			var i:int = 0;

			for(i = 0; i < kernelLen; i++) {
				var x:Number = r * r;
				kernel[i] = sqrtTwoPiTimesRadiusRecip * Math.exp(-x * twoRadiusSquaredRecip);
				r++;
				kernelSum += kernel[i];
			}

			for(i = 0; i < kernelLen; i++) {
				kernel[i] /= kernelSum;
			}

			var idx:uint = 4;
			for(i = kernelLen / 2; i >= 0; i--) {
				fragmentData[idx--] = kernel[i];
			}
		}

		override protected function prepareForRender(context:Context3D):void {

			// there is no ipad1 fragment shader fix for this material yet. so assume, the node is always tinted and use the color transform shader
			nodeTinted = true;

			super.prepareForRender(context);

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fragmentData, 2);

			if(!blurredTexture) {
				blurredTexture = context.createTexture(texture.textureWidth, texture.textureHeight, Context3DTextureFormat.BGRA, true);
			}

			if(!blurredTexture2) {
				blurredTexture2 = context.createTexture(texture.textureWidth, texture.textureHeight, Context3DTextureFormat.BGRA, true);
			}
		}

		protected function renderBlur(context:Context3D, startTri:uint, numTris:uint):void {
			activeRenderToTexture = (activeRenderToTexture == blurredTexture ? blurredTexture2 : blurredTexture);
			context.setRenderToTexture(activeRenderToTexture, false, 2, 0);
			context.clear(0.0, 0.0, 0.0, 0.0);
			context.drawTriangles(indexBuffer, startTri * 3, numTris);
			context.setTextureAt(0, activeRenderToTexture);
		}

		override public function render(context:Context3D, faceList:Vector.<Face>, startTri:uint, numTris:uint):void {
			generateBufferData(context, faceList);

			// set up camera for blurry texture
			blurredTextureCam.resizeCameraStage(texture.textureWidth, texture.textureHeight);
			blurredTextureCam.x = -texture.textureWidth * 0.5;
			blurredTextureCam.y = -texture.textureHeight * 0.5;

			// save camera matrix
			var savedCamMatrix:Matrix3D = viewProjectionMatrix;
			var savedSpriteSheet:ASpriteSheetBase = spriteSheet;
			var savedModelMatrix:Matrix3D = modelMatrix;
			viewProjectionMatrix = blurredTextureCam.getViewProjectionMatrix();
			spriteSheet = null;
			modelMatrix = new Matrix3D();

			updateBlurKernel(MAX_BLUR, BLUR_DIRECTION_HORIZONTAL);
			prepareForRender(context);

			activeRenderToTexture = null;
			var totalSteps:int;
			var i:uint;

			// BLUR X
			totalSteps = Math.floor(blurX / MAX_BLUR);

			for(i = 0; i < totalSteps; i++) {
				renderBlur(context, startTri, numTris);
			}

			if(blurX % MAX_BLUR != 0) {
				updateBlurKernel(blurX % MAX_BLUR, BLUR_DIRECTION_HORIZONTAL);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fragmentData, 2);

				renderBlur(context, startTri, numTris);
			}

			// BLUR Y
			context.setProgram(verticalShader.shader);
			updateBlurKernel(MAX_BLUR, BLUR_DIRECTION_VERTICAL);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fragmentData, 2);

			totalSteps = Math.floor(blurY / MAX_BLUR);

			for(i = 0; i < totalSteps; i++) {
				renderBlur(context, startTri, numTris);
			}

			if(blurY % MAX_BLUR != 0) {
				updateBlurKernel(blurY % MAX_BLUR, BLUR_DIRECTION_VERTICAL);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fragmentData, 2);

				renderBlur(context, startTri, numTris);
			}

			context.setRenderToBackBuffer();

			// FINAL PASS
			viewProjectionMatrix = savedCamMatrix;
			spriteSheet = savedSpriteSheet;
			modelMatrix = savedModelMatrix;

			updateBlurKernel(0, BLUR_DIRECTION_HORIZONTAL);
			prepareForRender(context);

			if(blurX == 0 && blurY == 0) {
				activeRenderToTexture = texture.getTexture(context);
			}

			context.setTextureAt(0, activeRenderToTexture);

			context.drawTriangles(indexBuffer, startTri * 3, numTris);

			clearAfterRender(context);
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			blurredTexture = null;
			blurredTexture2 = null;
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {
				horizontalShader = ShaderCache.getInstance().getShader(context, this, VERTEX_SHADER, HORIZONTAL_FRAGMENT_SHADER, 4, texture.textureOptions, 0);
				verticalShader = ShaderCache.getInstance().getShader(context, this, VERTEX_SHADER, VERTICAL_FRAGMENT_SHADER, 4, texture.textureOptions, 1000);

				shaderData = horizontalShader;
			}
		}
		
		override public function dispose():void
		{
			if(horizontalShader) 
			{
				horizontalShader.dispose();
				horizontalShader = null;
			}
			
			if(verticalShader) 
			{
				verticalShader.dispose();
				verticalShader = null;
			}
			
			if(blurredTexture) 
			{
				blurredTexture.dispose();
				blurredTexture = null;
			}
			
			if(blurredTexture2) 
			{
				blurredTexture2.dispose();
				blurredTexture2 = null;
			}

			if(activeRenderToTexture) 
			{
				activeRenderToTexture.dispose();
				activeRenderToTexture = null;
			}

			super.dispose();
		}
	}
}
