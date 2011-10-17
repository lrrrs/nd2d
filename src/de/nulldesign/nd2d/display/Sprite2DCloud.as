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

package de.nulldesign.nd2d.display {

    import com.adobe.utils.AGALMiniAssembler;

    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.materials.ASpriteSheetBase;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.materials.Texture2D;
    import de.nulldesign.nd2d.materials.TextureAtlas;
    import de.nulldesign.nd2d.utils.StatsObject;
    import de.nulldesign.nd2d.utils.TextureHelper;
    import de.nulldesign.nd2d.utils.VectorUtil;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
     * Sprite2DCloud
     * Use a sprite cloud to batch sprites with the same Texture, SpriteSheet or TextureAtlas.
     * all sprites will be rendered in one single draw call. It will be fast ;)
     *
     * Limitations:
     * - Mouseevents are disabled and won't work for childs
     * - Reordering childs (add, remove) is very expensive. Try to avoid it! A Sprite2DBatch might work better in this case
	 * - Subchilds are not rendered. The cloud will only render it's own childs, you can't nest nodes deeper with a cloud.
     */
    public class Sprite2DCloud extends Node2D {

        protected var faceList:Vector.<Face>;
        protected var spriteSheet:ASpriteSheetBase;
        protected var texture:Texture2D;

        protected var v1:Vertex;
        protected var v2:Vertex;
        protected var v3:Vertex;
        protected var v4:Vertex;

        protected var uv1:UV;
        protected var uv2:UV;
        protected var uv3:UV;
        protected var uv4:UV;

        protected const numFloatsPerVertex:uint = 12;

        protected const DEFAULT_VERTEX_SHADER:String =
                "m44 op, va0, vc0   \n" + // vertex * clipspace
                        "mov v0, va1		\n" + // copy uv
                        "mov v1, va2		\n" + // copy colorMultiplier
                        "mov v2, va3		\n"; // copy colorOffset

        protected const DEFAULT_FRAGMENT_SHADER:String =
                "tex ft0, v0, fs0 <2d,clamp,linear,mipnearest>\n" + // sample texture from interpolated uv coords
                        "mul ft0, ft0, v1\n" + // mult with colorMultiplier
                        "add oc, ft0, v2\n";  // add with colorOffset

        protected static var program:Program3D;
        protected var indexBuffer:IndexBuffer3D;
        protected var vertexBuffer:VertexBuffer3D;
        protected var mVertexBuffer:Vector.<Number>;
        protected var mIndexBuffer:Vector.<uint>;
        protected var uvInited:Boolean = false;
        protected var maxCapacity:uint;

        protected var clipSpaceMatrix:Matrix3D = new Matrix3D();

        public function Sprite2DCloud(maxCapacity:uint, textureObject:Object) {

            if(textureObject is BitmapData) {
                texture = Texture2D.textureFromBitmapData(textureObject as BitmapData);
				trace("Setting constructor argument in a Sprite2DCloud as a BitmapData is depricated. Please pass a Texture2D object to the constructor. Create Texture2D object from a BitmapData by using the static method: Texture2D.textureFromBitmapData()");
            } else if(textureObject is Texture2D) {
                texture = textureObject as Texture2D;
            } else if(textureObject != null) {
                throw new Error("textureObject has to be a BitmapData or a Texture2D");
            }

            faceList = TextureHelper.generateQuadFromDimensions(2, 2);

            v1 = faceList[0].v1;
            v2 = faceList[0].v2;
            v3 = faceList[0].v3;
            v4 = faceList[1].v3;

            uv1 = faceList[0].uv1;
            uv2 = faceList[0].uv2;
            uv3 = faceList[0].uv3;
            uv4 = faceList[1].uv3;

            this.maxCapacity = maxCapacity;

            mVertexBuffer = new Vector.<Number>(maxCapacity * numFloatsPerVertex * 4, true);
            mIndexBuffer = new Vector.<uint>(maxCapacity * 6, true);
        }

        public function setSpriteSheet(value:ASpriteSheetBase):void {
            this.spriteSheet = value;
        }

        override public function get numTris():uint {
            return children.length * 2;
        }

        override public function get drawCalls():uint {
            return 1;
        }

        override public function addChildAt(child:Node2D, idx:uint):Node2D {

            if(child is Sprite2DCloud) {
                throw new Error("You can't nest Sprite2DClouds");
            }

            if(children.length < maxCapacity || getChildIndex(child) != -1) {

                super.addChildAt(child, idx);

                var c:Sprite2D = child as Sprite2D;

                // distribute spritesheets to sprites
                if(spriteSheet && !c.spriteSheet) {
                    c.spriteSheet = spriteSheet.clone();
                } else {
                    c.setTexture(texture);
                }

                for(var i:int = 0; i < children.length; i++) {
                    c = children[i] as Sprite2D;
                    c.invalidateColors = true;
                    c.invalidateMatrix = true;
                }
                uvInited = false;

                return child;
            }

            return null;
        }

        override public function removeChildAt(idx:uint):void {

            if(idx < children.length) {
                super.removeChildAt(idx);

                var c:Sprite2D;
                for(var i:int = 0; i < children.length; i++) {
                    c = children[i] as Sprite2D;
                    c.invalidateColors = true;
                    c.invalidateMatrix = true;
                }

                uvInited = false;
            }
        }

        override public function swapChildren(child1:Node2D, child2:Node2D):void {
            super.swapChildren(child1, child2);
            child1.invalidateColors = true;
            child1.invalidateMatrix = true;
            if(Sprite2D(child1).spriteSheet) {
                Sprite2D(child1).spriteSheet.frameUpdated = true;
            }

            child2.invalidateColors = true;
            child2.invalidateMatrix = true;
            if(Sprite2D(child2).spriteSheet) {
                Sprite2D(child2).spriteSheet.frameUpdated = true;
            }
        }


        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();

            texture.texture = null;
            program = null;
            vertexBuffer = null;
            indexBuffer = null;
            uvInited = false;

            var c:Sprite2D;
            for(var i:int = 0; i < children.length; i++) {
                c = children[i] as Sprite2D;
                c.invalidateColors = true;
                c.invalidateMatrix = true;
            }
        }

        override public function dispose():void {
            super.dispose();
            if(program) {
                program.dispose();
                program = null;
            }
            if(vertexBuffer) {
                vertexBuffer.dispose();
                vertexBuffer = null;
            }
            if(indexBuffer) {
                indexBuffer.dispose();
                indexBuffer = null;
            }
        }

        override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

            if(!visible) {
                return;
            }

            var myMatrixChanged:Boolean = false;

            if(invalidateMatrix) {
                updateLocalMatrix();
                myMatrixChanged = true;
            }

            if(parentMatrixChanged || myMatrixChanged) {
                updateWorldMatrix();
            }

            draw(context, camera);
            statsObject.totalDrawCalls += drawCalls;
            statsObject.totalTris += numTris;
        }

        override protected function draw(context:Context3D, camera:Camera2D):void {

            if(children.length == 0) return;

            clipSpaceMatrix.identity();
            clipSpaceMatrix.append(worldModelMatrix);
            clipSpaceMatrix.append(camera.getViewProjectionMatrix());

            if(!program) {
                var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER);

                var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, DEFAULT_FRAGMENT_SHADER);

                program = context.createProgram();
                program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
            }

            var vIdx:uint = 0;
            var rMultiplier:Number;
            var gMultiplier:Number;
            var bMultiplier:Number;
            var aMultiplier:Number;
            var rOffset:Number;
            var gOffset:Number;
            var bOffset:Number;
            var aOffset:Number;
            var uvOffsetAndScale:Rectangle = new Rectangle(0.0, 0.0, 1.0, 1.0);
            var rot:Number;
            var cr:Number;
            var sr:Number;
            var i:int = -1;
            var child:Sprite2D;
            var n:uint = children.length;
            var sx:Number;
            var sy:Number;
            var somethingChanged:Boolean = false;
            var atlasOffset:Point = new Point();
            var pivot:Point;
            var offsetFactor:Number = 1.0 / 255.0;

            if(invalidateColors) {
                updateColors();
                invalidateColors = true;
            }

            while(++i < n) {

                child = Sprite2D(children[i]);

                spriteSheet = child.spriteSheet;

                if(invalidateColors || child.invalidateColors) {
                    child.updateColors();
                    child.invalidateColors = true;
                }

                rMultiplier = child.combinedColorTransform.redMultiplier;
                gMultiplier = child.combinedColorTransform.greenMultiplier;
                bMultiplier = child.combinedColorTransform.blueMultiplier;
                aMultiplier = child.visible ? child.combinedColorTransform.alphaMultiplier : 0.0; // fake visibility. just set alpha to zero, it's faster
                rOffset = child.combinedColorTransform.redOffset * offsetFactor;
                gOffset = child.combinedColorTransform.greenOffset * offsetFactor;
                bOffset = child.combinedColorTransform.blueOffset * offsetFactor;
                aOffset = child.visible ? child.combinedColorTransform.alphaOffset * offsetFactor : 0.0; // fake visibility. just set alpha to zero, it's faster

                sx = child.scaleX;
                sy = child.scaleY;

                if(spriteSheet) {
                    sx *= spriteSheet.spriteWidth * 0.5;
                    sy *= spriteSheet.spriteHeight * 0.5;
                    atlasOffset = spriteSheet.getOffsetForFrame();
                } else {
                    sx *= texture.textureWidth * 0.5;
                    sy *= texture.textureHeight * 0.5;
                    atlasOffset.x = 0.0;
                    atlasOffset.y = 0.0;
                }

                var initUV:Boolean = !uvInited;

                if(spriteSheet && (spriteSheet.frameUpdated || initUV)) {
                    spriteSheet.frameUpdated = false;
                    initUV = true;
                    uvOffsetAndScale = spriteSheet.getUVRectForFrame(texture.textureWidth, texture.textureHeight);
                }

                if(child.invalidateMatrix) {
                    rot = VectorUtil.deg2rad(child.rotation);
                    cr = Math.cos(rot);
                    sr = Math.sin(rot);

                    pivot = child.pivot;
                }

                // v1
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx] = (v1.x * sx - pivot.x) * cr - (v1.y * sy - pivot.y) * sr + child.x + atlasOffset.x;
                    mVertexBuffer[vIdx + 1] = (v1.x * sx - pivot.x) * sr + (v1.y * sy - pivot.y) * cr + child.y + atlasOffset.y;
                    somethingChanged = true;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 2] = uvOffsetAndScale.width * uv1.u + uvOffsetAndScale.x;
                    mVertexBuffer[vIdx + 3] = uvOffsetAndScale.height * uv1.v + uvOffsetAndScale.y;
                    somethingChanged = true;
                }

                if(invalidateColors || child.invalidateColors || child.invalidateVisibility) {
                    mVertexBuffer[vIdx + 4] = rMultiplier;
                    mVertexBuffer[vIdx + 5] = gMultiplier;
                    mVertexBuffer[vIdx + 6] = bMultiplier;
                    mVertexBuffer[vIdx + 7] = aMultiplier;
                    mVertexBuffer[vIdx + 8] = rOffset;
                    mVertexBuffer[vIdx + 9] = gOffset;
                    mVertexBuffer[vIdx + 10] = bOffset;
                    mVertexBuffer[vIdx + 11] = aOffset;
                    somethingChanged = true;
                }

                // v2
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 12] = (v2.x * sx - pivot.x) * cr - (v2.y * sy - pivot.y) * sr + child.x + atlasOffset.x;
                    mVertexBuffer[vIdx + 13] = (v2.x * sx - pivot.x) * sr + (v2.y * sy - pivot.y) * cr + child.y + atlasOffset.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 14] = uvOffsetAndScale.width * uv2.u + uvOffsetAndScale.x;
                    mVertexBuffer[vIdx + 15] = uvOffsetAndScale.height * uv2.v + uvOffsetAndScale.y;
                }

                if(invalidateColors || child.invalidateColors || child.invalidateVisibility) {
                    mVertexBuffer[vIdx + 16] = rMultiplier;
                    mVertexBuffer[vIdx + 17] = gMultiplier;
                    mVertexBuffer[vIdx + 18] = bMultiplier;
                    mVertexBuffer[vIdx + 19] = aMultiplier;
                    mVertexBuffer[vIdx + 20] = rOffset;
                    mVertexBuffer[vIdx + 21] = gOffset;
                    mVertexBuffer[vIdx + 22] = bOffset;
                    mVertexBuffer[vIdx + 23] = aOffset;
                }

                // v3
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 24] = (v3.x * sx - pivot.x) * cr - (v3.y * sy - pivot.y) * sr + child.x + atlasOffset.x;
                    mVertexBuffer[vIdx + 25] = (v3.x * sx - pivot.x) * sr + (v3.y * sy - pivot.y) * cr + child.y + atlasOffset.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 26] = uvOffsetAndScale.width * uv3.u + uvOffsetAndScale.x;
                    mVertexBuffer[vIdx + 27] = uvOffsetAndScale.height * uv3.v + uvOffsetAndScale.y;
                }

                if(invalidateColors || child.invalidateColors || child.invalidateVisibility) {
                    mVertexBuffer[vIdx + 28] = rMultiplier;
                    mVertexBuffer[vIdx + 29] = gMultiplier;
                    mVertexBuffer[vIdx + 30] = bMultiplier;
                    mVertexBuffer[vIdx + 31] = aMultiplier;
                    mVertexBuffer[vIdx + 32] = rOffset;
                    mVertexBuffer[vIdx + 33] = gOffset;
                    mVertexBuffer[vIdx + 34] = bOffset;
                    mVertexBuffer[vIdx + 35] = aOffset;
                }

                // v4
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 36] = (v4.x * sx - pivot.x) * cr - (v4.y * sy - pivot.y) * sr + child.x + atlasOffset.x;
                    mVertexBuffer[vIdx + 37] = (v4.x * sx - pivot.x) * sr + (v4.y * sy - pivot.y) * cr + child.y + atlasOffset.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 38] = uvOffsetAndScale.width * uv4.u + uvOffsetAndScale.x;
                    mVertexBuffer[vIdx + 39] = uvOffsetAndScale.height * uv4.v + uvOffsetAndScale.y;
                }

                if(invalidateColors || child.invalidateColors || child.invalidateVisibility) {
                    mVertexBuffer[vIdx + 40] = rMultiplier;
                    mVertexBuffer[vIdx + 41] = gMultiplier;
                    mVertexBuffer[vIdx + 42] = bMultiplier;
                    mVertexBuffer[vIdx + 43] = aMultiplier;
                    mVertexBuffer[vIdx + 44] = rOffset;
                    mVertexBuffer[vIdx + 45] = gOffset;
                    mVertexBuffer[vIdx + 46] = bOffset;
                    mVertexBuffer[vIdx + 47] = aOffset;
                }

                vIdx += 48;

                child.invalidateMatrix = child.invalidateColors = child.invalidateVisibility = false;
            }

            invalidateColors = false;
            uvInited = true;

            if(!vertexBuffer) {
                vertexBuffer = context.createVertexBuffer(mVertexBuffer.length / numFloatsPerVertex, numFloatsPerVertex);
            }

            // reupload changed vertexbuffer...
            if(somethingChanged) {
                vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / numFloatsPerVertex);
            }

            if(!indexBuffer) {

                var refIdx:uint = 0;
                var iIdx:uint = 0;
                var idx:int = -1;

                while(++idx < maxCapacity) {
                    mIndexBuffer[iIdx] = refIdx;
                    mIndexBuffer[iIdx + 1] = refIdx + 1;
                    mIndexBuffer[iIdx + 2] = refIdx + 2;
                    mIndexBuffer[iIdx + 3] = refIdx + 2;
                    mIndexBuffer[iIdx + 4] = refIdx + 3;
                    mIndexBuffer[iIdx + 5] = refIdx;

                    refIdx += 4;
                    iIdx += 6;
                }

                indexBuffer = context.createIndexBuffer(mIndexBuffer.length);
                indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer.length);
            }

            context.setTextureAt(0, texture.getTexture(context, true));
            context.setProgram(program);
            context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
            context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
            context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // colorMultiplier
            context.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4); // colorOffset

            context.setBlendFactors(blendMode.src, blendMode.dst);

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

            context.drawTriangles(indexBuffer, 0, 2 * children.length);

            context.setTextureAt(0, null);

            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
            context.setVertexBufferAt(3, null);
        }
    }
}