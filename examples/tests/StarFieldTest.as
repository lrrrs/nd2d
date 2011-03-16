package tests{
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;

    public class StarFieldTest extends World2D {

        [Embed(source="/assets/starfield.jpg")]
        private var starFieldTexture:Class;

        [Embed(source="/assets/starfield.png")]
        private var starFieldTexture2:Class;

        private var starfield1:Sprite2D;
        private var starfield2:Sprite2D;

        private var starfield3:Sprite2D;
        private var starfield4:Sprite2D;

        private var p:Number = 0.0;
        private var p2:Number = 0.0;

        private var scene:Scene2D;

        public function StarFieldTest(renderMode:String) {
            super(renderMode, 60);

            scene = new Scene2D();
            setActiveScene(scene);

            starfield1 = new Sprite2D(new starFieldTexture().bitmapData);
            scene.addChild(starfield1);
            starfield2 = new Sprite2D(new starFieldTexture().bitmapData);
            scene.addChild(starfield2);

            starfield3 = new Sprite2D(new starFieldTexture2().bitmapData);
            starfield3.blendMode = BlendModePresets.ADD;
            scene.addChild(starfield3);
            starfield4 = new Sprite2D(new starFieldTexture2().bitmapData);
            starfield4.blendMode = BlendModePresets.ADD;
            scene.addChild(starfield4);
        }

        override protected function step(t:Number):void {

            starfield1.scaleX = starfield1.scaleY = stage.stageWidth / starfield1.width;
            starfield1.x = stage.stageWidth / 2;

            var scaledHeight:Number = (starfield1.height * starfield1.scaleY);
            var min:Number = stage.stageHeight - scaledHeight / 2;
            var max:Number = stage.stageHeight + scaledHeight / 2;

            //starfield1.y = stage.stageHeight / 2;
            starfield1.y = min + (max - min) * p;

            starfield2.scaleX = starfield2.scaleY = stage.stageWidth / starfield2.width;
            starfield2.x = stage.stageWidth / 2;
            //starfield2.y = stage.stageHeight / 2;
            starfield2.y = starfield1.y - scaledHeight;

            p += 0.005;

            if(starfield1.y - scaledHeight / 2 > stage.stageHeight) {
                p = 0.0;
            }

            // layer 2
            starfield3.scaleX = starfield3.scaleY = stage.stageWidth / starfield1.width;
            starfield3.x = stage.stageWidth / 2;

            scaledHeight = (starfield3.height * starfield3.scaleY);
            min = stage.stageHeight - scaledHeight / 2;
            max = stage.stageHeight + scaledHeight / 2;

            starfield3.y = min + (max - min) * p2;

            starfield4.scaleX = starfield4.scaleY = stage.stageWidth / starfield4.width;
            starfield4.x = stage.stageWidth / 2;
            starfield4.y = starfield3.y - scaledHeight;

            p2 += 0.008;

            if(starfield3.y - scaledHeight / 2 > stage.stageHeight) {
                p2 = 0.0;
            }
        }
    }
}