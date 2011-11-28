package tests {

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.ColorUtil;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flash.events.Event;

	public class Sprite2DCloudParticles extends Scene2D {

        [Embed(source="/assets/twirl.jpg")]
        private var twirlBmp:Class;

        private var spriteCloud:Node2D;

        /**
         * Sprite2DCloudParticles
         * @author Lars Gerckens (lars@nulldesign,de)
         * Date: 05.10.11 15:38
         */
        public function Sprite2DCloudParticles() {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        protected function addedToStage(e:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            var maxParticles:uint = 1000;
            var s:Sprite2D;

            spriteCloud = new Sprite2DCloud(maxParticles, Texture2D.textureFromBitmapData(new twirlBmp().bitmapData));
            spriteCloud.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

            for(var i:int = 0; i < maxParticles; i++) {
                s = new Sprite2D();
                s.alpha = i / maxParticles;
                s.vx = NumberUtil.rndMinMax(-5.0, 5.0);
                s.vy = NumberUtil.rndMinMax(-5.0, 5.0);
                s.scaleX = s.scaleY = 1.0;
                spriteCloud.addChild(s);
            }

            addChild(spriteCloud);
        }


        override protected function step(elapsed:Number):void {
            for each (var child:Node2D in spriteCloud.children) {
                child.x += child.vx;
                child.y += child.vy;
                child.alpha -= 0.01;
                child.rotation += 20.0;
                child.scaleX -= 0.01;
                child.scaleY -= 0.01;
                child.tint = ColorUtil.mixColors(0xFF0099, 0x0099FF, child.alpha);

                if(child.alpha <= 0.0) {
                    child.alpha = 1.0;
                    child.x = stage.mouseX;
                    child.y = stage.mouseY;
                    child.scaleX = child.scaleY = 1.0;
                }
            }
        }
    }
}
