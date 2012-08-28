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

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.ParticleSystemMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.ColorUtil;
	import de.nulldesign.nd2d.utils.NumberUtil;
	import de.nulldesign.nd2d.utils.ParticleSystemPreset;
	import de.nulldesign.nd2d.utils.VectorUtil;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * Dispatched when the system's burst is finished
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * <p>The particle system can render thousands of instances of a bitmap on the GPU</p>
	 * Since all movement based on the rules to supply with the ParticleSystemPreset are calculated on the GPU, you won't be able to control individual particles.
	 * Use a Sprite2DBatch or Sprite2DCloud for this need
	 */
	public class ParticleSystem2D extends Node2D {

		protected var particles:Vector.<Particle>;
		protected var activeParticles:uint;
		protected var faceList:Vector.<Face>;
		protected var material:ParticleSystemMaterial;
		protected var texW:Number;
		protected var texH:Number;
		protected var maxCapacity:uint;
		protected var preset:ParticleSystemPreset;

		public var gravity:Point = new Point(0.0, 0.0);

		protected var currentTime:Number;
		protected var startTime:Number;
		protected var burst:Boolean;
		protected var burstDone:Boolean = false;
		protected var lastParticleDeathTime:Number = 0.0;

		override public function get numTris():uint {
			return activeParticles * 2;
		}

		override public function get drawCalls():uint {
			return material.drawCalls;
		}

		public function ParticleSystem2D(textureObject:Texture2D, maxCapacity:uint, preset:ParticleSystemPreset, burst:Boolean = false) {
			super();
			this.preset = preset;
			this.burst = burst;
			init(textureObject, maxCapacity);
		}

		public function reset():void {
			startTime = getTimer();
			currentTime = 0;
			activeParticles = 1;
			burstDone = false;
		}

		protected function init(textureObject:Texture2D, maxCapacity:uint):void {

			this.maxCapacity = maxCapacity;

			var tex:Texture2D;
			tex = textureObject;

			material = new ParticleSystemMaterial(tex, burst);

			texW = tex.textureWidth / 2.0;
			texH = tex.textureHeight / 2.0;

			particles = new Vector.<Particle>(maxCapacity, true);
			faceList = new Vector.<Face>(maxCapacity * 2, true);

			var f:int = 0;
			startTime = getTimer();
			currentTime = 0;

			for(var i:int = 0; i < maxCapacity; i++) {

				particles[i] = new Particle();

				faceList[f++] = new Face(particles[i].v1, particles[i].v2, particles[i].v3, particles[i].uv1,
						particles[i].uv2, particles[i].uv3);

				faceList[f++] = new Face(particles[i].v1, particles[i].v3, particles[i].v4, particles[i].uv1,
						particles[i].uv3, particles[i].uv4);

				var angle:Number = NumberUtil.rndMinMax(VectorUtil.deg2rad(preset.minEmitAngle),
						VectorUtil.deg2rad(preset.maxEmitAngle));

				var speed:Number = NumberUtil.rndMinMax(preset.minSpeed, preset.maxSpeed);

				var particleStartColor:Number = ColorUtil.mixColors(preset.startColor, preset.startColorVariance,
						NumberUtil.rnd0_1());
				var particleEndColor:Number = ColorUtil.mixColors(preset.endColor, preset.endColorVariance,
						NumberUtil.rnd0_1());

				initParticle(NumberUtil.rndMinMax(preset.minStartPosition.x, preset.maxStartPosition.x),
						NumberUtil.rndMinMax(preset.minStartPosition.y, preset.maxStartPosition.y),
						Math.sin(angle) * speed, Math.cos(angle) * speed, particleStartColor, particleEndColor,
						preset.startAlpha, preset.endAlpha,
						NumberUtil.rndMinMax(preset.minStartSize, preset.maxStartSize),
						NumberUtil.rndMinMax(preset.minEndSize, preset.maxEndSize),
						NumberUtil.rndMinMax(preset.minLife, preset.maxLife), preset.spawnDelay * i);
			}

			activeParticles = 1;

			if(preset.spawnDelay == 0) {
				activeParticles = maxCapacity;
			}
		}

		protected function initParticle(x:Number, y:Number, vx:Number, vy:Number, startColor:Number, endColor:Number, startAlpha:Number, endAlpha:Number, startSize:Number, endSize:Number, life:Number, startTime:Number):void {

			var p:Particle = particles[activeParticles];

			p.v1.x = -texW;
			p.v1.y = -texH;
			p.v2.x = texW;
			p.v2.y = -texH;
			p.v3.x = texW;
			p.v3.y = texH;
			p.v4.x = -texW;
			p.v4.y = texH;

			p.v1.startColorR = p.v2.startColorR = p.v3.startColorR = p.v4.startColorR = ColorUtil.r(startColor);
			p.v1.startColorG = p.v2.startColorG = p.v3.startColorG = p.v4.startColorG = ColorUtil.g(startColor);
			p.v1.startColorB = p.v2.startColorB = p.v3.startColorB = p.v4.startColorB = ColorUtil.b(startColor);
			p.v1.startAlpha = p.v2.startAlpha = p.v3.startAlpha = p.v4.startAlpha = startAlpha;
			p.v1.startX = p.v2.startX = p.v3.startX = p.v4.startX = x;
			p.v1.startY = p.v2.startY = p.v3.startY = p.v4.startY = y;
			p.v1.startSize = p.v2.startSize = p.v3.startSize = p.v4.startSize = startSize;
			p.v1.startTime = p.v2.startTime = p.v3.startTime = p.v4.startTime = startTime;
			p.v1.endColorR = p.v2.endColorR = p.v3.endColorR = p.v4.endColorR = ColorUtil.r(endColor);
			p.v1.endColorG = p.v2.endColorG = p.v3.endColorG = p.v4.endColorG = ColorUtil.g(endColor);
			p.v1.endColorB = p.v2.endColorB = p.v3.endColorB = p.v4.endColorB = ColorUtil.b(endColor);
			p.v1.endAlpha = p.v2.endAlpha = p.v3.endAlpha = p.v4.endAlpha = endAlpha;
			p.v1.vx = p.v2.vx = p.v3.vx = p.v4.vx = vx;
			p.v1.vy = p.v2.vy = p.v3.vy = p.v4.vy = vy;
			p.v1.life = p.v2.life = p.v3.life = p.v4.life = life;
			p.v1.endSize = p.v2.endSize = p.v3.endSize = p.v4.endSize = endSize;

			++activeParticles;

			lastParticleDeathTime = Math.max(startTime + life, lastParticleDeathTime);
		}

		override protected function step(elapsed:Number):void {
			currentTime = getTimer() - startTime;

			if(activeParticles < maxCapacity) {
				activeParticles = Math.min(Math.ceil(currentTime / preset.spawnDelay), maxCapacity);
			}

			if(burst && !burstDone && (currentTime > lastParticleDeathTime)) {
				burstDone = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}


		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			material.handleDeviceLoss();
		}

		override protected function draw(context:Context3D, camera:Camera2D):void {

			if(burstDone) {
				return;
			}

			material.blendMode = blendMode;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.currentTime = currentTime;
			material.gravity = gravity;
			material.render(context, faceList, 0, activeParticles * 2);
		}

		override public function dispose():void 
		{
			if(material) 
			{
				material.dispose();
				material = null;
			}

			super.dispose();
		}
	}
}

import de.nulldesign.nd2d.geom.ParticleVertex;
import de.nulldesign.nd2d.geom.UV;

class Particle {
	public var v1:ParticleVertex = new ParticleVertex(-1, -1, 0.0);
	public var v2:ParticleVertex = new ParticleVertex(1, -1, 0.0);
	public var v3:ParticleVertex = new ParticleVertex(1, 1, 0.0);
	public var v4:ParticleVertex = new ParticleVertex(-1, 1, 0.0);
	public var uv1:UV = new UV(0, 0);
	public var uv2:UV = new UV(1, 0);
	public var uv3:UV = new UV(1, 1);
	public var uv4:UV = new UV(0, 1);
}