/**
 * tests
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 06.11.11 15:29
 */
package tests {

	import de.nulldesign.nd2d.display.Node2D;

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flash.display.BitmapData;
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Transform3DTest extends Scene2D {

		[Embed(source="../assets/test_image.jpg")]
		private var imageBitmap:Class;

		private var batchNode:Sprite2DBatch;

		public function Transform3DTest() {

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);

			//x = 10, y = 8
		}

		private function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new imageBitmap().bitmapData);
			batchNode = new Sprite2DBatch(tex);
			addChild(batchNode);

			var sheet:SpriteSheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 780 / 10, 208 / 4, 1);
			batchNode.setSpriteSheet(sheet);

			for(var i:int = 0; i < 40; i++) {
				var s:Sprite2D = new Sprite2D();
				batchNode.addChild(s);

				s.x = (i % 10) * 78.0 - 780.0 * 0.5;
				s.y = Math.floor(i / 10) * 52.0 - 208.0 * 0.5;
				s.spriteSheet.frame = i;
			}
		}

		override protected function step(elapsed:Number):void {
			batchNode.x = stage.stageWidth * 0.5;
			batchNode.y = stage.stageHeight * 0.5;

			var n:Node2D
			for(var i:int = 0; i < batchNode.children.length; i++) {
				n = batchNode.getChildAt(i);
				n.rotationX = NumberUtil.sin0_1(timeSinceStartInSeconds * 0.8) * 180.0 * (Math.floor(i / 10) % 2 == 0 ? -1 : 1);
				n.rotationY = NumberUtil.sin0_1(timeSinceStartInSeconds * 0.8) * 180.0 * (i % 2 == 0 ? -1 : 1);
			}
		}
	}
}
