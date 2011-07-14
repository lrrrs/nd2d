package tests {

    import de.nulldesign.nd2d.display.ParticleSystem2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.utils.ParticleSystemPreset;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ParticleSystemTest extends Scene2D {

        [Embed(source="/assets/particle_small.png")]
        private var particleClass:Class;

        private var particles:ParticleSystem2D;

        private var blah:Sprite;

        public function ParticleSystemTest() {

            var psp:ParticleSystemPreset = new ParticleSystemPreset();
            psp.minStartPosition.x = -300.0;
            psp.maxStartPosition.x = 300.0;
            psp.startColor = 0x00FF00;
            psp.startColorVariance = 0x0000FF;
            psp.endColor = 0xAAFF33;
            psp.endColorVariance = 0xFF9966;
            psp.minStartSize = 3.0;
            psp.maxStartSize = 5.0;
            psp.minEndSize = 0.0;
            psp.maxEndSize = 0.0;
            psp.spawnDelay = 5.0;

            particles = new ParticleSystem2D(new particleClass().bitmapData, 1000, psp);
            particles.gravity = new Point(0.0, -1500.0);
            //particles.scaleX = particles.scaleY = 4.0;
            particles.blendMode = BlendModePresets.ADD;

            addChild(particles);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        private function removedFromStage(e:Event):void {
            if(blah) {
                blah.removeEventListener(MouseEvent.CLICK, resetClick);
                stage.removeChild(blah);
                blah = null;
            }
        }

        private function addedToStage(e:Event):void {

            blah = new Sprite();
            blah.graphics.beginFill(0xFF9900, 10.0);
            blah.graphics.drawCircle(0, 0, 10.0);
            blah.graphics.endFill();
            blah.x = 150;
            blah.y = 10;
            blah.addEventListener(MouseEvent.CLICK, resetClick);
            stage.addChild(blah);
        }

        private function resetClick(e:MouseEvent):void {
            particles.reset();
        }

        override protected function step(elapsed:Number):void {
            particles.x = stage.stageWidth / 2.0;
            particles.y = stage.stageHeight - 50.0;
        }
    }
}