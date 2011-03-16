package tests{
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;

    public class SpriteAnimTest extends World2D {

        [Embed(source="/assets/spritechar1.png")]
        private var spriteTexture:Class;

        private var s:Sprite2D;

        public function SpriteAnimTest(rendermode:String) {
            super(rendermode, 60);

            //s = new Sprite2D(new spriteTexture().bitmapData, new Rectangle(0, 0, 24, 32));
            //scene.addChild(s);
        }

        override protected function step(t:Number):void {

            s.x = stage.stageWidth / 2;
            s.y = stage.stageHeight / 2;

            //s.frame = Math.round(getTimer() / 200) % 12;
            //s.frame = 0;

            //camera.zoom = 12.0 + Math.sin(getTimer() / 500) * 11.0;
        }
    }
}