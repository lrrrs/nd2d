package tests {

    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.Sprite2DCloud;
    import de.nulldesign.nd2d.materials.BlendModePresets;

    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.events.Event;

    public class MassiveSpritesTest extends Scene2D {

        [Embed(source="/assets/particle_small.png")]
        private var cubeTexture:Class;

        private var sprites:Vector.<Sprite2D>;
        private var spriteSheet:Sprite2DCloud;

        private var perlinBmp:BitmapData;

        private var maxParticles:uint = 4000;

        public function MassiveSpritesTest() {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        protected function randomizeParticle(s:Sprite2D):void {
            s.x = Math.random() * stage.stageWidth;
            s.y = Math.random() * stage.stageHeight;
            s.vx = (Math.random() - Math.random()) * 15;
            s.vy = (Math.random() - Math.random()) * 15;
            s.alpha = 1.0;
        }

        protected function addedToStage(e:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            sprites = new Vector.<Sprite2D>();
            var tex:BitmapData = new cubeTexture().bitmapData;
            var s:Sprite2D;
            spriteSheet = new Sprite2DCloud(maxParticles, tex);
            spriteSheet.blendMode = BlendModePresets.ADD;

            for(var i:int = 0; i < maxParticles; i++) {
                s = new Sprite2D();
                randomizeParticle(s);
                sprites[i] = s;
                spriteSheet.addChild(s);
            }

            addChild(spriteSheet);

            perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
            perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, false, false,
                                  BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);

            stage.addEventListener(Event.RESIZE, resizeStage);
        }

        protected function resizeStage(e:Event):void {

            perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
            perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, true, false,
                                  BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);
        }

        override protected function step(elapsed:Number):void {

            var p:Number;
            var s:Sprite2D;
            var len:int = sprites.length;
            var r:uint;
            var g:uint;
            var b:uint;

            for(var i:int = 0; i < len; i++) {
                s = sprites[i];
                s.x += s.vx;
                s.y += s.vy;

                if(s.x < 0) {
                    //s.x = 0;
                    //s.vx *= -1;
                    randomizeParticle(s);
                }

                if(s.x > stage.stageWidth) {
                    //s.x = stage.stageWidth;
                    //s.vx *= -1;
                    randomizeParticle(s);
                }

                if(s.y < 0) {
                    //s.y = 0;
                    //s.vy *= -1;
                    randomizeParticle(s);
                }

                if(s.y > stage.stageHeight) {
                    //s.y = stage.stageHeight;
                    //s.vy *= -1;
                    randomizeParticle(s);
                }

                p = perlinBmp.getPixel(s.x, s.y);

                r = p >> 16;
                g = p >> 8 & 255;
                b = p & 255;

                s.vx += (r - b) * 0.003;
                s.vy += (g - b) * 0.003;

                // clip
                s.vx = Math.min(s.vx, 3);
                s.vy = Math.min(s.vy, 3);
                s.vx = Math.max(s.vx, -3);
                s.vy = Math.max(s.vy, -3);

                r = (s.x / stage.stageWidth) * 255;
                g = (s.y / stage.stageHeight) * 255;
                b = Math.abs(Math.round((s.vx + s.vy))) * 10;
                s.tint = (r << 16 | g << 8 | b);
                s.alpha -= 0.001;
            }
        }
    }
}