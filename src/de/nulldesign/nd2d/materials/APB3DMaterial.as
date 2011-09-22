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

    import com.adobe.pixelBender3D.VertexRegisterInfo;
    import com.adobe.pixelBender3D.utils.VertexBufferHelper;

    import de.nulldesign.nd2d.geom.Face;

    import de.nulldesign.nd2d.geom.UV;

    import de.nulldesign.nd2d.geom.Vertex;

    import flash.display3D.Context3D;
    import flash.utils.ByteArray;

    public class APB3DMaterial extends AMaterial {

        protected var vertexBufferHelper:VertexBufferHelper;

        public function APB3DMaterial() {
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            vertexBufferHelper = null;
        }

        override protected function prepareForRender(context:Context3D):Boolean {

            super.prepareForRender(context);

            if(!vertexBufferHelper) {
                vertexBufferHelper = new VertexBufferHelper(context, programData.vertexRegisterMap.inputVertexRegisters, vertexBuffer);
            }

            vertexBufferHelper.setVertexBuffers();

            return true;
        }

        override protected function clearAfterRender(context:Context3D):void {

            for(var i:int = 0; i < programData.vertexRegisterMap.inputVertexRegisters.length; ++i) {
                context.setVertexBufferAt(i, null);
            }
            context.setTextureAt(0, null);
        }

        override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

            var vertexRegisters:Vector.<VertexRegisterInfo> = programData.vertexRegisterMap.inputVertexRegisters;

            for(var i:int = 0; i < programData.vertexRegisterMap.inputVertexRegisters.length; i += 1) {
                var n:int = getFloatFormat(programData.vertexRegisterMap.inputVertexRegisters[i].format);
                fillBuffer(buffer, v, uv, face, vertexRegisters[i].semantics.id, n);
            }
        }

        protected function readFile(f:Class):String {
            var bytes:ByteArray;
            bytes = new f();
            return bytes.readUTFBytes(bytes.bytesAvailable);
        }
    }
}
