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
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.Texture;

    public class TextureRenderer extends Node2D {

        protected var renderNode:Node2D;
        protected var texCamera:Camera2D = new Camera2D(1, 1);

        public var texture:Texture;

        public function TextureRenderer(renderNode:Node2D, textureWidth:Number, textureHeight:Number) {
            this.renderNode = renderNode;
            _width = textureWidth;
            _height = textureHeight;
        }

        override internal function drawNode(context:Context3D, camera:Camera2D):void {

            if(!texture) {
                texture = context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
            }

            context.setRenderToTexture(texture, false, 2, 0);
            context.clear(0.0, 0.0, 0.0, 0.0);

            texCamera.resizeCameraStage(width, height);
            texCamera.x = -renderNode.x + width * 0.5;
            texCamera.y = -renderNode.y + height * 0.5;

            renderNode.drawNode(context, texCamera);

            context.setRenderToBackBuffer();
        }
    }
}
