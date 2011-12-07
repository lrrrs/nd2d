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

package materials {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.Sprite2DMaterial;
	import de.nulldesign.nd2d.materials.shader.Shader2D;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.utils.getTimer;

	public class Sprite2DDizzyMaterial extends Sprite2DMaterial {

        private const DIZZY_VERTEX_SHADER:String =
                "m44 op, va0, vc0   \n" + // vertex * clipspace
                "mov v0, va1		\n"; // copy uv

        private const DIZZY_FRAGMENT_SHADER:String =
                "mov ft0.xyzw, v0.xy                        \n" + // get interpolated uv coords
                "mul ft1, ft0, fc2.y                        \n" +
                "add ft1, ft1, fc2.x                        \n" +
                "cos ft1.y, ft1.w                           \n" +
                "sin ft1.x, ft1.z                           \n" +
                "mul ft1.xy, ft1.xy, fc2.zw                 \n" +
                "add ft0, ft0, ft1                          \n" +
                "tex ft0, ft0, fs0 <2d,clamp,linear,nomip>  \n" + // sample texture
                "mul ft0, ft0, fc0                          \n" + // mult with colorMultiplier
                "add ft0, ft0, fc1                          \n" + // mult with colorOffset
                "mov oc, ft0                                \n";

        private static var dizzyProgramData:Shader2D;

        public function Sprite2DDizzyMaterial() {
            super();
        }

        override protected function prepareForRender(context:Context3D):void {

            super.prepareForRender(context);

            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([ getTimer() * 0.002,
                                                                                                      8 * Math.PI,
                                                                                                      0.01,
                                                                                                      0.02 ]));
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            dizzyProgramData = null;
        }

        override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

            fillBuffer(buffer, v, uv, face, "PB3D_POSITION", 2);
            fillBuffer(buffer, v, uv, face, "PB3D_UV", 2);
        }

        override protected function initProgram(context:Context3D):void {
            if(!dizzyProgramData) {
				dizzyProgramData = new Shader2D(context, DIZZY_VERTEX_SHADER, DIZZY_FRAGMENT_SHADER, 4, texture.textureOptions);
            }

            shaderData = dizzyProgramData;
        }
    }
}
