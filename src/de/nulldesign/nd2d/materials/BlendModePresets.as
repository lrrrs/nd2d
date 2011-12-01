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

	import de.nulldesign.nd2d.utils.*;

	import flash.display3D.Context3DBlendFactor;

	public class BlendModePresets {

        public static const BLEND:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA,
                                                                    Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        public static const FILTER:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.DESTINATION_COLOR,
                                                                     Context3DBlendFactor.ZERO);

        public static const MODULATE:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.DESTINATION_COLOR,
                                                                       Context3DBlendFactor.ZERO);

        public static const NORMAL_PREMULTIPLIED_ALPHA:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.ONE,
                                                                                         Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        public static const NORMAL_NO_PREMULTIPLIED_ALPHA:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA,
                                                                                            Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        public static const ADD_NO_PREMULTIPLIED_ALPHA:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA,
                                                                  Context3DBlendFactor.ONE);

        public static const ADD_PREMULTIPLIED_ALPHA:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.ONE,
                                                                          Context3DBlendFactor.ONE);
    }
}
