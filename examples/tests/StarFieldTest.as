package tests {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;

    public class StarFieldTest extends Scene2D {

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

        public function StarFieldTest() {

            starfield1 = new Sprite2D(new starFieldTexture().bitmapData);
            addChild(starfield1);
            starfield2 = new Sprite2D(new starFieldTexture().bitmapData);
            addChild(starfield2);

            starfield3 = new Sprite2D(new starFieldTexture2().bitmapData);
            starfield3.blendMode = BlendModePresets.ADD;
            addChild(starfield3);

            starfield4 = new Sprite2D(new starFieldTexture2().bitmapData);
            starfield4.blendMode = BlendModePresets.ADD;
            addChild(starfield4);
        }

        override protected function step(t:Number):void {

            starfield1.width = stage.stageWidth;
            starfield1.scaleY = starfield1.scaleX;
            starfield1.x = stage.stageWidth / 2;

            var scaledHeight:Number = starfield1.height;
            var min:Number = stage.stageHeight - scaledHeight / 2;
            var max:Number = stage.stageHeight + scaledHeight / 2;

            //starfield1.y = stage.stageHeight / 2;
            starfield1.y = min + (max - min) * p;

            starfield2.width = stage.stageWidth;
            starfield2.scaleY = starfield2.scaleX;
            starfield2.x = stage.stageWidth / 2;
            //starfield2.y = stage.stageHeight / 2;
            starfield2.y = starfield1.y - scaledHeight;

            p += 0.005;

            if(starfield1.y - scaledHeight / 2 > stage.stageHeight) {
                p = 0.0;
            }

            // layer 2
            starfield3.width = stage.stageWidth;
            starfield3.scaleY = starfield3.scaleX;
            starfield3.x = stage.stageWidth / 2;

            scaledHeight = starfield3.height;
            min = stage.stageHeight - scaledHeight / 2;
            max = stage.stageHeight + scaledHeight / 2;

            starfield3.y = min + (max - min) * p2;

            starfield4.width = stage.stageWidth;
            starfield4.scaleY = starfield4.scaleX;
            starfield4.x = stage.stageWidth / 2;
            starfield4.y = starfield3.y - scaledHeight;

            p2 += 0.008;

            if(starfield3.y - scaledHeight / 2 > stage.stageHeight) {
                p2 = 0.0;
            }
        }
    }
}