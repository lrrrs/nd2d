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
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.ParticleVertex;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    public class ParticleSystemMaterial extends AMaterial {

        [Embed (source="../shader/ParticleSystemVertexShader.pbasm", mimeType="application/octet-stream")]
        protected static const VertexProgramClass:Class;

        [Embed (source="../shader/ParticleSystemMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
        protected static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/ParticleSystemMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
        protected static const MaterialFragmentProgramClass:Class;

        protected var texture:Texture;
        protected var particleTexture:BitmapData;

        public var gravity:Point;
        public var currentTime:Number;

        public function ParticleSystemMaterial(particleTexture:BitmapData) {
            this.particleTexture = particleTexture;
            this.drawCalls = 1;
        }


        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            texture = null;
        }

        override protected function prepareForRender(context:Context3D):Boolean {

            super.prepareForRender(context);

            if(!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, particleTexture, true);
            }

            parameterBufferHelper.setTextureByName("textureImage", texture);

            parameterBufferHelper.setMatrixParameterByName(Context3DProgramType.VERTEX, "objectToClipSpaceTransform",
                                                           clipSpaceMatrix, true);

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "currentTime",
                                                           Vector.<Number>([ currentTime ]));

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX, "gravity",
                                                           Vector.<Number>([ gravity.x, gravity.y, 0.0, 1.0 ]));

            parameterBufferHelper.update();

            vertexBufferHelper.setVertexBuffers();

            return true;
        }

        override protected function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {
            if(!program) {
                vertexProgram = readFile(VertexProgramClass);
                materialVertexProgram = readFile(MaterialVertexProgramClass);
                materialFragmentProgram = readFile(MaterialFragmentProgramClass);
            }

            super.initProgram(context);
        }

        override protected function fillBuffer(buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face, semanticsID:String,
                                      floatFormat:int):void {

            super.fillBuffer(buffer, v, uv, face, semanticsID, floatFormat);

            var pv:ParticleVertex = ParticleVertex(v);

            if(semanticsID == "PB3D_VELOCITY") {
                buffer.push(pv.vx, pv.vy, pv.startX, pv.startY);
            }

            if(semanticsID == "PB3D_MISC") {
                buffer.push(pv.startTime, pv.life, pv.startSize, pv.endSize);
            }

            if(semanticsID == "PB3D_ENDCOLOR") {
                buffer.push(pv.endColorR, pv.endColorG, pv.endColorB, pv.endAlpha);
            }

            if(semanticsID == "PB3D_STARTCOLOR") {
                buffer.push(pv.startColorR, pv.startColorG, pv.startColorB, pv.startAlpha);
            }

            /*
            if(semanticsID == "PB3D_BIRTH") {
                buffer.push(pv.startTime);
            }

            if(semanticsID == "PB3D_LIFE") {
                buffer.push(pv.life);
            }

            if(semanticsID == "PB3D_STARTSIZE") {
                buffer.push(pv.startSize);
            }

            if(semanticsID == "PB3D_ENDSIZE") {
                buffer.push(pv.endSize);
            }
            */
        }
    }
}