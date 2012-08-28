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

	import flash.display3D.Context3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class ShaderCache {

		private static var instance:ShaderCache;

		private var cacheObj:Dictionary = new Dictionary(true);

		public function ShaderCache() {
		}

		public static function getInstance():ShaderCache {
			if(!instance) {
				instance = new ShaderCache();
			}
			return instance;
		}

		public function getShader(context:Context3D, materialClass:Object, vertexShaderString:String, fragmentShaderString:String, numFloatsPerVertex:uint, textureOptions:uint, miscOptions:uint = 0):Shader2D {

			var shaderName:String = getQualifiedClassName(materialClass);

			if(!cacheObj[context]) {
				cacheObj[context] = {};
			}

			var currentCacheContainer:Object = cacheObj[context];

			if(currentCacheContainer[shaderName] && currentCacheContainer[shaderName][textureOptions + miscOptions]) {
				return currentCacheContainer[shaderName][textureOptions + miscOptions];
			} else {
				var shader:Shader2D = new Shader2D(context, vertexShaderString, fragmentShaderString, numFloatsPerVertex, textureOptions);

				if(!currentCacheContainer[shaderName]) {
					currentCacheContainer[shaderName] = {};
				}

				currentCacheContainer[shaderName][textureOptions + miscOptions] = shader;
				return shader;
			}
		}

		public function handleDeviceLoss():void {
			cacheObj = new Dictionary(true);
		}

		public function dispose():void {
			for each(var container:Object in cacheObj) {
				for each(var subContainer:Object in container) {
					for each(var shader:Shader2D in subContainer) {
						shader.dispose();
					}
				}
			}
			cacheObj = null;
		}
	}
}
