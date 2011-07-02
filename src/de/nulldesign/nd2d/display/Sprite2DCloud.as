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

package de.nulldesign.nd2d.display {

    import com.adobe.utils.AGALMiniAssembler;

    import de.nulldesign.nd2d.geom.UV;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.materials.Sprite2DMaterial;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.TextureHelper;
    import de.nulldesign.nd2d.utils.VectorUtil;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.geom.Point;

    /**
     * Sprite2DCloud
     * Use a sprite cloud to batch sprites with the same texture / spritesheet.
     * all sprites will be batched in one single draw call
     * Mouseevents are disabled and won't work for spriteclouds
     */
    public class Sprite2DCloud extends Sprite2D {

        protected var v1:Vertex;
        protected var v2:Vertex;
        protected var v3:Vertex;
        protected var v4:Vertex;

        protected var uv1:UV;
        protected var uv2:UV;
        protected var uv3:UV;
        protected var uv4:UV;

        protected const DEFAULT_VERTEX_SHADER:String = "m44 op, va0, vc0   \n" + // vertex * clipspace
                "mov v0, va1		\n" + // copy uv
                "mov v1, va2		\n"; // copy color

        protected const DEFAULT_FRAGMENT_SHADER:String = "mov ft0, v0\n" + // get interpolated uv coords
                "tex ft1, ft0, fs0 <2d,clamp,linear>\n" + // sample texture
                "mul ft1, ft1, v1\n" + // mult with color
                "mov oc, ft1\n";

        protected var program:Program3D;
        protected var indexBuffer:IndexBuffer3D;
        protected var vertexBuffer:VertexBuffer3D;
        protected var mVertexBuffer:Vector.<Number>;
        protected var mIndexBuffer:Vector.<uint>;
        protected var uvInited:Boolean = false;
        protected var maxCapacity:uint;

        protected var clipSpaceMatrix:Matrix3D = new Matrix3D();

        public function Sprite2DCloud(maxCapacity:uint, bitmapTexture:BitmapData = null,
                                      spriteSheet:SpriteSheet = null) {
            super(bitmapTexture, spriteSheet);
            this.maxCapacity = maxCapacity;

            mVertexBuffer = new Vector.<Number>(maxCapacity * 8 * 4, true);
            mIndexBuffer = new Vector.<uint>(maxCapacity * 6, true);
        }

        override public function get numTris():uint {
            return children.length * 2;
        }

        override public function get drawCalls():uint {
            return material.drawCalls;
        }

        override protected function setMaterial(material:Sprite2DMaterial):void {
            super.setMaterial(material);

            // kinda hackish ...
            v1 = faceList[0].v1;
            v2 = faceList[0].v2;
            v3 = faceList[0].v3;
            v4 = faceList[1].v3;

            uv1 = faceList[0].uv1;
            uv2 = faceList[0].uv2;
            uv3 = faceList[0].uv3;
            uv4 = faceList[1].uv3;
        }

        override public function addChildAt(child:Node2D, idx:uint):Node2D {

            if(child is Sprite2DCloud) {
                throw new Error("You can't nest Sprite2DClouds");
            }

            if(getChildIndex(child) != -1) {
                removeChild(child);
            }

            if(children.length < maxCapacity) {

                super.addChildAt(child, idx);

                var c:Sprite2D = child as Sprite2D;
                // set w/h of sprite
                c.setTexture(null, width, height);

                // distribute spritesheets to sprites
                if(c && spriteSheet && !c.spriteSheet) {
                    c.spriteSheet = spriteSheet.clone();
                }
                return child;
            }

            return null;
        }

        override internal function drawNode(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            if(!visible) {
                return;
            }

            if(invalidateMatrix) {
                updateMatrix();
            }

            worldModelMatrix.identity();
            worldModelMatrix.append(localModelMatrix);

            if(parent) {
                worldModelMatrix.append(parent.worldModelMatrix);
            }

            if(handleDeviceLoss) {
                material.texture = null;
                program = null;
                vertexBuffer = null;
                indexBuffer = null;
                uvInited = false;
            }

            draw(context, camera, handleDeviceLoss);
        }

        override protected function draw(context:Context3D, camera:Camera2D, handleDeviceLoss:Boolean):void {

            if(!material.texture) {
                material.texture = TextureHelper.generateTextureFromBitmap(context, material.bitmapData, true);
            }

            if(!program) {
                var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, DEFAULT_VERTEX_SHADER);

                var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, DEFAULT_FRAGMENT_SHADER);

                program = context.createProgram();
                program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
            }

            var vIdx:uint = 0;
            var r:Number;
            var g:Number;
            var b:Number;
            var a:Number;
            var offset:Point;
            var rot:Number;
            var cr:Number;
            var sr:Number;
            var i:int = -1;
            var child:Sprite2D;
            var n:uint = children.length;
            var sx:Number;
            var sy:Number;
            var somethingChanged:Boolean = false;

            if(invalidateColors) {
                updateColors();
                invalidateColors = true;
            }

            // TODO: get rid of this implementation and do batch rendering! :)
            while(++i < n) {

                child = Sprite2D(children[i]);

                spriteSheet = child.spriteSheet;

                if(invalidateColors || child.invalidateColors) {
                    child.updateColors();
                    child.invalidateColors = true;
                }

                r = child.r;
                g = child.g;
                b = child.b;
                a = child.visible ? child.a : 0.0; // fake visibility for now ... it's faster

                offset = new Point();
                sx = child.scaleX;
                sy = child.scaleY;

                var initUV:Boolean = !uvInited;

                if(spriteSheet && spriteSheet.frameUpdated) {

                    spriteSheet.frameUpdated = false;
                    initUV = true;
                    offset = spriteSheet.getOffsetForFrame();
                }

                if(child.invalidateMatrix) {
                    rot = VectorUtil.deg2rad(child.rotation);
                    cr = Math.cos(rot);
                    sr = Math.sin(rot);
                }

                // v1
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx] = v1.x * sx * cr - v1.y * sy * sr + child.x;
                    mVertexBuffer[vIdx + 1] = v1.x * sx * sr + v1.y * sy * cr + child.y;
                    somethingChanged = true;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 2] = uv1.u + offset.x; // u
                    mVertexBuffer[vIdx + 3] = uv1.v + offset.y; // v
                    somethingChanged = true;
                }

                if(invalidateColors || child.invalidateColors) {
                    mVertexBuffer[vIdx + 4] = r; // r
                    mVertexBuffer[vIdx + 5] = g; // g
                    mVertexBuffer[vIdx + 6] = b; // b
                    mVertexBuffer[vIdx + 7] = a; // a
                    somethingChanged = true;
                }

                // v2
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 8] = v2.x * sx * cr - v2.y * sy * sr + child.x;
                    mVertexBuffer[vIdx + 9] = v2.x * sx * sr + v2.y * sy * cr + child.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 10] = uv2.u + offset.x; // u
                    mVertexBuffer[vIdx + 11] = uv2.v + offset.y; // v
                }

                if(invalidateColors || child.invalidateColors) {
                    mVertexBuffer[vIdx + 12] = r; // r
                    mVertexBuffer[vIdx + 13] = g; // g
                    mVertexBuffer[vIdx + 14] = b; // b
                    mVertexBuffer[vIdx + 15] = a; // a
                }

                // v3
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 16] = v3.x * sx * cr - v3.y * sy * sr + child.x;
                    mVertexBuffer[vIdx + 17] = v3.x * sx * sr + v3.y * sy * cr + child.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 18] = uv3.u + offset.x; // u
                    mVertexBuffer[vIdx + 19] = uv3.v + offset.y; // v
                }

                if(invalidateColors || child.invalidateColors) {
                    mVertexBuffer[vIdx + 20] = r; // r
                    mVertexBuffer[vIdx + 21] = g; // g
                    mVertexBuffer[vIdx + 22] = b; // b
                    mVertexBuffer[vIdx + 23] = a; // a
                }

                // v4
                if(child.invalidateMatrix) {
                    mVertexBuffer[vIdx + 24] = v4.x * sx * cr - v4.y * sy * sr + child.x;
                    mVertexBuffer[vIdx + 25] = v4.x * sx * sr + v4.y * sy * cr + child.y;
                }

                if(initUV) {
                    mVertexBuffer[vIdx + 26] = uv4.u + offset.x; // u
                    mVertexBuffer[vIdx + 27] = uv4.v + offset.y; // v
                }

                if(invalidateColors || child.invalidateColors) {
                    mVertexBuffer[vIdx + 28] = r; // r
                    mVertexBuffer[vIdx + 29] = g; // g
                    mVertexBuffer[vIdx + 30] = b; // b
                    mVertexBuffer[vIdx + 31] = a; // a
                }

                vIdx += 32;

                child.invalidateMatrix = child.invalidateColors = false;
            }

            invalidateColors = false;
            uvInited = true;

            if(!vertexBuffer) {
                vertexBuffer = context.createVertexBuffer(mVertexBuffer.length / 8, 8);
            }

            // reupload changed vertexbuffer every frame...
            if(somethingChanged) {
                vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / 8);
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

            context.setTextureAt(0, material.texture);
            context.setProgram(program);
            context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
            context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
            context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // color

            context.setBlendFactors(blendMode.src, blendMode.dst);

            clipSpaceMatrix.identity();
            clipSpaceMatrix.append(worldModelMatrix);
            clipSpaceMatrix.append(camera.getViewProjectionMatrix());

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);

            context.drawTriangles(indexBuffer, 0, 2 * children.length);

            context.setTextureAt(0, null);

            context.setVertexBufferAt(0, null); // vertex
            context.setVertexBufferAt(1, null); // uv
            context.setVertexBufferAt(2, null); // color
        }
    }
}