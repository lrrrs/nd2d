/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 06.04.11 14:28
 */
package de.nulldesign.nd2d.materials {

    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    public class Sprite2DCloudMaterial extends AMaterial {
        /*
         protected const DEFAULT_VERTEX_SHADER:String = "m44 op, va0, vc[va3.x]   \n" + // vertex * clipspace
         "mov v0, va1		\n" + // copy uv
         "mov v1, va2		\n"; // copy color

         protected const DEFAULT_FRAGMENT_SHADER:String = "mov ft0, v0\n" + // get interpolated uv coords
         "tex ft1, ft0, fs0 <2d,clamp,linear>\n" + // sample texture
         "mul ft1, ft1, v1\n" + // mult with color
         "mov oc, ft1\n";
         */
        [Embed (source="../shader/Sprite2DCloudMaterialVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialVertexProgramClass:Class;

        [Embed (source="../shader/Sprite2DCloudMaterialFragmentShader.pbasm", mimeType="application/octet-stream")]
        private static const MaterialFragmentProgramClass:Class;

        [Embed (source="../shader/Sprite2DCloudVertexShader.pbasm", mimeType="application/octet-stream")]
        private static const VertexProgramClass:Class;

        protected static var sprite2DCloudProgramData:ProgramData;

        protected var texture:Texture;
        protected var bitmapData:BitmapData;
        protected var spriteSheet:SpriteSheet;

        protected const BATCH_SIZE:uint = 2;

        public function Sprite2DCloudMaterial(bitmapData:BitmapData, spriteSheet:SpriteSheet = null) {
            this.bitmapData = bitmapData;
            this.spriteSheet = spriteSheet;
            this.drawCalls = 1;
        }

        override protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void {

            // use first two faces and extend facelist to max. batch size
            var f0:Face = faceList[0];
            var f1:Face = faceList[1];
            var newF0:Face;
            var newF1:Face;

            var newFaceList:Vector.<Face> = new Vector.<Face>(BATCH_SIZE * 2, true);

            for(var i:int = 0; i < BATCH_SIZE; i++) {
                newF0 = f0.clone();
                newF1 = f1.clone();

                newF0.idx = i;
                newF1.idx = i;

                newFaceList[i * 2] = newF0;
                newFaceList[i * 2 + 1] = newF1;
            }

            super.generateBufferData(context, newFaceList);
        }

        override protected function prepareForRender(context:Context3D):Boolean {

            super.prepareForRender(context);

            refreshClipspaceMatrix();

            if(!texture) {
                texture = TextureHelper.generateTextureFromBitmap(context, bitmapData, true);
            }

            context.setTextureAt(0, texture);

            /*
             // TODO SET TEXTURE BY NAME!!!
             context.setTextureAt(0, texture);

             var child:Sprite2D;
             var spriteSheet:SpriteSheet;
             var offset:Point;

             for(var i:uint = 0; i < childList.length; i++) {

             child = Sprite2D(childList[i]);
             spriteSheet = child.spriteSheet;
             offset = spriteSheet.getOffsetForFrame();

             // TODO update properties internally
             if(child.invalidateColors) child.updateColors();
             if(child.invalidateMatrix) child.updateMatrix();

             clipSpaceMatrix.identity();
             clipSpaceMatrix.append(modelMatrix);
             clipSpaceMatrix.append(child.localModelMatrix);
             clipSpaceMatrix.append(viewProjectionMatrix);

             var numConstantsPerSprite:uint = 6; // matrix + offset + color
             var numConstantsUsedForMatrix:uint = 4;

             context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, i * numConstantsPerSprite,
             clipSpaceMatrix, true);

             context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
             i * numConstantsPerSprite + numConstantsUsedForMatrix,
             Vector.<Number>([ child.r, child.g, child.b, child.a ]));

             context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
             i * numConstantsPerSprite + numConstantsUsedForMatrix + 1,
             Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));
             }
             */
            vertexBufferHelper.setVertexBuffers();

            return true;
        }

        public function renderBatch(context:Context3D, faceList:Vector.<Face>, childList:Vector.<Node2D>):void {

            generateBufferData(context, faceList);

            if(prepareForRender(context)) {
                //context.drawTriangles(indexBuffer, 0, 2);

                var child:Sprite2D;
                var spriteSheet:SpriteSheet;
                var offset:Point;

                for(var i:uint = 0; i < 2; i++) {

                    child = Sprite2D(childList[i]);
                    //spriteSheet = child.spriteSheet;
                    //offset = spriteSheet.getOffsetForFrame();

                    if(child.invalidateColors) child.updateColors();
                    if(child.invalidateMatrix) child.updateMatrix();

                    if(child.visible) {

                        clipSpaceMatrix.identity();
                        clipSpaceMatrix.append(modelMatrix);
                        clipSpaceMatrix.append(child.localModelMatrix);
                        clipSpaceMatrix.append(viewProjectionMatrix);

                        // set shader parameters...
                        var numConstantsPerSprite:uint = 6; // matrix + offset + color
                        var numConstantsUsedForMatrix:uint = 4;

                        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, i * numConstantsPerSprite,
                                                              clipSpaceMatrix, true);

                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              i * numConstantsPerSprite + numConstantsUsedForMatrix,
                                                              Vector.<Number>([ child.r, child.g, child.b, child.a ]));

                        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                                                              i * numConstantsPerSprite + numConstantsUsedForMatrix + 1,
                                                              Vector.<Number>([ offset.x, offset.y, 0.0, 1.0 ]));
                    }
                }
            }
            clearAfterRender(context);
        }

        override protected function clearAfterRender(context:Context3D):void {
            super.clearAfterRender(context);
            context.setTextureAt(0, null);
        }

        override protected function initProgram(context:Context3D):void {

            // program will be only created once and cached as static var in material
            if(!sprite2DCloudProgramData) {
                sprite2DCloudProgramData = new ProgramData(context, VertexProgramClass, MaterialVertexProgramClass,
                                                           MaterialFragmentProgramClass);
            }

            programData = sprite2DCloudProgramData;
        }

        override public function cleanUp():void {

            super.cleanUp();
            if(texture) {
                texture.dispose();
                texture = null;
            }
        }
    }
}
