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

package de.nulldesign.nd2d.materials.shader {

	import com.adobe.utils.AGALMiniAssembler;

	import de.nulldesign.nd2d.materials.texture.TextureOption;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;

	public class Shader2D {

		public var shader:Program3D;
		public var numFloatsPerVertex:int;

		public function Shader2D(context:Context3D, vertexShaderString:String, fragmentShaderString:String, numFloatsPerVertex:uint, textureOptions:uint) {

			var texOptions:Array = ["2d"];
			var optionMissing:Boolean = false;

			if(textureOptions & TextureOption.MIPMAP_DISABLE) {
				texOptions.push("mipnone");
			} else if(textureOptions & TextureOption.MIPMAP_NEAREST) {
				texOptions.push("mipnearest");
			} else if(textureOptions & TextureOption.MIPMAP_LINEAR) {
				texOptions.push("miplinear");
			} else {
				optionMissing = true;
			}

			if(textureOptions & TextureOption.FILTERING_LINEAR) {
				texOptions.push("linear");
			} else if(textureOptions & TextureOption.FILTERING_NEAREST) {
				texOptions.push("nearest");
			} else {
				optionMissing = true;
			}

			if(textureOptions & TextureOption.REPEAT_CLAMP) {
				texOptions.push("clamp");
			} else if(textureOptions & TextureOption.REPEAT_NORMAL) {
				texOptions.push("repeat");
			} else {
				optionMissing = true;
			}

			if(optionMissing && textureOptions > 0) {
				throw new Error("you need to specify all three texture option components. for example: myOption = MIPMAP_NEAREST | FILTERING_NEAREST | REPEAT_NORMAL;");
			}

			var pattern:RegExp = /TEXTURE_SAMPLING_OPTIONS/g;
			var finalFragmentShader:String = fragmentShaderString.replace(pattern, texOptions.join(","));

			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, vertexShaderString);

			var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, finalFragmentShader);

			shader = context.createProgram();
			shader.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
			this.numFloatsPerVertex = numFloatsPerVertex;
		}
	}
}
