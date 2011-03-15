/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.materials {
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
        }

        override public function prepareForRender(context:Context3D):void {

            super.prepareForRender(context);

            if (!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, particleTexture);
            }

            context.setTextureAt(0, texture);

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX,
                    "currentTime",
                    Vector.<Number>([ currentTime, currentTime, currentTime, 1.0 ]));

            parameterBufferHelper.setNumberParameterByName(Context3DProgramType.VERTEX,
                    "gravity",
                    Vector.<Number>([ gravity.x, gravity.y, 0.0, 1.0 ]));

            parameterBufferHelper.update();

            vertexBufferHelper.setVertexBuffers();
        }

        override public function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {
            if (!program) {
                vertexProgram = readFile(VertexProgramClass);
                materialVertexProgram = readFile(MaterialVertexProgramClass);
                materialFragmentProgram = readFile(MaterialFragmentProgramClass);
            }

            super.initProgram(context);
        }
    }
}