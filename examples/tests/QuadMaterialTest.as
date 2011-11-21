/**
 * tests
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 15.11.11 19:45
 */
package tests {

	import de.nulldesign.nd2d.display.Quad2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.materials.Quad2DColorMaterial;
	import de.nulldesign.nd2d.utils.ColorUtil;
	import de.nulldesign.nd2d.utils.NumberUtil;

	public class QuadMaterialTest extends Scene2D {

		private var colorQuad:Quad2D;

		public function QuadMaterialTest() {
			colorQuad = new Quad2D(500.0, 500.0);
			addChild(colorQuad);
		}

		override protected function step(elapsed:Number):void {
			colorQuad.x = stage.stageWidth * 0.5;
			colorQuad.y = stage.stageHeight * 0.5;
			colorQuad.width = stage.stageWidth;
			colorQuad.height = stage.stageHeight;

			colorQuad.topLeftColor = ColorUtil.colorWithAlphaFromColor(
												ColorUtil.mixColors(0xFF0000, 0x00FF00, NumberUtil.sin0_1(timeSinceStartInSeconds * 2.2)),
												NumberUtil.sin0_1(timeSinceStartInSeconds * 2.3)
											);

			colorQuad.topRightColor = ColorUtil.colorWithAlphaFromColor(
												ColorUtil.mixColors(0x00FF00, 0x0000FF, NumberUtil.sin0_1(timeSinceStartInSeconds * 2.4)),
												NumberUtil.sin0_1(timeSinceStartInSeconds * 2.5)
											);
			colorQuad.bottomLeftColor = ColorUtil.colorWithAlphaFromColor(
												ColorUtil.mixColors(0xFF00FF, 0xFFFF00, NumberUtil.sin0_1(timeSinceStartInSeconds * 2.6)),
												NumberUtil.sin0_1(timeSinceStartInSeconds * 2.7)
											);

			colorQuad.bottomRightColor = ColorUtil.colorWithAlphaFromColor(
												ColorUtil.mixColors(0x00FF99, 0x9900FF, NumberUtil.sin0_1(timeSinceStartInSeconds * 2.8)),
												NumberUtil.sin0_1(timeSinceStartInSeconds * 2.9)
											);
		}
	}
}
