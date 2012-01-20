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

	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.utils.NodeBlendMode;
	import de.nulldesign.nd2d.utils.StatsObject;

	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * Dispatched when the scene is active and added to the stage.
	 * @eventType flash.events.Event.ADDED_TO_STAGE
	 */
	[Event(name="addedToStage", type="flash.events.Event")]

	/**
	 * Dispatched when the scene inactive and removed from stage.
	 * @eventType flash.events.Event.REMOVED_FROM_STAGE
	 */
	[Event(name="removedFromStage", type="flash.events.Event")]

	/**
	 * Dispatched when a user presses and releases the main button of the user's pointing device over the same Node2D.
	 * @eventType flash.events.MouseEvent.CLICK
	 */
	[Event(name="click", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user presses the pointing device button over an Node2D instance.
	 * @eventType flash.events.MouseEvent.MOUSE_DOWN
	 */
	[Event(name="mouseDown", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user moves the pointing device while it is over an Node2D.
	 * @eventType flash.events.MouseEvent.MOUSE_MOVE
	 */
	[Event(name="mouseMove", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user releases the pointing device button over an Node2D instance.
	 * @eventType flash.events.MouseEvent.MOUSE_UP
	 */
	[Event(name="mouseUp", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when the user moves a pointing device over an Node2D instance.
	 * @eventType flash.events.MouseEvent.MOUSE_OVER
	 */
	[Event(name="mouseOver", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when the user moves a pointing device away from an Node2D instance.
	 * @eventType flash.events.MouseEvent.MOUSE_OUT
	 */
	[Event(name="mouseOut", type="flash.events.MouseEvent")]

	/**
	 * Dispatched when a user presses and releases the main button of the user's pointing device over the same Node2D.
	 * @eventType flash.events.TouchEvent.TOUCH_TAP
	 */
	[Event(name="touchTap", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when the user moves a pointing device over an Node2D instance.
	 * @eventType flash.events.TouchEvent.TOUCH_OVER
	 */
	[Event(name="touchOver", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when the user moves a pointing device away from an Node2D instance.
	 * @eventType flash.events.TouchEvent.TOUCH_OUT
	 */
	[Event(name="touchOut", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user moves the pointing device while it is over an Node2D.
	 * @eventType flash.events.TouchEvent.TOUCH_MOVE
	 */
	[Event(name="touchMove", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user presses the pointing device button over an Node2D instance.
	 * @eventType flash.events.TouchEvent.TOUCH_BEGIN
	 */
	[Event(name="touchBegin", type="flash.events.TouchEvent")]

	/**
	 * Dispatched when a user releases the pointing device button over an Node2D instance.
	 * @eventType flash.events.TouchEvent.TOUCH_END
	 */
	[Event(name="touchEnd", type="flash.events.TouchEvent")]

	/**
	 * <p>Base 2D object. All drawable objects must extend Node2D</p>
	 * A Node2D has two methods that are called during rendering:
	 * <ul>
	 * <li>step - Update the node's position here</li>
	 * <li>draw - Your rendering code goes here</li>
	 * </ul>
	 */
	public class Node2D extends EventDispatcher {

		/**
		 * @private
		 */
		public var localModelMatrix:Matrix3D = new Matrix3D();

		/**
		 * @private
		 */
		public var worldModelMatrix:Matrix3D = new Matrix3D();

		/**
		 * @private
		 */
		public var invalidateMatrix:Boolean = true;

		/**
		 * @private
		 */
		public var invalidateVisibility:Boolean = true;

		/**
		 * @private
		 */
		public var invalidateColors:Boolean = true;

		public var hasPremultipliedAlphaTexture:Boolean = true;

		public var children:Vector.<Node2D> = new Vector.<Node2D>();
		public var parent:Node2D;

		public var vx:Number;
		public var vy:Number;

		public var tag:int = 0;

		public var blendMode:NodeBlendMode = BlendModePresets.NORMAL_PREMULTIPLIED_ALPHA;

		public var mouseEnabled:Boolean = false;

		public var boundingSphereRadius:Number;

		protected var timeSinceStartInSeconds:Number = 0.0;

		protected var camera:Camera2D;

		private var localMouse:Vector3D;
		private var localMouseMatrix:Matrix3D = new Matrix3D();

		internal var mouseInNode:Boolean = false;
		internal var mouseEvents:Vector.<Event>;

		protected var _stage:Stage;

		public function get stage():Stage {
			return _stage;
		}

		/**
		 * @private
		 */
		protected var _width:Number;

		public function get width():Number {
			return Math.abs(_width * _scaleX);
		}

		public function set width(value:Number):void {
			scaleX = value / _width;
		}

		/**
		 * @private
		 */
		protected var _height:Number;

		public function get height():Number {
			return Math.abs(_height * _scaleY);
		}

		public function set height(value:Number):void {
			scaleY = value / _height;
		}

		protected var _visible:Boolean = true;

		public function get visible():Boolean {
			return _visible;
		}

		public function set visible(value:Boolean):void {
			if(_visible != value) {
				_visible = value;
				invalidateVisibility = true;
			}
		}

		protected var _alpha:Number = 1.0;

		public function set alpha(value:Number):void {
			if(_alpha != value) {
				_alpha = value;
				invalidateColors = true;
				visible = _alpha > 0.0;
			}
		}

		public function get alpha():Number {
			return _alpha;
		}

		/**
		 * @private
		 */
		public var combinedColorTransform:ColorTransform = new ColorTransform();

		protected var _colorTransform:ColorTransform = new ColorTransform();

		public function get colorTransform():ColorTransform {
			return _colorTransform;
		}

		public function set colorTransform(value:ColorTransform):void {
			if(_colorTransform != value) {
				_colorTransform = value;
				invalidateColors = true;
			}
		}

		protected var _tint:uint = 0xFFFFFF;

		public function get tint():uint {
			return _tint;
		}

		public function set tint(value:uint):void {
			if(_tint != value) {
				_tint = value;

				var r:Number = (_tint >> 16) / 255.0;
				var g:Number = (_tint >> 8 & 255) / 255.0;
				var b:Number = (_tint & 255) / 255.0;

				_colorTransform.redMultiplier = r;
				_colorTransform.greenMultiplier = g;
				_colorTransform.blueMultiplier = b;
				_colorTransform.alphaMultiplier = 1.0;
				_colorTransform.redOffset = 0;
				_colorTransform.greenOffset = 0;
				_colorTransform.blueOffset = 0;
				_colorTransform.alphaOffset = 0;

				invalidateColors = true;
			}
		}

		protected var _scaleX:Number = 1.0;

		public function set scaleX(value:Number):void {
			if(_scaleX != value) {
				_scaleX = value;
				invalidateMatrix = true;
			}
		}

		public function get scaleX():Number {
			return _scaleX;
		}

		protected var _scaleY:Number = 1.0;

		public function set scaleY(value:Number):void {
			if(_scaleY != value) {
				_scaleY = value;
				invalidateMatrix = true;
			}
		}

		public function get scaleY():Number {
			return _scaleY;
		}

		protected var _x:Number = 0.0;

		public function set x(value:Number):void {
			if(_x != value) {
				_position.x = _x = value;
				invalidateMatrix = true;
			}
		}

		public function get x():Number {
			return _x;
		}

		protected var _y:Number = 0.0;

		public function set y(value:Number):void {
			if(_y != value) {
				_position.y = _y = value;
				invalidateMatrix = true;
			}
		}

		public function get y():Number {
			return _y;
		}

		protected var _z:Number = 0.0;

		public function set z(value:Number):void {
			if(_z != value) {
				_position.z = _z = value;
				invalidateMatrix = true;
			}
		}

		public function get z():Number {
			return _z;
		}

		protected var _position:Vector3D = new Vector3D(0.0, 0.0, 0.0);

		public function get position():Vector3D {
			return _position;
		}

		public function set position(value:Vector3D):void {
			if(_x != value.x || _y != value.y || _z != value.z) {
				_position.x = _x = value.x;
				_position.y = _y = value.y;
				_position.z = _z = value.z;
				invalidateMatrix = true;
			}
		}

		protected var _pivot:Point = new Point(0.0, 0.0);

		public function get pivot():Point {
			return _pivot;
		}

		public function set pivot(value:Point):void {
			if(_pivot.x != value.x || _pivot.y != value.y) {
				_pivot.x = value.x;
				_pivot.y = value.y;
				invalidateMatrix = true;
			}
		}

		public function set rotation(value:Number):void {
			if(_rotationZ != value) {
				_rotationZ = value;
				invalidateMatrix = true;
			}
		}

		public function get rotation():Number {
			return _rotationZ;
		}

		protected var _rotationX:Number = 0.0;

		public function set rotationX(value:Number):void {
			if(_rotationX != value) {
				_rotationX = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationX():Number {
			return _rotationX;
		}

		protected var _rotationY:Number = 0.0;

		public function set rotationY(value:Number):void {
			if(_rotationY != value) {
				_rotationY = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationY():Number {
			return _rotationY;
		}

		protected var _rotationZ:Number = 0.0;

		public function set rotationZ(value:Number):void {
			if(_rotationZ != value) {
				_rotationZ = value;
				invalidateMatrix = true;
			}
		}

		public function get rotationZ():Number {
			return _rotationZ;
		}

		protected var _mouseX:Number = 0.0;

		public function get mouseX():Number {
			return _mouseX;
		}

		protected var _mouseY:Number = 0.0;

		public function get mouseY():Number {
			return _mouseY;
		}

		public function get numTris():uint {
			return 0;
		}

		public function get drawCalls():uint {
			return 0;
		}

		public function get numChildren():uint {
			return children.length;
		}

		public function Node2D() {
		}

		/**
		 * @private
		 */
		public function updateLocalMatrix():void {
			invalidateMatrix = false;
			localModelMatrix.identity();
			localModelMatrix.appendTranslation(-_pivot.x, -_pivot.y, 0);
			localModelMatrix.appendScale(_scaleX, _scaleY, 1.0);
			localModelMatrix.appendRotation(_rotationZ, Vector3D.Z_AXIS);
			localModelMatrix.appendRotation(_rotationY, Vector3D.Y_AXIS);
			localModelMatrix.appendRotation(_rotationX, Vector3D.X_AXIS);
			localModelMatrix.appendTranslation(_x, _y, _z);
		}

		/**
		 * @private
		 */
		public function updateWorldMatrix():void {

			worldModelMatrix.identity();
			worldModelMatrix.append(localModelMatrix);

			if(parent) {
				worldModelMatrix.append(parent.worldModelMatrix);
			}
		}

		/**
		 * @private
		 */
		public function updateColors():void {

			invalidateColors = false;

			if(hasPremultipliedAlphaTexture) {
				combinedColorTransform.redMultiplier = _colorTransform.redMultiplier * _alpha;
				combinedColorTransform.greenMultiplier = _colorTransform.greenMultiplier * _alpha;
				combinedColorTransform.blueMultiplier = _colorTransform.blueMultiplier * _alpha;
				combinedColorTransform.alphaMultiplier = _colorTransform.alphaMultiplier * _alpha;
			} else {
				combinedColorTransform.redMultiplier = _colorTransform.redMultiplier;
				combinedColorTransform.greenMultiplier = _colorTransform.greenMultiplier;
				combinedColorTransform.blueMultiplier = _colorTransform.blueMultiplier;
				combinedColorTransform.alphaMultiplier = _colorTransform.alphaMultiplier * _alpha;
			}

			combinedColorTransform.redOffset = _colorTransform.redOffset;
			combinedColorTransform.greenOffset = _colorTransform.greenOffset;
			combinedColorTransform.blueOffset = _colorTransform.blueOffset;
			combinedColorTransform.alphaOffset = _colorTransform.alphaOffset;

			if(parent) {
				combinedColorTransform.concat(parent.combinedColorTransform);
			}

			for each(var child:Node2D in children) {
				child.updateColors();
			}
		}

		/**
		 * @private
		 */
		internal function processMouseEvent(mousePosition:Vector3D, mouseEventType:String, cameraViewProjectionMatrix:Matrix3D, isTouchEvent:Boolean, touchPointID:int):Node2D {
			mouseEvents = new Vector.<Event>();
			var result:Node2D = null;

			if(mouseEnabled && mouseEventType) {
				// transform mousepos to local coordinate system
				localMouseMatrix.identity();
				localMouseMatrix.append(worldModelMatrix);
				localMouseMatrix.append(cameraViewProjectionMatrix);
				localMouseMatrix.invert();

				localMouse = localMouseMatrix.transformVector(mousePosition);
				localMouse.w = 1.0 / localMouse.w;
				localMouse.x /= localMouse.w;
				localMouse.y /= localMouse.w;
				localMouse.z /= localMouse.w;

				_mouseX = localMouse.x;
				_mouseY = localMouse.y;

				var oldMouseInNodeState:Boolean = mouseInNode;
				var newMouseInNode:Boolean = hitTest();

				if(newMouseInNode) {
					if(!oldMouseInNodeState) {
						if(isTouchEvent) {
							mouseEvents.push(new TouchEvent(TouchEvent.TOUCH_OVER, false, false, touchPointID, false, localMouse.x, localMouse.y));
						} else {
							mouseEvents.push(new MouseEvent(MouseEvent.MOUSE_OVER, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
						}
					}

					if(isTouchEvent) {
						mouseEvents.push(new TouchEvent(mouseEventType, false, false, touchPointID, false, localMouse.x, localMouse.y));
					} else {
						mouseEvents.push(new MouseEvent(mouseEventType, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
					}
					result = this;

				} else if(oldMouseInNodeState) {
					// dispatch mouse out directly, no hierarchy test
					if(isTouchEvent) {
						dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, false, false, touchPointID, false, localMouse.x, localMouse.y));
					} else {
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, false, false, localMouse.x, localMouse.y, null, false, false, false, (mouseEventType == MouseEvent.MOUSE_DOWN), 0));
					}
				}
			}

			var subChildMouseNode:Node2D;
			for(var i:Number = children.length - 1; i >= 0; --i) {
				subChildMouseNode = children[i].processMouseEvent(mousePosition, mouseEventType, cameraViewProjectionMatrix, isTouchEvent, touchPointID);
				if(subChildMouseNode) {
					result = subChildMouseNode;
					break;
				}
			}

			// set over to false, if one of our childs stole the event
			if(result != this) {
				mouseInNode = false;
			}

			return result;
		}

		/**
		 * Overwrite and do your own hitTest if you like
		 * @return
		 */
		protected function hitTest():Boolean {
			if(isNaN(_width) || isNaN(_height)) {
				return false;
			}

			var halfWidth:Number = _width >> 1;
			var halfHeight:Number = _height >> 1;
			return (_mouseX >= -halfWidth && _mouseX <= halfWidth && _mouseY >= -halfHeight && _mouseY <= halfHeight);
		}

		internal function setStageAndCamRef(value:Stage, cameraValue:Camera2D):void {

			if(_stage != value) {

				camera = cameraValue;

				if(value) {
					_stage = value;
					dispatchEvent(new Event(Event.ADDED_TO_STAGE));
				} else {
					dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
					_stage = value;
				}

				for each(var child:Node2D in children) {
					child.setStageAndCamRef(value, cameraValue);
				}
			}
		}

		/**
		 * @private
		 */
		internal function stepNode(elapsed:Number, timeSinceStartInSeconds:Number):void {

			this.timeSinceStartInSeconds = timeSinceStartInSeconds;

			step(elapsed);

			for each(var child:Node2D in children) {
				child.stepNode(elapsed, timeSinceStartInSeconds);
			}
		}

		public function handleDeviceLoss():void {
			for each(var child:Node2D in children) {
				child.handleDeviceLoss();
			}
			// extend in extended classes
		}

		/**
		 * @private
		 */
		internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

			var myMatrixChanged:Boolean = false;

			if(!_visible) {
				return;
			}

			if(invalidateColors) {
				updateColors();
			}

			if(invalidateMatrix) {
				updateLocalMatrix();
				myMatrixChanged = true;
			}

			if(parentMatrixChanged || myMatrixChanged) {
				updateWorldMatrix();
				myMatrixChanged = true;
			}

			draw(context, camera);
			statsObject.totalDrawCalls += drawCalls;
			statsObject.totalTris += numTris;

			for each(var child:Node2D in children) {
				child.drawNode(context, camera, myMatrixChanged, statsObject);
			}
		}

		protected function draw(context:Context3D, camera:Camera2D):void {
			// overwrite in extended classes
		}

		protected function step(elapsed:Number):void {
			// overwrite in extended classes
		}

		public function setChildIndex(child:Node2D, index:int):void {
			var child2:Node2D = getChildAt(index);
			if(child2 != null) swapChildren(child, child2);
		}

		public function addChild(child:Node2D):Node2D {
			return addChildAt(child, children.length);
		}

		public function addChildAt(child:Node2D, idx:uint):Node2D {

			var existingIdx:int = getChildIndex(child);
			if(existingIdx != -1) {
				removeChildAt(existingIdx);
			}

			child.parent = this;
			child.setStageAndCamRef(_stage, camera);
			children.splice(idx, 0, child);
			return child;
		}

		public function removeChild(child:Node2D):void {

			var idx:int = children.indexOf(child);

			if(idx >= 0) {
				removeChildAt(idx);
			}
		}

		public function removeChildAt(idx:uint):void {
			if(idx < children.length) {
				children[idx].parent = null;
				children[idx].setStageAndCamRef(null, null);
				children.splice(idx, 1);
			}
		}

		public function getChildAt(idx:uint):Node2D {
			if(idx < children.length) {
				return children[idx];
			}

			return null;
		}

		public function getChildIndex(child:Node2D):int {
			return children.indexOf(child);
		}

		public function swapChildren(child1:Node2D, child2:Node2D):void {
			var idx1:uint = getChildIndex(child1);
			var idx2:uint = getChildIndex(child2);
			children[idx1] = child2;
			children[idx2] = child1;
		}

		public function removeAllChildren():void {
			while(children.length > 0) {
				removeChildAt(0);
			}
		}

		public function getChildByTag(value:int):Node2D {
			for each(var child:Node2D in children) {
				if(child.tag == value) return child;
			}

			return null;
		}

		public function localToGlobal(p:Point):Point {

			var clipSpaceMat:Matrix3D = new Matrix3D();
			clipSpaceMat.append(worldModelMatrix);
			clipSpaceMat.append(camera.getViewProjectionMatrix());

			var v:Vector3D = clipSpaceMat.transformVector(new Vector3D(p.x, p.y, 0.0));
			return new Point((v.x + 1.0) * 0.5 * camera.sceneWidth, (-v.y + 1.0) * 0.5 * camera.sceneHeight);
		}

		public function globalToLocal(p:Point):Point {

			var clipSpaceMat:Matrix3D = new Matrix3D();
			clipSpaceMat.append(worldModelMatrix);
			clipSpaceMat.append(camera.getViewProjectionMatrix());
			clipSpaceMat.invert();

			var from:Vector3D = new Vector3D(p.x / camera.sceneWidth * 2.0 - 1.0,
					-(p.y / camera.sceneHeight * 2.0 - 1.0),
					0.0, 1.0);

			var v:Vector3D = clipSpaceMat.transformVector(from);
			v.w = 1.0 / v.w;
			v.x /= v.w;
			v.y /= v.w;
			//v.z /= v.w;

			return new Point(v.x, v.y);
		}

		public function dispose():void {
			for each(var child:Node2D in children) {
				child.dispose();
			}
		}
	}
}