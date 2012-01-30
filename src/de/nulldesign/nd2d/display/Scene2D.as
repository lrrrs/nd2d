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

	import de.nulldesign.nd2d.utils.StatsObject;

	import flash.display.Stage;

	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * <p>A scene that can contain 2D nodes. Such as Sprite2D.</p>
	 * <p>The scene is meant to display a state of your game, such as the game screen, a highscore screen, etc. You can switch between the scenes by setting a new active scene in the World2D</p>
	 *
	 * Even if a scene has x,y, rotation etc. properties you can't modify a scene this way.
	 * Use the built in camera instance to pan and zoom over your scene.
	 *
	 * <p>If you make use of the camera and still want to have non moving objects in your scene like GUI elements, attach them to the sceneGUILayer instead to the scene itself.</p>
	 */
	public class Scene2D extends Node2D {

		internal var br:Number = 0.0;
		internal var bg:Number = 0.0;
		internal var bb:Number = 0.0;

		private var _backgroundColor:Number = 0x000000;

		public function get backgroundColor():Number {
			return _backgroundColor;
		}

		/**
		 * @param The background color of your scene in RGB format
		 */
		public function set backgroundColor(value:Number):void {
			_backgroundColor = value;
			br = (backgroundColor >> 16) / 255.0;
			bg = (backgroundColor >> 8 & 255) / 255.0;
			bb = (backgroundColor & 255) / 255.0;
		}

		protected var sceneGUICamera:Camera2D = new Camera2D(1, 1);
		protected var sceneGUILayer:Node2D = new Node2D();

		public function Scene2D() {
			super();
			mouseEnabled = true;
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			sceneGUILayer.handleDeviceLoss();
		}

		override internal function stepNode(elapsed:Number, timeSinceStartInSeconds:Number):void {

			this.timeSinceStartInSeconds = timeSinceStartInSeconds;

			for each(var child:Node2D in children) {
				child.stepNode(elapsed, timeSinceStartInSeconds);
			}

			// call step() after all nodes have finished updating their positions. removes camera stuttering issue
			step(elapsed);

			sceneGUILayer.stepNode(elapsed, timeSinceStartInSeconds);
		}

		override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

			for each(var child:Node2D in children) {
				child.drawNode(context, camera, false, statsObject);
			}

			// resize gui camera if needed
			if(sceneGUICamera.sceneWidth != camera.sceneWidth) {
				sceneGUICamera.resizeCameraStage(camera.sceneWidth, camera.sceneHeight);
			}

			// draw GUI layer
			sceneGUILayer.drawNode(context, sceneGUICamera, false, statsObject);
		}

		override internal function processMouseEvent(mousePosition:Vector3D, mouseEventType:String, cameraViewProjectionMatrix:Matrix3D, isTouchEvent:Boolean, touchPointID:int):Node2D {
			var node:Node2D = super.processMouseEvent(mousePosition, mouseEventType, cameraViewProjectionMatrix, isTouchEvent, touchPointID);
			var guiNode:Node2D = sceneGUILayer.processMouseEvent(mousePosition, mouseEventType, sceneGUICamera.getViewProjectionMatrix(), isTouchEvent, touchPointID);

			return guiNode ? guiNode : node;
		}

		override internal function setStageAndCamRef(value:Stage, cameraValue:Camera2D):void {
			super.setStageAndCamRef(value, cameraValue);

			if(camera) {
				_width = camera.sceneWidth;
				_height = camera.sceneHeight;
			}
		}

		override protected function hitTest():Boolean {
			return (_mouseX >= 0.0 && _mouseX <= _width && _mouseY >= 0.0 && _mouseY <= _height);
		}
	}
}