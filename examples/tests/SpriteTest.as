package tests {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.utils.ColorUtil;

    import flash.utils.getTimer;

    public class SpriteTest extends Scene2D {

        [Embed(source="../assets/crate.jpg")]
        private var spriteTexture:Class;

        private var s:Sprite2D;
        private var s2:Sprite2D;
        private var s3:Sprite2D;

        public function SpriteTest() {

            s = new Sprite2D(new spriteTexture().bitmapData);
            addChild(s);

            s2 = new Sprite2D(new spriteTexture().bitmapData);
            addChild(s2);

            s3 = new Sprite2D(new spriteTexture().bitmapData);
            addChild(s3);
        }

        override protected function step(t:Number):void {

            s.x = stage.stageWidth / 2;
            s.y = stage.stageHeight / 2;

            s.rotation += 5;
            //s.scaleX = s.scaleY = 2.0 + Math.sin(getTimer() * 0.001);
            s.tint = ColorUtil.rgb2hex(255 * (0.5 + Math.sin(getTimer() * 0.002) * 0.5),
                                       255 * (0.5 + Math.cos(getTimer() * 0.001) * 0.5),
                                       255 * (0.5 + Math.sin(getTimer() * 0.003) * 0.5));

            s2.x = stage.stageWidth / 2 - s2.width / 1.5;
            s2.y = stage.stageHeight / 2;
            s2.rotation += 5;
            s2.alpha = 0.5 + Math.sin(getTimer() * 0.001) * 0.5;

            s3.x = stage.stageWidth / 2 + s3.width / 1.5;
            s3.y = stage.stageHeight / 2;
            s3.rotation -= 2.5;
            s3.blendMode = BlendModePresets.ADD;

            camera.x = Math.sin(getTimer() / 5000) * 20.0;
            camera.y = Math.cos(getTimer() / 5000) * 20.0;
            camera.rotation += 5.0;
            camera.zoom = 1.0 + Math.sin(getTimer() / 5000) * 0.2;
        }
    }
}