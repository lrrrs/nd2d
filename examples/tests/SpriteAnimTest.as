package tests {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.SpriteSheet;

    public class SpriteAnimTest extends Scene2D {

        [Embed(source="/assets/spritechar1.png")]
        private var spriteTexture:Class;

        private var s:Sprite2D;

        public function SpriteAnimTest() {

            var sheet:SpriteSheet = new SpriteSheet(new spriteTexture().bitmapData, 24, 32, 5);
            sheet.addAnimation("up", [0, 1, 2], true);
            sheet.addAnimation("right", [3, 4, 5], true);
            sheet.addAnimation("down", [6, 7, 8], true);
            sheet.addAnimation("left", [9, 10, 11], true);

            s = new Sprite2D(null, sheet);
            addChild(s);
        }

        override protected function step(t:Number):void {

            s.x = stage.stageWidth / 2;
            s.y = stage.stageHeight / 2;

            //camera.zoom = 12.0 + Math.sin(getTimer() / 500) * 11.0;
        }
    }
}