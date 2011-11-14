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

package de.nulldesign.nd2d.materials.texture {

	/**
	 * TextureOptions available for Texture2D
	 * Use a bitmask to combine options, example:
	 * myOption = MIPMAP_NEAREST | FILTERING_NEAREST | REPEAT_NORMAL;
	 */
	public class TextureOption {

		// defines how and if mip mapping should be used
		public static const MIPMAP_DISABLE:uint = 1;
		public static const MIPMAP_NEAREST:uint = 2;
		public static const MIPMAP_LINEAR:uint = 4;

		// texture filtering methods
		public static const FILTERING_NEAREST:uint = 8;
		public static const FILTERING_LINEAR:uint = 16;

		// texture repeat
		public static const REPEAT_NORMAL:uint = 32;
		public static const REPEAT_CLAMP:uint = 64;

		// predefined presets
		public static const QUALITY_LOW:uint = MIPMAP_DISABLE | FILTERING_NEAREST | REPEAT_NORMAL;
		public static const QUALITY_MEDIUM:uint = MIPMAP_DISABLE | FILTERING_LINEAR | REPEAT_NORMAL;
		public static const QUALITY_HIGH:uint = MIPMAP_NEAREST | FILTERING_LINEAR | REPEAT_NORMAL;
		public static const QUALITY_ULTRA:uint = MIPMAP_LINEAR | FILTERING_LINEAR | REPEAT_NORMAL;
	}
}
