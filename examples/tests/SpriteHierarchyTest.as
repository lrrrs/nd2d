package tests {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.materials.SpriteSheet;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class SpriteHierarchyTest extends Scene2D {

        [Embed(source="/assets/crate.jpg")]
        private var spriteTexture:Class;

        [Embed(source="/assets/spritechar2.png")]
        private var spriteTexture2:Class;

        private var s:Sprite2D;
        private var s2:Sprite2D;
        private var s3:Sprite2D;

        public function SpriteHierarchyTest() {

            s = new Sprite2D(new spriteTexture().bitmapData);
            s.mouseEnabled = true;
            s.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            s.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            addChild(s);

            s2 = new Sprite2D(new spriteTexture().bitmapData);
            s2.mouseEnabled = true;
            s2.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            s2.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            s2.x = 50;
            s2.y = 50;
            s2.scaleX = 0.5;
            s2.scaleY = 0.5;
            s.addChild(s2);

            var bmp:BitmapData = new spriteTexture2().bitmapData;

            var sheet:SpriteSheet = new SpriteSheet(bmp, 24, 32, 5);
            sheet.addAnimation("up", [6, 7, 8], true);

            s3 = new Sprite2D(null, sheet);
            s3.mouseEnabled = true;
            s3.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
            s3.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
            s3.scaleX = s3.scaleY = 4.0;
            s2.addChild(s3);

            s3.blendMode = BlendModePresets.NORMAL;
        }

        private function mouseOut(event:MouseEvent):void {
            event.target.tint = 0xffffff;
        }

        private function mouseOver(event:MouseEvent):void {
            event.target.tint = Math.random() * 0xffffff;
        }

        override protected function step(t:Number, elapsed:Number):void {

            //s.x = stage.stageWidth / 2;
            //s.y = stage.stageHeight / 2;
            s.position = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
            //s.alpha = 0.5 + 0.5 * Math.sin(getTimer() / 500);
            s.rotation += 0.1;

            //s.pivot = new Point(Math.sin(getTimer() / 800) * 64, Math.cos(getTimer() / 800) * 64);

            s2.rotation -= 0.5;

            s3.rotation -= 0.5;
        }
    }
}