
package tests {
    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.Sprite2DCloud;
    import de.nulldesign.nd2d.display.Sprite2DCloud2;
    import de.nulldesign.nd2d.materials.SpriteSheet;

    import flash.display.BitmapData;

    public class MassiveSpriteCloudTest extends Scene2D {

        [Embed(source="/assets/spritechar2.png")]
        private var cubeTexture:Class;

        private var sprites:Vector.<Sprite2D>;
        private var spriteCloud:Node2D;

        private var numSprites:uint = 1600;

        public function MassiveSpriteCloudTest() {

            backGroundColor = 0x666666;

            sprites = new Vector.<Sprite2D>();
            var tex:BitmapData = new cubeTexture().bitmapData;
            var s:Sprite2D;

            var sheet:SpriteSheet = new SpriteSheet(tex, 24, 32, 10);
            sheet.addAnimation("up", [0, 1, 2], true);
            sheet.addAnimation("right", [3, 4, 5], true);
            sheet.addAnimation("down", [6, 7, 8], true);
            sheet.addAnimation("left", [9, 10, 11], true);

            spriteCloud = new Sprite2DCloud(numSprites, null, sheet);

            for(var i:int = 0; i < numSprites; i++) {

                s = new Sprite2D();
                s.x = Math.round(Math.random() * 1000);
                s.y = Math.round(Math.random() * 1000);
                s.vx = (Math.random() - Math.random()) * 3;
                s.vy = (Math.random() - Math.random()) * 3;
                //s.scaleX = s.scaleY = 2.0; // NOT IMPLEMENTED

                sprites[i] = s;

                spriteCloud.addChild(s);
            }

            addChild(spriteCloud);
        }

        override protected function step(t:Number, elapsed:Number):void {

            var s:Sprite2D;
            var len:int = sprites.length;
            var i:int = len;
            var vxabs:Number;
            var vyabs:Number;

            while(--i > -1) {
                s = sprites[i];
                s.x += s.vx;
                s.y += s.vy;

                //s.rotation += 10;

                if(s.x < 0) {
                    s.x = 0;
                    s.vx *= -1;
                }

                if(s.x > stage.stageWidth) {
                    s.x = stage.stageWidth;
                    s.vx *= -1;
                }

                if(s.y < 0) {
                    s.y = 0;
                    s.vy *= -1;
                }

                if(s.y > stage.stageHeight) {
                    s.y = stage.stageHeight;
                    s.vy *= -1;
                }

                vxabs = Math.abs(s.vx);
                vyabs = Math.abs(s.vy);

                if(s.vx > 0 && vxabs > vyabs) { // right
                    s.spriteSheet.playAnimation("right");
                } else if(s.vx < 0 && vxabs > vyabs) { // left
                    s.spriteSheet.playAnimation("left");
                } else if(s.vy > 0 && vyabs > vxabs) { // down
                    s.spriteSheet.playAnimation("down");
                } else if(s.vy < 0 && vyabs > vxabs) { // up
                    s.spriteSheet.playAnimation("up");
                }
            }

            //camera.x = Math.sin(getTimer() / 1000.0) * 100.0;
            //camera.y = Math.cos(getTimer() / 1000.0) * 100.0;
            //camera.zoom = 1.0 + 0.5 + 0.5 * Math.sin(getTimer() / 5000);
        }
    }
}
