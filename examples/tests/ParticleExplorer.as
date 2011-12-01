/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package tests {

	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.ParticleSystem2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.ParticleSystemPreset;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ParticleExplorer extends Scene2D {

        [Embed(source="/assets/particle_small.png")]
        private var particleClass:Class;

        private var tex:Texture2D;

        private var maxParticles:uint = 2000;

        private var timer:Timer = new Timer(2000, 0);

        private var particles:ParticleSystem2D;
        private var preset:ParticleSystemPreset = new ParticleSystemPreset();

        private var panel:Sprite;
		private var burst:Boolean = false;

        public function ParticleExplorer() {

            tex = Texture2D.textureFromBitmapData(new particleClass().bitmapData);
            particles = new ParticleSystem2D(tex, maxParticles, preset);
            particles.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

            timer.addEventListener(TimerEvent.TIMER, updateSystem);

            addChild(particles);
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        private function removedFromStage(e:Event):void {
            if(panel) {
                stage.removeChild(panel);
            }
        }

        protected function addedToStage(event:Event):void {

            if(!panel) {
                panel = new Sprite();
                panel.graphics.beginFill(0x000000, 1.0);
                panel.graphics.drawRect(0, 0, 200, 450);
                panel.graphics.endFill();

                var s:HUISlider;
                var c:ColorChooser;
                var nextY:Number = 5;

				Style.LABEL_TEXT = 0xFFFFFF;

                s = new HUISlider(panel, 0, nextY, "minStartX", changeHandler);
                s.minimum = -stage.stageWidth / 2;
                s.maximum = stage.stageWidth / 2;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxStartX", changeHandler);
                s.minimum = -stage.stageWidth / 2;
                s.maximum = stage.stageWidth / 2;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minStartY", changeHandler);
                s.minimum = -stage.stageHeight / 2;
                s.maximum = stage.stageHeight / 2;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxStartY", changeHandler);
                s.minimum = -stage.stageHeight / 2;
                s.maximum = stage.stageHeight / 2;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minSpeed", changeHandler);
                s.minimum = 0;
                s.maximum = 1000;
                s.value = preset.minSpeed;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxSpeed", changeHandler);
                s.minimum = 0;
                s.maximum = 1000;
                s.value = preset.maxSpeed;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minEmitAngle", changeHandler);
                s.minimum = 0;
                s.maximum = 360;
                s.value = preset.minEmitAngle;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxEmitAngle", changeHandler);
                s.minimum = 0;
                s.maximum = 360;
                s.value = preset.maxEmitAngle;
                nextY += 20;

                c = new ColorChooser(panel, 0, nextY, preset.startColor, changeHandler);
                c.tag = 0;
                c.usePopup = true;
                nextY += 20;

                c = new ColorChooser(panel, 0, nextY, preset.startColorVariance, changeHandler);
                c.usePopup = true;
                c.tag = 1;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "startAlpha", changeHandler);
                s.minimum = 0;
                s.maximum = 1;
                s.value = preset.startAlpha;
                nextY += 20;

                c = new ColorChooser(panel, 0, nextY, preset.endColor, changeHandler);
                c.usePopup = true;
                c.tag = 2;
                nextY += 20;

                c = new ColorChooser(panel, 0, nextY, preset.endColorVariance, changeHandler);
                c.usePopup = true;
                c.tag = 3;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "endAlpha", changeHandler);
                s.minimum = 0;
                s.maximum = 1;
                s.value = preset.endAlpha;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "spawnDelay", changeHandler);
                s.minimum = 0;
                s.maximum = 10;
                s.value = preset.spawnDelay;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minLife", changeHandler);
                s.minimum = 0;
                s.maximum = 10000;
                s.value = preset.minLife;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxLife", changeHandler);
                s.minimum = 0;
                s.maximum = 10000;
                s.value = preset.maxLife;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minStartSize", changeHandler);
                s.minimum = 0;
                s.maximum = 10;
                s.value = preset.minStartSize;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxStartSize", changeHandler);
                s.minimum = 0;
                s.maximum = 10;
                s.value = preset.maxStartSize;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "minEndSize", changeHandler);
                s.minimum = 0;
                s.maximum = 10;
                s.value = preset.minEndSize;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxEndSize", changeHandler);
                s.minimum = 0;
                s.maximum = 10;
                s.value = preset.maxEndSize;
                nextY += 20;

                s = new HUISlider(panel, 0, nextY, "maxParticles", changeHandler);
                s.minimum = 0;
                s.maximum = 10000;
                s.value = maxParticles;
				nextY += 30;

				var check:CheckBox = new CheckBox(panel, 10, nextY, "burst", changeHandler);
            }

            stage.addChild(panel);
        }

        private function changeHandler(e:Event):void {

            var s:HUISlider = e.target as HUISlider;
            var c:ColorChooser = e.target as ColorChooser;
			var check:CheckBox = e.target as CheckBox;

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
                        preset.startColorVariance = c.value;
                        break;
                    case 2:
                        preset.endColor = c.value;
                        break;
                    case 3:
                        preset.endColorVariance = c.value;
                        break;
                }
            }

			if(check) {
				burst = check.selected;
			}

            timer.reset();
            timer.start();
        }

        private function updateSystem(e:TimerEvent):void {

            removeChild(particles);
            particles.dispose();

            particles = new ParticleSystem2D(tex, maxParticles, preset, burst);
            particles.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

            addChild(particles);

            timer.stop();
        }

        override protected function step(t:Number):void {
            particles.x = stage.stageWidth / 2;
            particles.y = stage.stageHeight / 2;
            particles.gravity.x = (stage.mouseX / stage.stageWidth * 2.0 - 1.0) * 2000.0;
            particles.gravity.y = (stage.mouseY / stage.stageHeight * 2.0 - 1.0) * 2000.0;
        }
    }
}
