/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
 *
 *
 *  Licence Agreement
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 * /
 */

package de.nulldesign.nd2d.materials {
    import com.adobe.pixelBender3D.AGALProgramPair;
    import com.adobe.pixelBender3D.PBASMCompiler;
    import com.adobe.pixelBender3D.PBASMProgram;
    import com.adobe.pixelBender3D.RegisterMap;
    import com.adobe.pixelBender3D.VertexRegisterInfo;
    import com.adobe.pixelBender3D.utils.ProgramConstantsHelper;
    import com.adobe.pixelBender3D.utils.VertexBufferHelper;

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.utils.NodeBlendMode;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    public class AMaterial {

        // cameras view projectionmatrix
        public var viewProjectionMatrix:Matrix3D;

        // cameras projection matrix
        public var projectionMatrix:Matrix3D;

        // models modelmatrix
        public var modelMatrix:Matrix3D;

        public var clipSpaceMatrix:Matrix3D = new Matrix3D();

        public var numTris:int = 0;
        public var drawCalls:int = 0;

        protected var indexBuffer:IndexBuffer3D;
        protected var vertexBuffer:VertexBuffer3D;

        public var blendMode:NodeBlendMode = BlendModePresets.NORMAL;

        protected var mIndexBuffer:Vector.<uint>;
        protected var mVertexBuffer:Vector.<Number>;

        protected var vertexProgram:String;
        protected var materialVertexProgram:String;
        protected var materialFragmentProgram:String;

        protected var program:Program3D;

        protected var numFloatsPerVertex:int;
        protected var vertexRegisterMap:RegisterMap;
        protected var fragmentRegisterMap:RegisterMap;
        protected var parameterBufferHelper:ProgramConstantsHelper;
        protected var vertexBufferHelper:VertexBufferHelper;

        public var needUploadVertexBuffer:Boolean = false;

        public function AMaterial() {

        }

        protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

            if(vertexBuffer) {
                return;
            }

            initProgram(context);

            var i:int;
            var numFaces:int = faceList.length;
            var numIndices:int;

            mIndexBuffer = new Vector.<uint>();
            mVertexBuffer = new Vector.<Number>();

            var duplicateCheck:Dictionary = new Dictionary();
            var tmpUID:String;
            var indexBufferIdx:uint = 0;
            var face:Face;

            // generate index + vertexbuffer
            // integrated check if the vertex / uv combination is already in the buffer and skip these vertices
            for(i = 0; i < numFaces; i++) {

                face = faceList[i];

                tmpUID = face.v1.uid + "." + face.uv1.uid;

                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v1, face.uv1, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    face.v1.bufferIdx = indexBufferIdx;
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }

                tmpUID = face.v2.uid + "." + face.uv2.uid;

                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v2, face.uv2, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    face.v2.bufferIdx = indexBufferIdx;
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }

                tmpUID = face.v3.uid + "." + face.uv3.uid;

                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v3, face.uv3, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    face.v3.bufferIdx = indexBufferIdx;
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }
            }

            duplicateCheck = null;
            numIndices = mVertexBuffer.length / numFloatsPerVertex;

            // GENERATE BUFFERS
            vertexBuffer = context.createVertexBuffer(numIndices, numFloatsPerVertex);
            vertexBuffer.uploadFromVector(mVertexBuffer, 0, numIndices);

            if(!indexBuffer) {

                indexBuffer = context.createIndexBuffer(mIndexBuffer.length);
                indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer.length);

                numTris = int(mIndexBuffer.length / 3);
            }
        }

        protected function prepareForRender(context:Context3D):Boolean {

            context.setProgram(program);
            context.setBlendFactors(blendMode.src, blendMode.dst);

            if(vertexRegisterMap && !vertexBufferHelper) {
                vertexBufferHelper = new VertexBufferHelper(context, vertexRegisterMap.inputVertexRegisters,
                                                            vertexBuffer);
            }

            clipSpaceMatrix.identity();
            clipSpaceMatrix.append(modelMatrix);
            clipSpaceMatrix.append(viewProjectionMatrix);

            if(needUploadVertexBuffer) {
                needUploadVertexBuffer = false;
                vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / numFloatsPerVertex);
            }

            return true;
            // overwrite and set parameter and vertexbuffers for program
        }

        public function handleDeviceLoss():void {
            indexBuffer = null;
            vertexBuffer = null;
            mIndexBuffer = null;
            mVertexBuffer = null;
            program = null;
            vertexRegisterMap = null;
            fragmentRegisterMap = null;
            parameterBufferHelper = null;
            vertexBufferHelper = null;
            needUploadVertexBuffer = true;
        }

        public function render(context:Context3D, faceList:Vector.<Face>, numTris:uint):void {
            generateBufferData(context, faceList);
            if(prepareForRender(context)) {
                context.drawTriangles(indexBuffer, 0, numTris);
            }
            clearAfterRender(context);
        }

        protected function clearAfterRender(context:Context3D):void {
            for(var i:int = 0; i < vertexRegisterMap.inputVertexRegisters.length; ++i) {
                context.setVertexBufferAt(i, null);
            }
        }

        protected function initProgram(context:Context3D):void {
            if(!program) {

                var inputVertexProgram:PBASMProgram = new PBASMProgram(vertexProgram);
                var inputMaterialVertexProgram:PBASMProgram = new PBASMProgram(materialVertexProgram);
                var inputFragmentProgram:PBASMProgram = new PBASMProgram(materialFragmentProgram);

                var programs:AGALProgramPair = PBASMCompiler.compile(inputVertexProgram, inputMaterialVertexProgram,
                                                                     inputFragmentProgram);

                var agalVertexBinary:ByteArray = programs.vertexProgram.byteCode;
                var agalFragmentBinary:ByteArray = programs.fragmentProgram.byteCode;

                vertexRegisterMap = programs.vertexProgram.registers;
                fragmentRegisterMap = programs.fragmentProgram.registers;

                parameterBufferHelper = new ProgramConstantsHelper(context, vertexRegisterMap, fragmentRegisterMap);

                numFloatsPerVertex = VertexBufferHelper.numFloatsPerVertex(vertexRegisterMap.inputVertexRegisters);

                program = context.createProgram();
                program.upload(agalVertexBinary, agalFragmentBinary);
            }
        }

        protected function readFile(f:Class):String {
            var bytes:ByteArray;
            bytes = new f();
            return bytes.readUTFBytes(bytes.bytesAvailable);
        }

        protected function addVertex(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {

            var vertexRegisters:Vector.<VertexRegisterInfo> = vertexRegisterMap.inputVertexRegisters;

            for(var i:int = 0; i < vertexRegisterMap.inputVertexRegisters.length; i += 1) {

                var n:int = getFloatFormat(vertexRegisterMap.inputVertexRegisters[i].format);
                fillBuffer(buffer, v, uv, face, vertexRegisters[i].semantics.id, n);
            }
        }

        public function modifyVertexInBuffer(bufferIdx:uint, x:Number, y:Number):void {

            if(!mVertexBuffer || mVertexBuffer.length == 0) return;

            var vertexRegisters:Vector.<VertexRegisterInfo> = vertexRegisterMap.inputVertexRegisters;
            var idx:uint = bufferIdx * numFloatsPerVertex;

            for(var i:int = 0; i < vertexRegisterMap.inputVertexRegisters.length; i += 1) {
                var semanticsID:String = vertexRegisters[i].semantics.id;
                var floatFormat:int = getFloatFormat(vertexRegisterMap.inputVertexRegisters[i].format);

                if(semanticsID == "PB3D_POSITION") {

                    mVertexBuffer[idx++] = x;
                    mVertexBuffer[idx++] = y;

                    if(floatFormat >= 3)
                        idx++;

                    if(floatFormat == 4)
                        idx++;

                } else {
                    idx += floatFormat;
                }
            }

            //TODO: implement partial vertex buffer uploads? performance? test...
            needUploadVertexBuffer = true;
        }

        protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String,
                                      floatFormat:int):void {

            if(semanticsID == "PB3D_IDX") {
                buffer.push(face.idx);

                if(floatFormat == 2)
                    buffer.push(0.0);

                if(floatFormat == 3)
                    buffer.push(0.0, 0.0);

                if(floatFormat == 4)
                    buffer.push(0.0, 0.0, 0.0);
            }

            if(semanticsID == "PB3D_POSITION") {

                buffer.push(v.x, v.y);

                if(floatFormat >= 3)
                    buffer.push(v.z);

                if(floatFormat == 4)
                    buffer.push(v.w);
            }

            if(semanticsID == "PB3D_COLOR") {

                buffer.push(v.r, v.g, v.b);

                if(floatFormat == 4)
                    buffer.push(v.a);
            }

            if(semanticsID == "PB3D_UV") {

                buffer.push(uv.u, uv.v);

                if(floatFormat == 3)
                    buffer.push(0.0);

                if(floatFormat == 4)
                    buffer.push(0.0, 0.0);
            }
        }

        protected function getFloatFormat(format:String):int {
            if(format == Context3DVertexBufferFormat.FLOAT_1)
                return 1;
            if(format == Context3DVertexBufferFormat.FLOAT_2)
                return 2;
            if(format == Context3DVertexBufferFormat.FLOAT_3)
                return 3;
            if(format == Context3DVertexBufferFormat.FLOAT_4)
                return 4;

            throw new Error("bad format");

            return 0;
        }
    }
}
