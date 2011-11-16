/**
 * tests
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 16.11.11 21:00
 */
package tests {

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.TextField2D;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flashx.textLayout.formats.TextAlign;

	public class TextFieldTest extends Scene2D {

		private var txt:TextField2D;

		public function TextFieldTest() {
			txt = new TextField2D();
			txt.font = "Helvetica";
			txt.textColor = 0xFFFFFF;
			txt.size = 100.0;
			txt.align = TextAlign.CENTER;
			txt.text = "Hello ND2D Text!";
			addChild(txt);
		}


		override protected function step(elapsed:Number):void {
			txt.x = stage.stageWidth >> 1;
			txt.y = stage.stageHeight >> 1;
			txt.rotation += 4.0;
			txt.scaleX = txt.scaleY = NumberUtil.sin0_1(timeSinceStartInSeconds);
		}
	}
}
