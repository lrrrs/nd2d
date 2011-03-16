/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: https://github.com/nulldesign/nd2d
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

/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
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
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    public class AMaterial {

        public var projectionMatrix:Matrix3D;
        public var modelViewMatrix:Matrix3D;
        public var clipSpaceMatrix:Matrix3D = new Matrix3D();

        public var numTris:int = 0;

        public var indexBuffer:IndexBuffer3D;
        public var vertexBuffer:VertexBuffer3D;

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

        public function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

            initProgram(context);

            if(vertexBuffer) {
                return;
            }

            var i:int;
            var numFaces:int = faceList.length;
            var numIndices:int;

            mIndexBuffer = new Vector.<uint>();
            mVertexBuffer = new Vector.<Number>();

            var duplicateCheck:Dictionary = new Dictionary();
            var tmpUID:String;
            var indexBufferIdx:Number = 0;
            var face:Face;

            for(i = 0; i < numFaces; i++) {

                face = faceList[i];

                tmpUID = face.v1.uid + "." + face.uv1.uid;
                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v1, face.uv1, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }

                tmpUID = face.v2.uid + "." + face.uv2.uid;
                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v2, face.uv2, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }

                tmpUID = face.v3.uid + "." + face.uv3.uid;
                if(duplicateCheck[tmpUID] == undefined) {
                    addVertex(mVertexBuffer, face.v3, face.uv3, face);
                    duplicateCheck[tmpUID] = indexBufferIdx;
                    mIndexBuffer.push(indexBufferIdx);
                    ++indexBufferIdx;
                } else {
                    mIndexBuffer.push(duplicateCheck[tmpUID]);
                }
            }

            numIndices = mVertexBuffer.length / numFloatsPerVertex;

            // GENERATE BUFFERS
            vertexBuffer = context.createVertexBuffer(numIndices, numFloatsPerVertex); // xx vertices, xx floats per vertex
            vertexBuffer.uploadFromVector(mVertexBuffer, 0, numIndices);

            if(!indexBuffer) {

                indexBuffer = context.createIndexBuffer(mIndexBuffer.length);
                indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer.length);

                numTris = int(mIndexBuffer.length / 3);
            }
        }

        public function prepareForRender(context:Context3D):void {

            context.setProgram(program);
            context.setBlendFactors(blendMode.src, blendMode.dst);

            if(vertexRegisterMap) {
                vertexBufferHelper = new VertexBufferHelper(context, vertexRegisterMap.vertexRegisters, vertexBuffer);
            }

            clipSpaceMatrix.identity();
            clipSpaceMatrix.append(modelViewMatrix);
            clipSpaceMatrix.append(projectionMatrix);

            parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX, "objectToClipSpaceTransform", clipSpaceMatrix, true);

            if(needUploadVertexBuffer) {
                needUploadVertexBuffer = false;
                vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / numFloatsPerVertex);
            }

            // overwrite and set parameter and vertexbuffers for program
        }

        public function clearAfterRender(context:Context3D):void {
            // overwrite
            for(var j:int = 0; j < vertexRegisterMap.vertexRegisters.length; j += 1) {
                context.setVertexBufferAt(j, null);
            }
        }

        protected function initProgram(context:Context3D):void {
            if(!program) {

                var inputVertexProgram:PBASMProgram = new PBASMProgram(vertexProgram);

                var inputMaterialVertexProgram:PBASMProgram = new PBASMProgram(materialVertexProgram);
                var inputFragmentProgram:PBASMProgram = new PBASMProgram(materialFragmentProgram);

                var programs:AGALProgramPair = PBASMCompiler.compile(inputVertexProgram, inputMaterialVertexProgram, inputFragmentProgram);

                var agalVertexBinary:ByteArray = programs.vertexProgram.byteCode;
                var agalFragmentBinary:ByteArray = programs.fragmentProgram.byteCode;

                vertexRegisterMap = programs.vertexProgram.registers;
                fragmentRegisterMap = programs.fragmentProgram.registers;

                parameterBufferHelper = new ProgramConstantsHelper(context, vertexRegisterMap, fragmentRegisterMap);

                numFloatsPerVertex = VertexBufferHelper.numFloatsPerVertex(vertexRegisterMap.vertexRegisters);

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

            var vertexRegisters:Vector.<VertexRegisterInfo> = vertexRegisterMap.vertexRegisters;

            for(var j:int = 0; j < vertexRegisterMap.vertexRegisters.length; j += 1) {
                var n:int = getFloatFormat(vertexRegisterMap.vertexRegisters[j].format);

                if(vertexRegisters[ j ].semantics.id == "PB3D_POSITION") {
                    buffer.push(v.x, v.y, v.z);
                    if(n == 4)
                        buffer.push(1.0);
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_TARGET_POSITION") {
                    buffer.push(v.targetVertex.x, v.targetVertex.y, v.targetVertex.z);
                    if(n == 4)
                        buffer.push(1.0);
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_COLOR") {
                    buffer.push(v.r, v.g, v.b);
                    if(n == 4)
                        buffer.push(v.a);
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_NORMAL") {
                    buffer.push(v.normal.x, v.normal.y, v.normal.z);
                    if(n == 4)
                        buffer.push(v.normal.w);
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_TARGET_NORMAL") {
                    buffer.push(v.targetVertex.normal.x, v.targetVertex.normal.y, v.targetVertex.normal.z);
                    if(n == 4)
                        buffer.push(v.targetVertex.normal.w);
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_UV") {
                    buffer.push(uv.u, uv.v);
                    if(n == 3)
                        buffer.push(0.0);
                    if(n == 4)
                        buffer.push(0.0, 0.0);
                }
            }
        }

        public function copyBufferIdx(fromIdx:uint, toIdx:uint):void {
            needUploadVertexBuffer = true;

            toIdx *= numFloatsPerVertex;

            for(var i:int = toIdx; i < toIdx + numFloatsPerVertex; i++) {
                mVertexBuffer[i] = mVertexBuffer[fromIdx++];
            }
        }

        public function modifyBufferAt(idx:uint, v:Vertex, uv:UV, face:Face):void {

            needUploadVertexBuffer = true;

            var curIdx:uint = idx * numFloatsPerVertex;
            var vertexRegisters:Vector.<VertexRegisterInfo> = vertexRegisterMap.vertexRegisters;

            for(var j:int = 0; j < vertexRegisterMap.vertexRegisters.length; j += 1) {
                var n:int = getFloatFormat(vertexRegisterMap.vertexRegisters[j].format);

                if(vertexRegisters[ j ].semantics.id == "PB3D_POSITION") {
                    mVertexBuffer[curIdx++] = v.x;
                    mVertexBuffer[curIdx++] = v.y;
                    mVertexBuffer[curIdx++] = v.z;

                    if(n == 4)
                        curIdx++;
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_TARGET_POSITION") {
                    mVertexBuffer[curIdx++] = v.targetVertex.x;
                    mVertexBuffer[curIdx++] = v.targetVertex.y;
                    mVertexBuffer[curIdx++] = v.targetVertex.z;

                    if(n == 4)
                        curIdx++;
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_COLOR") {
                    mVertexBuffer[curIdx++] = v.r;
                    mVertexBuffer[curIdx++] = v.g;
                    mVertexBuffer[curIdx++] = v.b;

                    if(n == 4)
                        v.a;
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_NORMAL") {
                    mVertexBuffer[curIdx++] = v.normal.x;
                    mVertexBuffer[curIdx++] = v.normal.y;
                    mVertexBuffer[curIdx++] = v.normal.z;

                    if(n == 4)
                        mVertexBuffer[curIdx++] = v.normal.w;
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_TARGET_NORMAL") {
                    mVertexBuffer[curIdx++] = v.targetVertex.normal.x;
                    mVertexBuffer[curIdx++] = v.targetVertex.normal.y;
                    mVertexBuffer[curIdx++] = v.targetVertex.normal.z;

                    if(n == 4)
                        mVertexBuffer[curIdx++] = v.targetVertex.normal.w;
                }

                if(vertexRegisters[ j ].semantics.id == "PB3D_UV") {
                    mVertexBuffer[curIdx++] = uv.u;
                    mVertexBuffer[curIdx++] = uv.v;

                    if(n == 3)
                        curIdx++;

                    if(n == 4)
                        curIdx += 2;
                }

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
