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

    /**
     * <p>Baseclass for ND2D</p>
     * Extend this class and add your own scenes and sprites
     *
     * Set up your project like this:
     * <ul>
     * <li>MyGameWorld2D</li>
     * <li>- MyStartScene2D</li>
     * <li>-- StartButtonSprite2D</li>
     * <li>-- ...</li>
     * <li>- MyGameScene2D</li>
     * <li>-- GameSprites2D</li>
     * <li>-- ...</li>
     * </ul>
     * <p>Put your game logic in the step() method of each scene / node</p>
     *
     * You can switch between scenes with the setActiveScene method of World2D.
     * There can be only one active scene.
     *
     */
    public class World2D extends Sprite {

        protected var camera:Camera2D = new Camera2D(1, 1);
        protected var context3D:Context3D;

        private var stageID:uint;
        private var renderTimer:Timer;
        private var renderMode:String;
        private var scene:Scene2D;
        private var frameRate:uint;
        private var isPaused:Boolean = false;
        private var mousePosition:Vector3D = new Vector3D(0.0, 0.0, 0.0);
        private var antialiasing:uint = 2;
        private var bounds:Rectangle;
        private var frameBased:Boolean;

        private var deviceInitialized:Boolean = false;
        private var deviceWasLost:Boolean = false;

        protected var stats:Stats;
        protected var lastFramesTime:Number = 0.0;
        protected var enableErrorChecking:Boolean = false;

        private var _statsVisible:Boolean = true;

        public function get statsVisible():Boolean {
            return _statsVisible;
        }

        public function set statsVisible(value:Boolean):void {
            _statsVisible = value;
            stats.visible = statsVisible;
        }

        /**
         * Constructor of class world
         * @param renderMode Context3DRenderMode (auto, software)
         * @param frameRate timer and the swf will be set to this framerate
         * @param frameBased whether to use a timer or a enterFrame to step()
         * @param bounds the worlds boundaries
         * @param stageID
         */
        public function World2D(renderMode:String, frameRate:uint, frameBased:Boolean, bounds:Rectangle = null,
                                stageID:uint = 0) {

            this.renderMode = renderMode;
            this.frameRate = frameRate;
            this.bounds = bounds;
            this.frameBased = frameBased;
            this.stageID = stageID;
            this.stats = Stats(addChild(new Stats()));
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        private function addedToStage(event:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            stage.addEventListener(Event.RESIZE, resizeStage);
            stage.frameRate = frameRate;
            stage.stage3Ds[stageID].addEventListener(Event.CONTEXT3D_CREATE, context3DCreated);
            stage.stage3Ds[stageID].requestContext3D(renderMode);

            stage.addEventListener(MouseEvent.CLICK, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
        }

        private function context3DCreated(e:Event):void {

            //stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, context3DCreated);

            context3D = stage.stage3Ds[stageID].context3D;
            context3D.enableErrorChecking = enableErrorChecking;
            context3D.setCulling(Context3DTriangleFace.NONE);
            context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);

            resizeStage();

            stats.driverInfo = context3D.driverInfo;

            // means we got the Event.CONTEXT3D_CREATE for the second time, the device was lost. reinit everything
            if(deviceInitialized) {
                deviceWasLost = true;
            }

            if(frameBased) {
                removeEventListener(Event.ENTER_FRAME, timerEventHandler);
                addEventListener(Event.ENTER_FRAME, timerEventHandler);
            } else {
                if(!renderTimer) {
                    renderTimer = new Timer(1000 / frameRate);
                    renderTimer.addEventListener(TimerEvent.TIMER, timerEventHandler);
                    renderTimer.start();
                }
            }

            deviceInitialized = true;
        }

        private function mouseEventHandler(event:MouseEvent):void {
            if(scene && scene.mouseEnabled && stage && camera) {
                var mouseEventType:String = event.type;

                // transformation of normalized coordinates between -1 and 1
                mousePosition.x = (stage.mouseX - 0.0) / camera.sceneWidth * 2.0 - 1.0;
                mousePosition.y = -((stage.mouseY - 0.0) / camera.sceneHeight * 2.0 - 1.0);
                mousePosition.z = 0.0;
                mousePosition.w = 1.0;

                scene.processMouseEvents(mousePosition, mouseEventType, camera.getViewProjectionMatrix());
            }
        }

        protected function resizeStage(e:Event = null):void {
            if(!context3D) return;
            var rect:Rectangle = bounds ? bounds : new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
            stage.stage3Ds[stageID].viewPort = rect;
            context3D.configureBackBuffer(rect.width, rect.height, antialiasing, false);
            camera.resizeCameraStage(rect.width, rect.height);
        }

        protected function timerEventHandler(e:Event):void {
            var t:Number = getTimer() / 1000;
            var elapsed:Number = t - lastFramesTime;

            if(scene) {
                context3D.clear(scene.br, scene.bg, scene.bb, 1.0);

                if(!isPaused)
                {
                    scene.timeSinceStartInSeconds = t;
                    scene.stepNode(elapsed);
                }

                scene.drawNode(context3D, camera, false, deviceWasLost);

                context3D.present();

                deviceWasLost = false;
            }

            lastFramesTime = t;
        }

        protected function setActiveScene(value:Scene2D):void {

            if(scene) {
                scene.setStageRef(null);
                scene.setCameraRef(null);
                scene.statsRef = null;
            }

            this.scene = value;

            if(scene) {
                scene.statsRef = stats;
                scene.setCameraRef(camera);
                scene.setStageRef(stage);
            }
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