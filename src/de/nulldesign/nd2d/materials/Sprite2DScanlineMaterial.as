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

    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;

    public class Sprite2DScanlineMaterial extends Sprite2DMaterial {

        [Embed (source="../shader/Sprite2DMaterialScanlineVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/Sprite2DMaterialScanlineFragmentShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialFragmentProgramClass:Class;

        [Embed (source="../shader/Sprite2DVertexScanlineShader.pbasm", mimeType="application/octet-stream")]
        private static const VertexProgramClass:Class;

        private static var scanlineProgramData:ProgramData;

        public function Sprite2DScanlineMaterial(textureObject:Object) {
            super(textureObject);
        }

        public var seed:uint = 0;

        override protected function prepareForRender(context:Context3D):Boolean {

            if(programData.parameterBufferHelper) {

                var sceneHeight:Number = Math.abs(1 / (projectionMatrix.rawData[5] / 2));
                programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "sceneHeight",
                                                                           Vector.<Number>([ sceneHeight ]));

                programData.parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "seed",
                                                                           Vector.<Number>([ seed ]));
            }

            return super.prepareForRender(context);
        }

        override protected function initProgram(context:Context3D):void {
            if(!scanlineProgramData) {
                scanlineProgramData = new ProgramData(context, VertexProgramClass, MaterialVertexProgramClass,
                                                      MaterialFragmentProgramClass);
            }

            programData = scanlineProgramData;
        }
    }
}
