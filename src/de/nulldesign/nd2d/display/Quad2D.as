/**
 * de.nulldesign.nd2d.display
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 15.11.11 19:49
 */
package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.Quad2DColorMaterial;
	import de.nulldesign.nd2d.utils.TextureHelper;

	import flash.display3D.Context3D;

	public class Quad2D extends Node2D {

		protected var faceList:Vector.<Face>;
		protected var material:Quad2DColorMaterial;

		public function get topLeftColor():uint {
			return faceList[0].v1.color;
		}

		public function set topLeftColor(value:uint):void {
			var v:Vertex = faceList[0].v1;
			v.color = value;
			material.modifyColorInBuffer(0, v.r, v.g, v.b, v.a);
		}

		public function get topRightColor():uint {
			return faceList[0].v2.color;
		}

		public function set topRightColor(value:uint):void {
			var v:Vertex = faceList[0].v2;
			v.color = value;
			material.modifyColorInBuffer(1, v.r, v.g, v.b, v.a);
		}

		public function get bottomRightColor():uint {
			return faceList[0].v3.color;
		}

		public function set bottomRightColor(value:uint):void {
			var v:Vertex = faceList[0].v3;
			v.color = value;
			material.modifyColorInBuffer(2, v.r, v.g, v.b, v.a);
		}

		public function get bottomLeftColor():uint {
			return faceList[1].v3.color;
		}

		public function set bottomLeftColor(value:uint):void {
			var v:Vertex = faceList[1].v3;
			v.color = value;
			material.modifyColorInBuffer(3, v.r, v.g, v.b, v.a);
		}

		public function Quad2D(pWidth:Number, pHeight:Number) {

			_width = pWidth;
			_height = pHeight;

			faceList = TextureHelper.generateQuadFromDimensions(pWidth, pHeight);
			material = new Quad2DColorMaterial();

			topLeftColor = 0xFFFF0000;
			topRightColor = 0xFF00FF00;
			bottomRightColor = 0xFF0000FF;
			bottomLeftColor = 0xFFFFFF00;

			blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
		}

		override public function get numTris():uint {
			return faceList.length;
		}

		override public function get drawCalls():uint {
			return material.drawCalls;
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			if(material)
				material.handleDeviceLoss();
		}

		override protected function draw(context:Context3D, camera:Camera2D):void {

			material.blendMode = blendMode;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.render(context, faceList, 0, faceList.length);
		}

		override public function dispose():void {
			if(material) {
				material.dispose();
				material = null;
			}
			super.dispose();
		}
	}
}
