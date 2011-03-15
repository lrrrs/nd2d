/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.display {
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.utils.NodeBlendMode;

    import flash.display3D.Context3D;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.media.Camera;
    import flash.utils.getTimer;

    public class Node2D extends EventDispatcher {

        public var modelMatrix:Matrix3D = new Matrix3D();
        public var modelViewMatrix:Matrix3D = new Matrix3D();
        public var children:Vector.<Node2D> = new Vector.<Node2D>();
        public var parent:Node2D;

        public var vx:Number = 0.0;
        public var vy:Number = 0.0;

        public var refreshPosition:Boolean = true;
        public var refreshColors:Boolean = true;

        public var blendMode:NodeBlendMode = BlendModePresets.NORMAL;

        public var mouseEnabled:Boolean = false;

        protected var localMouse:Vector3D;
        protected var mouseInNode:Boolean = false;

        protected var _width:Number;

        public function get width():Number {
            return _width;
        }

        protected var _height:Number;

        public function get height():Number {
            return _height;
        }

        protected var _visible:Boolean = true;

        public function get visible():Boolean {
            return _visible;
        }

        public function set visible(value:Boolean):void {
            _visible = value;
        }

        protected var _alpha:Number = 1.0;

        public function set alpha(value:Number):void {
            _alpha = value;
            refreshColors = true;
        }

        public function get alpha():Number {
            return _alpha;
        }

        protected var _a:Number = 1.0;

        public function get a():Number {
            return _a;
        }

        protected var _r:Number = 1.0;

        public function get r():Number {
            return _r;
        }

        protected var _g:Number = 1.0;

        public function get g():Number {
            return _g;
        }

        protected var _b:Number = 1.0;

        public function get b():Number {
            return _b;
        }

        protected var _tint:Number = 0xFFFFFF;

        public function set tint(value:Number):void {
            _tint = value;
            refreshColors = true;
        }

        public function get tint():Number {
            return _tint;
        }

        protected var _scaleX:Number = 1.0;

        public function set scaleX(value:Number):void {
            _scaleX = value;
            refreshPosition = true;
        }

        public function get scaleX():Number {
            return _scaleX;
        }

        protected var _scaleY:Number = 1.0;

        public function set scaleY(value:Number):void {
            _scaleY = value;
            refreshPosition = true;
        }

        public function get scaleY():Number {
            return _scaleY;
        }

        protected var _x:Number = 0.0;

        public function set x(value:Number):void {
            _x = value;
            position.x = x;
            refreshPosition = true;
        }

        public function get x():Number {
            return _x;
        }

        protected var _y:Number = 0.0;

        public function set y(value:Number):void {
            _y = value;
            position.y = y;
            refreshPosition = true;
        }

        public function get y():Number {
            return _y;
        }

        protected var _position:Point = new Point(0.0, 0.0);

        public function get position():Point {
            return _position;
        }

        public function set position(value:Point):void {
            _position = value;
            x = _position.x;
            y = _position.y;
        }

        protected var _pivot:Point = new Point(0.0, 0.0);

        public function get pivot():Point {
            return _pivot;
        }

        public function set pivot(value:Point):void {
            _pivot = value;
            refreshPosition = true;
        }

        protected var _rotation:Number = 0.0;

        public function set rotation(value:Number):void {
            _rotation = value;
            refreshPosition = true;
        }

        public function get rotation():Number {
            return _rotation;
        }

        public function get numTris():int {
            return 0;
        }

        public function Node2D() {
        }

        protected function refreshMatrix():void {
            refreshPosition = false;
            modelMatrix.identity();
            modelMatrix.appendTranslation(-pivot.x, -pivot.y, 0);
            modelMatrix.appendScale(scaleX, scaleY, 1.0);
            modelMatrix.appendRotation(rotation, Vector3D.Z_AXIS);
            modelMatrix.appendTranslation(x, y, 0.0);
        }

        protected function updateColors():void {

            refreshColors = false;

            _r = (tint >> 16) / 255.0;
            _g = (tint >> 8 & 255) / 255.0;
            _b = (tint & 255) / 255.0;
            _a = alpha;

            if (parent) {
                _r *= parent.r;
                _g *= parent.g;
                _b *= parent.b;
                _a *= parent.a;
            }
        }

        internal function drawNode(context:Context3D, camera:Camera2D):void {

            if (!visible) {
                return;
            }

            if (refreshPosition) {
                refreshMatrix();
            }

            modelViewMatrix.identity();
            modelViewMatrix.append(modelMatrix);

            if (parent) {
                modelViewMatrix.append(parent.modelViewMatrix);
            }

            draw(context, camera);

            for each(var child:Node2D in children) {
                child.drawNode(context, camera);
            }
        }

        internal function processMouseEvents(mousePosition:Vector3D, mouseEventType:String, camera:Camera2D):void {

            if (mouseEnabled && mouseEventType) {
                // transform mousepos to local coordinate system
                // TODO; CACHE MATRIX AND MODE UNPEOJECT IN CAMERA
                var clipSpaceMatrix:Matrix3D = new Matrix3D();
                clipSpaceMatrix.identity();
                clipSpaceMatrix.append(modelViewMatrix);
                clipSpaceMatrix.append(camera.getProjectionMatrix());
                clipSpaceMatrix.invert();

                localMouse = clipSpaceMatrix.transformVector(mousePosition);
                localMouse.w = 1.0 / localMouse.w;
                localMouse.x /= localMouse.w;
                localMouse.y /= localMouse.w;
                localMouse.z /= localMouse.w;

                //trace(localMouse.x + " / " + localMouse.y + " / " + localMouse.z + " / " + localMouse.w);

                var oldMouseInNodeState:Boolean = mouseInNode;
                mouseInNode = (localMouse.x >= -width / 2.0 && localMouse.x <= width / 2.0 && localMouse.y >= -height / 2.0 && localMouse.y <= height / 2.0);

                if (mouseInNode) {
                    if (!oldMouseInNodeState) {
                        dispatchMouseEvent(MouseEvent.MOUSE_OVER);
                    }
                    dispatchMouseEvent(mouseEventType);
                } else if (oldMouseInNodeState && !mouseInNode) {
                    dispatchMouseEvent(MouseEvent.MOUSE_OUT);
                }
            }

            for each(var child:Node2D in children) {
                child.processMouseEvents(mousePosition, mouseEventType, camera);
            }
        }

        internal function stepNode(t:Number):void {

            step(t);

            // TODO update local mouse! ??

            for each(var child:Node2D in children) {
                child.stepNode(t);
            }
        }

        private function dispatchMouseEvent(mouseEventType:String):void {
            dispatchEvent(new MouseEvent(mouseEventType, true, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
        }

        protected function draw(context:Context3D, camera:Camera2D):void {
            // overwrite in extended classes
        }

        protected function step(t:Number):void {
            // overwrite in extended classes
        }

        public function addChild(child:Node2D):void {
            addChildAt(child, children.length);
        }

        public function addChildAt(child:Node2D, idx:uint):void {
            child.parent = this;
            children.splice(idx, 0, child);
        }

        public function removeChild(child:Node2D):void {

            var idx:int = children.indexOf(child);

            if (idx >= 0) {
                children.splice(idx, 1);
            }
        }

        public function getChildIndex(child:Node2D):uint {
            return children.indexOf(child);
        }

        public function swapChildren(child1:Node2D, child2:Node2D):void {
            var idx1:uint = getChildIndex(child1);
            var idx2:uint = getChildIndex(child2);
            children[idx1] = child2;
            children[idx2] = child1;
        }

        public function removeAllChildren():void {
            children = new Vector.<Node2D>();
        }
    }
}