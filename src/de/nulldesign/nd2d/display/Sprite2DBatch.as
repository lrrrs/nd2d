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

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.Sprite2DBatchMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.StatsObject;
	import de.nulldesign.nd2d.utils.TextureHelper;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;

	/**
	 * Sprite2DBatch
	 * <p>Use a sprite cloud to batch sprites with the same Texture, SpriteSheet or TextureAtlas. The SpriteSheet or TextureAtlas is cloned and passed to each child. So you can control each child individually.</p>
	 *
	 * <p>Similar to a Sprite2DCloud, the main difference it that the Batch supports nested nodes, while the cloud just draws it's own children and not the subchilds.
	 * It uses less CPU resources and does more processing on the GPU than the Sprite2DCloud. Depending on your target system, it can be faster than the cloud.
	 * It supports mouseevents for childs and adding or removing childs doesn't slow down the rendering, it's free.
	 * So in particular cases it could be faster.</p>
	 *
	 * <p>If you have a SpriteSheet or TextureAtlas for your batch, make sure to add animations BEFORE you add any childs to the batch, because the SpriteSheet/TextureAtlas get's cloned and is copied to each added child</p>
	 */
	public class Sprite2DBatch extends Node2D {

		public var texture:Texture2D;
		public var spriteSheet:ASpriteSheetBase;

		private var material:Sprite2DBatchMaterial;
		private var faceList:Vector.<Face>;

		public function Sprite2DBatch(textureObject:Texture2D) {
			material = new Sprite2DBatchMaterial();
			faceList = TextureHelper.generateQuadFromDimensions(2, 2);
			texture = textureObject;
			isBatchNode = true;
		}

		override public function get numTris():uint {
			return material.numTris;
		}

		override public function get drawCalls():uint {
			return material.drawCalls;
		}

		public function setSpriteSheet(value:ASpriteSheetBase):void {
			this.spriteSheet = value;
		}

		override public function addChildAt(child:Node2D, idx:uint):Node2D {

			if(child is Sprite2DBatch) {
				throw new Error("You can't nest Sprite2DBatches");
			}

			var c:Sprite2D = child as Sprite2D;

			// distribute spritesheets to sprites
			if(c && spriteSheet && !c.spriteSheet) {
				c.setSpriteSheet(spriteSheet.clone());
			}

			if(c && texture && !c.texture) {
				c.setTexture(texture);
			}

			return super.addChildAt(child, idx);
		}

		override internal function stepNode(elapsed:Number, timeSinceStartInSeconds:Number):void {

			this.timeSinceStartInSeconds = timeSinceStartInSeconds;

			step(elapsed);

			for each(var child:Node2D in children) {
				child.stepNode(elapsed, timeSinceStartInSeconds);
			}

			// don't refresh own spritesheet
		}

		override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void {

			var myMatrixChanged:Boolean = false;

			if(!visible) {
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
			}

			draw(context, camera);
			statsObject.totalDrawCalls += drawCalls;
			statsObject.totalTris += numTris;

			// don't call draw on childs....
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			material.handleDeviceLoss();
		}

		override protected function draw(context:Context3D, camera:Camera2D):void {

			material.blendMode = blendMode;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.texture = texture;
			material.spriteSheet = spriteSheet;
			material.renderBatch(context, faceList, children);
		}

		override public function dispose():void 
		{
			if(material) 
			{
				material.dispose();
				material = null;
			}

			super.dispose();
		}
	}
}
