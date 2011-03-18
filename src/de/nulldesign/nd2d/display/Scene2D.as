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
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.events.Event;

    import net.hires.debug.Stats;

    [Event(name="addedToStage", type="flash.events.Event")]
    [Event(name="removedFromStage", type="flash.events.Event")]

    /**
     * A scene that can contain 2D nodes
     */
    public class Scene2D extends Node2D {

        public var statsRef:Stats;
        protected var stage:Stage;
        protected var camera:Camera2D;

        public function Scene2D() {
            super();
            mouseEnabled = true;
        }

        internal function setCameraRef(value:Camera2D):void {
            camera = value;
        }

        internal function setStageRef(value:Stage):void {
            stage = value;
            if(stage) {
                dispatchEvent(new Event(Event.ADDED_TO_STAGE));
            } else {
                dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
            }
        }

        override internal function drawNode(context:Context3D, camera:Camera2D):void {

            var totalTris:int = 0;
            var drawCalls:int = 0;

            for each(var child:Node2D in children) {
                child.drawNode(context, camera);
                totalTris += child.numTris;
                drawCalls += 1;
            }

            if(statsRef)
                statsRef.update(drawCalls, totalTris);
        }
    }
}