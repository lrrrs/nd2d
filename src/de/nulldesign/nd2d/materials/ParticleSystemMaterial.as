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
	import de.nulldesign.nd2d.geom.ParticleVertex;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Point;

	public class ParticleSystemMaterial extends AMaterial {

		private const BURST_SHADER_PART:String = "";
		private const REPEAT_SHADER_PART:String = "frc vt0, vt0 \n";

		private const VERTEX_SHADER:String =

			/*
			 va0 = vertex
			 va1 = uv
			 va2 = misc (starttime, life, startsize, endsize)
			 va3 = velocity / startpos
			 va4 = startcolor
			 va5 = endcolor

			 vc0 = matrix
			 vc4 = current time
			 vc5 = gravity
			 */

			// progress calculation p -> vt0
				"sub vt0, vc4, va2.x        \n" + // currentTime - birth
						"div vt0, vt0, va2.y        \n" + // (currentTime - birth) / life
						"[PARTICLES_REPEAT]" + // (fract((currentTime - birth) / life)
						"sat vt0, vt0               \n" + // clamp(fract((currentTime - birth) / life), 0.0, 1.0) == p -> vt0

					// velocity / position by progress / gravity calculation
						"mov vt1.xy, va3.xy         \n" + // tmp velocity -> vt1
						"mul vt2 vc5.xy, vt0        \n" + // (gravity * p) -> vt2
						"add vt1.xy, vt1.xy, vt2.xy \n" + // tmpVelocity += gravity * p;
						"mul vt1.xy, vt1.xy, vt0.xy \n" + // tmpVelocity *= p; -> vt1

					// size calculation -> float size = startSize * (1.0 - progress) + endSize * progress;
						"sub vt2.x, va0.w, vt0.x    \n" + // (1.0 - progress)
						"mul vt3.x va2.z, vt2.x     \n" + // startSize * (1.0 - progress)
						"mul vt2.x, va2.w, vt0.x    \n" + // endSize * progress;
						"add vt3.x, vt3.x, vt2.x    \n" + // startSize * (1.0 - progress) + endSize * progress -> size vt3.x

						"mov vt2, va0               \n" + // tmp initial vertex position
						"mul vt2.xy, vt2.xy, vt3.x  \n" + // tmpVertexPos.xy *= size;
						"add vt2.xy, vt2.xy, va3.zw \n" + // tmpVertexPos.xy += velocity.zw;
						"add vt2.xy, vt2.xy, vt1.xy \n" + //tmpVertexPos.xy += tmpVelocity.xy;
						"m44 op, vt2, vc0           \n" + // vertex * clipspace

						"mov v0, va1                \n" + // copy uv

					// mix colors -> startColor * (1.0 - progress) + endColor * progress
						"sub vt2.x, va0.w, vt0.x    \n" + // 1.0 - progress
						"mul vt3, va4, vt2.x        \n" + // startColor * (1.0 - progress)
						"mul vt4, va5, vt0.x        \n" + // endColor * progress
						"add v1, vt3, vt4           \n"; // save color


		private const PREMULTIPLIED_ALPHA_PART:String = "mul ft0, ft0, v1	\n" + // mult with color
				"mul oc, ft0, v1.w  \n";  // mult with alpha

		private const NON_PREMULTIPLIED_ALPHA_PART:String = "mul oc, ft0, v1 \n";  // mult with color

		private const FRAGMENT_SHADER:String =
				"tex ft0, v0, fs0 <TEXTURE_SAMPLING_OPTIONS>  \n" + // sample texture from interpolated uv coords
						"[PARTICLES_COLOR_CALCULATION]";  // mult with alpha

		protected var texture:Texture2D;

		public var gravity:Point;
		public var currentTime:Number;

		protected var burst:Boolean;

		public function ParticleSystemMaterial(texture:Texture2D, burst:Boolean) {
			this.texture = texture;
			this.drawCalls = 1;
			this.burst = burst;
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			texture.texture = null;
			shaderData = null;
		}

		override protected function prepareForRender(context:Context3D):void {

			super.prepareForRender(context);

			refreshClipspaceMatrix();

			context.setTextureAt(0, texture.getTexture(context));
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
			context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // misc (starttime, life, startsize, endsize
			context.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4); // velocity / startpos
			context.setVertexBufferAt(4, vertexBuffer, 12, Context3DVertexBufferFormat.FLOAT_4); // startcolor
			context.setVertexBufferAt(5, vertexBuffer, 16, Context3DVertexBufferFormat.FLOAT_4); // endcolor

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

			programConstVector[0] = currentTime;
			programConstVector[1] = currentTime;
			programConstVector[2] = currentTime;
			programConstVector[3] = currentTime;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, programConstVector);

			programConstVector[0] = gravity.x;
			programConstVector[1] = gravity.y;
			programConstVector[2] = 0.0;
			programConstVector[3] = 1.0;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, programConstVector);
		}

		override protected function clearAfterRender(context:Context3D):void {
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
			context.setVertexBufferAt(3, null);
			context.setVertexBufferAt(4, null);
			context.setVertexBufferAt(5, null);
		}

		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
			fillBuffer(buffer, v, uv, face, "PB3D_MISC", 4);
			fillBuffer(buffer, v, uv, face, "PB3D_VELOCITY", 4);
			fillBuffer(buffer, v, uv, face, "PB3D_STARTCOLOR", 4);
			fillBuffer(buffer, v, uv, face, "PB3D_ENDCOLOR", 4);
		}

		override protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String, floatFormat:int):void {

			super.fillBuffer(buffer, v, uv, face, semanticsID, floatFormat);

			var pv:ParticleVertex = ParticleVertex(v);

			if(semanticsID == "PB3D_VELOCITY") {
				buffer.push(pv.vx, pv.vy, pv.startX, pv.startY);
			}

			if(semanticsID == "PB3D_MISC") {
				buffer.push(pv.startTime, pv.life, pv.startSize, pv.endSize);
			}

			if(semanticsID == "PB3D_ENDCOLOR") {
				buffer.push(pv.endColorR, pv.endColorG, pv.endColorB, pv.endAlpha);
			}

			if(semanticsID == "PB3D_STARTCOLOR") {
				buffer.push(pv.startColorR, pv.startColorG, pv.startColorB, pv.startAlpha);
			}
		}

		override protected function initProgram(context:Context3D):void {
			if(!shaderData) {

				var vertexString:String;
				var fragmentString:String;
				var cacheNum:uint;

				if(burst) {
					cacheNum = 1000;
					vertexString = VERTEX_SHADER.replace("[PARTICLES_REPEAT]", BURST_SHADER_PART);
				} else {
					cacheNum = 2000;
					vertexString = VERTEX_SHADER.replace("[PARTICLES_REPEAT]", REPEAT_SHADER_PART);
				}

				if(texture.hasPremultipliedAlpha) {
					cacheNum += 100;
					fragmentString = FRAGMENT_SHADER.replace("[PARTICLES_COLOR_CALCULATION]", PREMULTIPLIED_ALPHA_PART);
				} else {
					cacheNum += 200;
					fragmentString = FRAGMENT_SHADER.replace("[PARTICLES_COLOR_CALCULATION]", NON_PREMULTIPLIED_ALPHA_PART);
				}

				shaderData = ShaderCache.getInstance().getShader(context, this, vertexString, fragmentString, 20, texture.textureOptions, cacheNum);
			}
		}
		
		override public function dispose():void 
		{
			if(texture) {
				texture.dispose();
				texture = null;
			}
			
			super.dispose();
		}
	}
}
