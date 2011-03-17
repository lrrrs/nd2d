package tests {
    import de.nulldesign.nd2d.display.ParticleSystem2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.utils.ParticleSystemPreset;

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class ParticleSystemTest extends World2D {

        [Embed(source="/assets/particle_small.png")]
        private var particleClass:Class;

        private var scene:Scene2D;
        private var particles:ParticleSystem2D;

        public function ParticleSystemTest(renderMode:String, frameRate:uint) {
            super(renderMode, frameRate);

            scene = new Scene2D();
            setActiveScene(scene);

            particles = new ParticleSystem2D(new particleClass().bitmapData, 6000, new ParticleSystemPreset());
            //particles.scaleX = particles.scaleY = 4.0;
            particles.blendMode = BlendModePresets.ADD2;

            scene.addChild(particles);

            var blah:Sprite = new Sprite();
            blah.graphics.beginFill(0xFF9900, 10.0);
            blah.graphics.drawCircle(0, 0, 10.0);
            blah.graphics.endFill();
            blah.x = 150;
            blah.y = 10;
            blah.addEventListener(MouseEvent.CLICK, resetClick);
            addChild(blah);
        }

        private function resetClick(e:MouseEvent):void {
            particles.reset();
        }

        override protected function step(t:Number):void {
            particles.x = stage.stageWidth / 2;
            particles.y = stage.stageHeight / 2;
            particles.gravity.x = (mouseX / stage.stageWidth * 2.0 - 1.0) * 2000.0;
            particles.gravity.y = (mouseY / stage.stageHeight * 2.0 - 1.0) * 2000.0;
            //particles.rotation += 1;
        }
    }
}