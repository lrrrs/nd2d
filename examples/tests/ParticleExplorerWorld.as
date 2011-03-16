/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: https://github.com/nulldesign/nd2d
 *
 *
 *  Licence Agreement
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 * /
 */

/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 16.03.11 17:10
 */
package tests {
    import com.bit101.components.ColorChooser;
    import com.bit101.components.HUISlider;

    import de.nulldesign.nd2d.display.ParticleSystem2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.World2D;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.utils.ParticleSystemPreset;

    import flash.display.BitmapData;
    import flash.display3D.Context3DRenderMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class ParticleExplorerWorld extends World2D {

        [Embed(source="/assets/particle_small.png")]
        private var particleClass:Class;

        private var bmp:BitmapData;

        private var maxParticles:uint = 2000;

        private var timer:Timer = new Timer(2000, 0);

        private var scene:Scene2D;
        private var particles:ParticleSystem2D;
        private var preset:ParticleSystemPreset = new ParticleSystemPreset();

        public function ParticleExplorerWorld() {

            super(Context3DRenderMode.AUTO, 60);

            scene = new Scene2D();
            setActiveScene(scene);

            bmp = new particleClass().bitmapData;
            particles = new ParticleSystem2D(bmp, maxParticles, preset);
            particles.blendMode = BlendModePresets.ADD2;

            timer.addEventListener(TimerEvent.TIMER, updateSystem);

            scene.addChild(particles);

            statsVisible = false;
        }

        override protected function addedToStage(event:Event):void {

            super.addedToStage(event);

            var s:HUISlider;
            var c:ColorChooser;

            s = new HUISlider(this, 0, 5, "minStartX", changeHandler);
            s.minimum = -stage.stageWidth / 2;
            s.maximum = stage.stageWidth / 2;

            s = new HUISlider(this, 0, 20, "maxStartX", changeHandler);
            s.minimum = -stage.stageWidth / 2;
            s.maximum = stage.stageWidth / 2;

            s = new HUISlider(this, 0, 35, "minStartY", changeHandler);
            s.minimum = -stage.stageHeight / 2;
            s.maximum = stage.stageHeight / 2;

            s = new HUISlider(this, 0, 50, "maxStartY", changeHandler);
            s.minimum = -stage.stageHeight / 2;
            s.maximum = stage.stageHeight / 2;

            s = new HUISlider(this, 0, 65, "minSpeed", changeHandler);
            s.minimum = 0;
            s.maximum = 1000;
            s.value = preset.minSpeed;

            s = new HUISlider(this, 0, 80, "maxSpeed", changeHandler);
            s.minimum = 0;
            s.maximum = 1000;
            s.value = preset.maxSpeed;

            s = new HUISlider(this, 0, 95, "minEmitAngle", changeHandler);
            s.minimum = 0;
            s.maximum = 360;
            s.value = preset.minEmitAngle;

            s = new HUISlider(this, 0, 110, "maxEmitAngle", changeHandler);
            s.minimum = 0;
            s.maximum = 360;
            s.value = preset.maxEmitAngle;

            c = new ColorChooser(this, 0, 125, preset.startColor, changeHandler);
            c.tag = 0;

            s = new HUISlider(this, 0, 145, "startAlpha", changeHandler);
            s.minimum = 0;
            s.maximum = 1;
            s.value = preset.startAlpha;

            c = new ColorChooser(this, 0, 160, preset.endColor, changeHandler);
            c.tag = 1;

            s = new HUISlider(this, 0, 180, "endAlpha", changeHandler);
            s.minimum = 0;
            s.maximum = 1;
            s.value = preset.endAlpha;

            s = new HUISlider(this, 0, 195, "spawnDelay", changeHandler);
            s.minimum = 0;
            s.maximum = 100;
            s.value = preset.spawnDelay;

            s = new HUISlider(this, 0, 210, "minLife", changeHandler);
            s.minimum = 0;
            s.maximum = 10000;
            s.value = preset.minLife;

            s = new HUISlider(this, 0, 225, "maxLife", changeHandler);
            s.minimum = 0;
            s.maximum = 10000;
            s.value = preset.maxLife;

            s = new HUISlider(this, 0, 240, "minStartSize", changeHandler);
            s.minimum = 0;
            s.maximum = 10;
            s.value = preset.minStartSize;

            s = new HUISlider(this, 0, 255, "maxStartSize", changeHandler);
            s.minimum = 0;
            s.maximum = 10;
            s.value = preset.maxStartSize;

            s = new HUISlider(this, 0, 270, "minEndSize", changeHandler);
            s.minimum = 0;
            s.maximum = 10;
            s.value = preset.minEndSize;

            s = new HUISlider(this, 0, 285, "maxEndSize", changeHandler);
            s.minimum = 0;
            s.maximum = 10;
            s.value = preset.maxEndSize;

            s = new HUISlider(this, 0, 300, "maxParticles", changeHandler);
            s.minimum = 0;
            s.maximum = 10000;
            s.value = maxParticles;
        }

        private function changeHandler(e:Event):void {

            var s:HUISlider = e.target as HUISlider;
            var c:ColorChooser = e.target as ColorChooser;

            //drrty switch ;)
            if(s) {

                switch(s.label) {
                    case "minStartX":
                        preset.minStartPosition.x = s.value;
                        break;
                    case "minStartY":
                        preset.minStartPosition.y = s.value;
                        break;
                    case "maxStartX":
                        preset.maxStartPosition.x = s.value;
                        break;
                    case "maxStartY":
                        preset.maxStartPosition.y = s.value;
                        break;
                    case "minSpeed":
                        preset.minSpeed = s.value;
                        break;
                    case "maxSpeed":
                        preset.maxSpeed = s.value;
                        break;
                    case "minEmitAngle":
                        preset.minEmitAngle = s.value;
                        break;
                    case "maxEmitAngle":
                        preset.maxEmitAngle = s.value;
                        break;
                    case "startAlpha":
                        preset.startAlpha = s.value;
                        break;
                    case "endAlpha":
                        preset.endAlpha = s.value;
                        break;
                    case "spawnDelay":
                        preset.spawnDelay = s.value;
                        break;
                    case "minLife":
                        preset.minLife = s.value;
                        break;
                    case "maxLife":
                        preset.maxLife = s.value;
                        break;
                    case "minStartSize":
                        preset.minStartSize = s.value;
                        break;
                    case "maxStartSize":
                        preset.maxStartSize = s.value;
                        break;
                    case "minEndSize":
                        preset.minEndSize = s.value;
                        break;
                    case "maxEndSize":
                        preset.maxEndSize = s.value;
                        break;
                    case "maxParticles":
                        maxParticles = s.value;
                        break;
                }
            }

            if(c) {
                switch(c.tag) {
                    case 0:
                        preset.startColor = c.value;
                        break;
                    case 1:
                        preset.endColor = c.value;
                        break;
                }
            }

            timer.reset();
            timer.start();
        }

        private function updateSystem(e:TimerEvent):void {

            scene.removeChild(particles);

            particles = new ParticleSystem2D(bmp, maxParticles, preset);
            particles.blendMode = BlendModePresets.ADD2;

            scene.addChild(particles);

            timer.stop();
        }

        override protected function step(t:Number):void {
            particles.x = stage.stageWidth / 2;
            particles.y = stage.stageHeight / 2;
            particles.gravity.x = (mouseX / stage.stageWidth * 2.0 - 1.0) * 2000.0;
            particles.gravity.y = (mouseY / stage.stageHeight * 2.0 - 1.0) * 2000.0;
        }
    }
}
