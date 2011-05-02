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

/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 02.05.11 15:06
 */
package tests {
    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.utils.NumberUtil;

    import flash.events.Event;
    import flash.events.MouseEvent;

    public class CameraTest extends Scene2D {

        [Embed(source="/assets/water_texture.jpg")]
        private var backgroundTexture:Class;

        [Embed(source="/assets/nd_logo.png")]
        private var spriteTexture:Class;

        private var back:Sprite2D;
        private var targetNode:Node2D;

        public function CameraTest() {

            back = new Sprite2D(new backgroundTexture().bitmapData);
            back.alpha = 0.5;
            addChild(back);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        private function addedToStage(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            for(var i:int = 0; i < 5; i++) {
                var s:Sprite2D = new Sprite2D(new spriteTexture().bitmapData);
                s.x = NumberUtil.rndMinMax(100.0, stage.stageWidth - 100.0);
                s.y = NumberUtil.rndMinMax(100.0, stage.stageHeight - 100.0);
                s.rotation = NumberUtil.rndMinMax(0.0, 360.0);
                s.mouseEnabled = true;
                s.addEventListener(MouseEvent.CLICK, spriteClick);
                addChild(s);
            }
        }

        private function spriteClick(e:MouseEvent):void {
            targetNode = Node2D(e.target);
        }

        override protected function step(t:Number, elapsed:Number):void {
            back.x = camera.sceneWidth * 0.5;
            back.y = camera.sceneHeight * 0.5;
            back.width = camera.sceneWidth * 5.0;
            back.height = camera.sceneHeight * 5.0;

            if(targetNode) {
                camera.x += ((-targetNode.x + camera.sceneWidth * 0.5) - camera.x) * 0.05;
                camera.y += ((-targetNode.y + camera.sceneHeight * 0.5) - camera.y) * 0.05;
                camera.rotation += (-targetNode.rotation - camera.rotation) * 0.05;
            }
        }
    }
}
