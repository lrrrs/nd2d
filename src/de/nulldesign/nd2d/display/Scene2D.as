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
	 * A scene that can contain 2D nodes
	 * Even if a scene has x,y, rotation etc. properties you can't modify a scene this way.
	 * Use the built in camera instance to pan and zoom over your scene.
	 */
	public class Scene2D extends Node2D {

		internal var br:Number = 0.0;
		internal var bg:Number = 0.0;
		internal var bb:Number = 0.0;

		private var _backGroundColor:Number = 0x000000;

		public function get backGroundColor():Number {
			return _backGroundColor;
		}

		public function set backGroundColor(value:Number):void {
			_backGroundColor = value;
			br = (backGroundColor >> 16) / 255.0;
			bg = (backGroundColor >> 8 & 255) / 255.0;
			bb = (backGroundColor & 255) / 255.0;
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
			super.stepNode(elapsed, timeSinceStartInSeconds);
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