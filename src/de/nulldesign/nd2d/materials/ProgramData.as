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

    import com.adobe.pixelBender3D.AGALProgramPair;
    import com.adobe.pixelBender3D.PBASMCompiler;
    import com.adobe.pixelBender3D.PBASMProgram;
    import com.adobe.pixelBender3D.RegisterMap;
    import com.adobe.pixelBender3D.utils.ProgramConstantsHelper;
    import com.adobe.pixelBender3D.utils.VertexBufferHelper;

    import flash.display3D.Context3D;
    import flash.display3D.Program3D;
    import flash.utils.ByteArray;

    public class ProgramData {

        public var program:Program3D;

        public var numFloatsPerVertex:int;
        public var vertexRegisterMap:RegisterMap;
        public var fragmentRegisterMap:RegisterMap;
        public var parameterBufferHelper:ProgramConstantsHelper;

        public function ProgramData(context:Context3D, vertexProgramClass:Class, materialVertexProgramClass:Class,
                                    materialFragmentProgramClass:Class) {

            if(!context) return;

            var inputVertexProgram:PBASMProgram = new PBASMProgram(readFile(vertexProgramClass));
            var inputMaterialVertexProgram:PBASMProgram = new PBASMProgram(readFile(materialVertexProgramClass));
            var inputFragmentProgram:PBASMProgram = new PBASMProgram(readFile(materialFragmentProgramClass));

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

            trace("new Program created: " + vertexProgramClass);
        }

        protected function readFile(f:Class):String {
            var bytes:ByteArray;
            bytes = new f();
            return bytes.readUTFBytes(bytes.bytesAvailable);
        }

    }
}
