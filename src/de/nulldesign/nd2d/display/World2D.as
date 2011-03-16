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

package de.nulldesign.nd2d.display {
    import flash.display.Sprite;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import net.hires.debug.Stats;

    public class World2D extends Sprite {

        protected var camera:Camera2D;

        private var renderTimer:Timer;
        private var context3D:Context3D;
        private var renderMode:String;
        private var scene:Scene2D;
        private var frameRate:uint;
        private var isPaused:Boolean = false;
        private var mousePosition:Vector3D = new Vector3D(0.0, 0.0, 0.0);

        protected var stats:Stats;

        private var _backGroundColor:Number = 0x000000;
        private var br:Number = 0.0;
        private var bg:Number = 0.0;
        private var bb:Number = 0.0;

        private var _statsVisible:Boolean = true;

        public function get statsVisible():Boolean {
            return _statsVisible;
        }

        public function set statsVisible(value:Boolean):void {
            _statsVisible = value;
            stats.visible = statsVisible;
        }

        public function get backGroundColor():Number {
            return _backGroundColor;
        }

        public function set backGroundColor(value:Number):void {
            _backGroundColor = value;
            br = (backGroundColor >> 16) / 255.0;
            bg = (backGroundColor >> 8 & 255) / 255.0;
            bb = (backGroundColor & 255) / 255.0;
        }

        public function World2D(renderMode:String, frameRate:uint) {
            this.renderMode = renderMode;
            this.scene = new Scene2D();
            this.frameRate = frameRate;
            this.stats = Stats(addChild(new Stats()));
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        protected function addedToStage(event:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            stage.addEventListener(Event.RESIZE, resizeStage);
            stage.frameRate = frameRate;
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3DCreated);
            stage.stage3Ds[0].requestContext3D(renderMode);

            stage.addEventListener(MouseEvent.CLICK, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
        }

        protected function context3DCreated(e:Event):void {

            context3D = stage.stage3Ds[0].context3D;
            context3D.enableErrorChecking = true;
            context3D.setCulling(Context3DTriangleFace.NONE);
            context3D.setDepthTest(false, Context3DCompareMode.LESS_EQUAL);

            stage.stage3Ds[0].viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);

            camera = new Camera2D(stage.stageWidth, stage.stageHeight);
            stats.driverInfo = context3D.driverInfo;

            renderTimer = new Timer(1000 / frameRate);
            renderTimer.addEventListener(TimerEvent.TIMER, timerEventHandler);
            renderTimer.start();

            addEventListener(Event.ENTER_FRAME, draw);
            step(0);
        }

        protected function resizeStage(e:Event):void {
            stage.stage3Ds[0].viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, false);
            camera = new Camera2D(stage.stageWidth, stage.stageHeight);
        }

        private function mouseEventHandler(event:MouseEvent):void {
            if(scene && stage && camera) {
                var mouseEventType:String = event.type;
                mousePosition.x = stage.mouseX;
                mousePosition.y = stage.mouseY;

                // transformation of normalized coordinates between -1 and 1
                mousePosition.x = (mousePosition.x - 0.0) / camera.sceneWidth * 2.0 - 1.0;
                mousePosition.y = -((mousePosition.y - 0.0) / camera.sceneHeight * 2.0 - 1.0);
                mousePosition.z = 0.0;
                mousePosition.w = 1.0;

                scene.processMouseEvents(mousePosition, mouseEventType, camera);
            }
        }

        private function timerEventHandler(event:Event):void {
            var t:Number = getTimer() / 1000;

            if(isPaused) return;

            step(t);

            if(scene) {
                scene.stepNode(t);
            }
        }

        protected function step(t:Number):void {
            // overwrite and do your movement here
        }

        protected function draw(event:Event):void {
            context3D.clear(br, bg, bb, 1.0);

            if(scene) {
                scene.drawNode(context3D, camera);
            }

            context3D.present();
        }

        protected function setActiveScene(scene:Scene2D):void {
            this.scene = scene
            scene.statsRef = stats;
        }

        protected function pause():void {
            isPaused = true;
        }

        protected function resume():void {
            isPaused = false;
        }

        public function destroy():void {
            // TODO
        }
    }
}