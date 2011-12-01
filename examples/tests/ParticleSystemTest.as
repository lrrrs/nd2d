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

	import de.nulldesign.nd2d.display.ParticleSystem2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
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

            particles = new ParticleSystem2D(Texture2D.textureFromBitmapData(new particleClass().bitmapData), 1000, psp);
            particles.gravity = new Point(0.0, -1500.0);
            //particles.scaleX = particles.scaleY = 4.0;
            particles.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;

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