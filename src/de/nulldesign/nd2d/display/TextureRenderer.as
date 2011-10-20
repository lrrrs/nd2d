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

    import de.nulldesign.nd2d.events.TextureEvent;
    import de.nulldesign.nd2d.materials.Texture2D;
    import de.nulldesign.nd2d.utils.StatsObject;
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;

    /**
     * Dispatched when the generated texture is created.
     * @eventType de.nulldesign.nd2d.events.TextureEvent.READY
     */
    [Event(name="textureReady", type="de.nulldesign.nd2d.events.TextureEvent")]

    public class TextureRenderer extends Node2D {

        protected var renderNode:Node2D;
        protected var texCamera:Camera2D = new Camera2D(1, 1);

        public var texture:Texture2D;

        private var cameraOffsetX:Number;
        private var cameraOffsetY:Number;

        public function TextureRenderer(renderNode:Node2D, textureWidth:Number, textureHeight:Number, cameraOffsetX:Number = NaN,
                                        cameraOffsetY:Number = NaN) {

            var size:Point = TextureHelper.getTextureDimensionsFromSize(textureWidth, textureHeight);

            texture = new Texture2D();
            texture.textureWidth = size.x;
            texture.textureHeight = size.y;
            texture.bitmapWidth = size.x;
            texture.bitmapHeight = size.y;

            this.renderNode = renderNode;
            _width = size.x;
            _height = size.y;
            this.cameraOffsetX = cameraOffsetX;
            this.cameraOffsetY = cameraOffsetY;

            texCamera.resizeCameraStage(width, height);
        }

        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            texture.texture = null;
        }

        override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

            if(!texture.texture) {
                texture.texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
                dispatchEvent(new TextureEvent(TextureEvent.READY));
            }

            context.setRenderToTexture(texture.texture, false, 2, 0);
            context.clear(0.0, 0.0, 0.0, 0.0);

            if(!isNaN(cameraOffsetX) && !isNaN(cameraOffsetY)) {
                texCamera.x = cameraOffsetX;
                texCamera.y = cameraOffsetY;
            } else {
                texCamera.x = renderNode.x - width * 0.5;
                texCamera.y = renderNode.y - height * 0.5;
            }

            var visibleState:Boolean = renderNode.visible;
            renderNode.visible = true;
            renderNode.drawNode(context, texCamera, parentMatrixChanged, statsObject);
            renderNode.visible = visibleState;

            context.setRenderToBackBuffer();
        }
    }
}
