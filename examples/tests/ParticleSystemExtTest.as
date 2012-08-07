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
	import tests.effect.ParticleSystemExt;
	import tests.effect.RectEmitter;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.ParticleSystemPreset;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ParticleSystemExtTest extends Scene2D {
		
		[Embed(source="/assets/crate.jpg")]
		private var particleClass:Class;
		
		private var particles:ParticleSystemExt;
		
		private var blah:Sprite;
		
		public function ParticleSystemExtTest() {
			
			var emitter:RectEmitter = new RectEmitter();
			emitter.color = 0x222222;
			emitter.colorRange = 0xaaaaaa;
			emitter.directionFrom.setTo(-500,0,0);
			emitter.directionTo.setTo(600,0,200);
			emitter.emitPeriod = 5;
			emitter.emitTime = 1;
			emitter.emitRate = 500;
			emitter.EmitterRectFrom.setTo(-200,-200,0);
			emitter.EmitterRectTo.setTo(200,200,0)
			emitter.sizeRange = 15
			emitter.sizeX = 10;
			emitter.sizeY = 10;
			emitter.vel = 200;
			emitter.rotVel = 5;
			emitter.rotRange = 10;
			//			emitter.alpha = 0.9
			
			particles = new ParticleSystemExt(1000,emitter,Texture2D.textureFromBitmapData(new particleClass().bitmapData));
			addChild(particles);
			particles.start();
			particles.blendMode = BlendModePresets.ADD_PREMULTIPLIED_ALPHA;
			
			
		}
		
		
		
		
		override protected function step(elapsed:Number):void {
			particles.x = stage.stageWidth / 2.0;
			particles.y = stage.stageHeight /2;
		}
	}
}