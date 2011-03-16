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

package de.nulldesign.nd2d.display {
    import de.nulldesign.nd2d.geom.Face;
    import de.nulldesign.nd2d.geom.Vertex;
    import de.nulldesign.nd2d.materials.ParticleSystemMaterial;
    import de.nulldesign.nd2d.utils.ColorUtil;
    import de.nulldesign.nd2d.utils.NumberUtil;
    import de.nulldesign.nd2d.utils.ParticleSystemPreset;
    import de.nulldesign.nd2d.utils.TextureHelper;
    import de.nulldesign.nd2d.utils.VectorUtil;

    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;

    public class ParticleSystem2D extends Node2D {

        protected var particles:Vector.<Particle>;
        protected var particleBitmap:BitmapData;
        protected var activeParticles:uint;
        protected var faceList:Vector.<Face>;
        protected var material:ParticleSystemMaterial;
        protected var texW:Number;
        protected var texH:Number;
        protected var maxCapacity:uint;
        protected var config:ParticleSystemPreset = new ParticleSystemPreset();

        public var gravity:Point = new Point(0.0, 0.0);

        protected var currentTime:Number;
        protected var startTime:Number;

        override public function get numTris():int {
            return activeParticles * 2;
        }

        public function ParticleSystem2D(particleBitmap:BitmapData, maxCapacity:uint) {
            super();
            init(particleBitmap, maxCapacity);
        }

        public function reset():void {
            startTime = getTimer();
            currentTime = 0;
            activeParticles = 1;
        }

        protected function init(particleBitmap:BitmapData, maxCapacity:uint):void {

            this.maxCapacity = maxCapacity;
            this.particleBitmap = particleBitmap;

            var textureDimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(particleBitmap);

            material = new ParticleSystemMaterial(particleBitmap);

            texW = textureDimensions.x / 2.0;
            texH = textureDimensions.y / 2.0;

            particles = new Vector.<Particle>(maxCapacity, true);
            faceList = new Vector.<Face>(maxCapacity * 2, true);

            var f:int = 0;
            startTime = getTimer();
            currentTime = 0;

            for(var i:int = 0; i < maxCapacity; i++) {
                particles[i] = new Particle();
                faceList[f++] = new Face(particles[i].v1, particles[i].v2, particles[i].v3, particles[i].uv1, particles[i].uv2, particles[i].uv3);
                faceList[f++] = new Face(particles[i].v1, particles[i].v3, particles[i].v4, particles[i].uv1, particles[i].uv3, particles[i].uv4);

                var angle:Number = NumberUtil.rndMinMax(VectorUtil.deg2rad(config.minEmitAngle), VectorUtil.deg2rad(config.maxEmitAngle));
                var speed:Number = NumberUtil.rndMinMax(config.minSpeed, config.maxSpeed);

                initParticle(NumberUtil.rndMinMax(config.minStartPosition.x, config.maxStartPosition.x), NumberUtil.rndMinMax(config.minStartPosition.y, config.maxStartPosition.y), Math.sin(angle) * speed, Math.cos(angle) * speed, config.startColor, config.endColor, config.startAlpha, config.endAlpha, NumberUtil.rndMinMax(config.minStartSize, config.maxStartSize), NumberUtil.rndMinMax(config.minEndSize, config.maxEndSize), NumberUtil.rndMinMax(config.minLife, config.maxLife), config.spawnDelay * i);
            }

            activeParticles = 1;
        }

        protected function initParticle(x:Number, y:Number, vx:Number, vy:Number, startColor:Number, endColor:Number, startAlpha:Number, endAlpha:Number, startSize:Number, endSize:Number, life:Number, startTime:Number):void {

            // position
            var p:Particle = particles[activeParticles];

            p.v1.x = -texW + x;
            p.v1.y = -texH + y;
            p.v2.x = texW + x;
            p.v2.y = -texH + y;
            p.v3.x = texW + x;
            p.v3.y = texH + y;
            p.v4.x = -texW + x;
            p.v4.y = texH + y;

            // start color
            p.v1.color = startColor;
            p.v1.a = startAlpha;
            p.v2.color = startColor;
            p.v2.a = startAlpha;
            p.v3.color = startColor;
            p.v3.a = startAlpha;
            p.v4.color = startColor;
            p.v4.a = startAlpha;

            // velocity
            p.v1.targetVertex = new Vertex(vx, vy);
            p.v2.targetVertex = new Vertex(vx, vy);
            p.v3.targetVertex = new Vertex(vx, vy);
            p.v4.targetVertex = new Vertex(vx, vy);

            var r:Number = ColorUtil.r(endColor);
            var g:Number = ColorUtil.g(endColor);
            var b:Number = ColorUtil.b(endColor);

            // end color in target normal
            p.v1.targetVertex.normal = new Vector3D(r, g, b, endAlpha);
            p.v2.targetVertex.normal = new Vector3D(r, g, b, endAlpha);
            p.v3.targetVertex.normal = new Vector3D(r, g, b, endAlpha);
            p.v4.targetVertex.normal = new Vector3D(r, g, b, endAlpha);

            // store birth and life properties in the normal!
            p.v1.normal = new Vector3D(startTime, life, startSize, endSize);
            p.v2.normal = new Vector3D(startTime, life, startSize, endSize);
            p.v3.normal = new Vector3D(startTime, life, startSize, endSize);
            p.v4.normal = new Vector3D(startTime, life, startSize, endSize);

            ++activeParticles;
        }

        override protected function step(t:Number):void {
            currentTime = getTimer() - startTime;

            if(activeParticles < maxCapacity) {
                activeParticles = Math.min(Math.ceil(currentTime / config.spawnDelay), maxCapacity);
            }
        }

        override protected function draw(context:Context3D, camera:Camera2D):void {

            super.draw(context, camera);

            material.blendMode = blendMode;
            material.modelViewMatrix = modelViewMatrix;
            material.projectionMatrix = camera.getProjectionMatrix();

            material.currentTime = currentTime;
            material.gravity = gravity;
            material.generateBufferData(context, faceList);
            material.prepareForRender(context);

            context.drawTriangles(material.indexBuffer, 0, activeParticles * 2);

            material.clearAfterRender(context);
        }
    }
}

import de.nulldesign.nd2d.geom.UV;
import de.nulldesign.nd2d.geom.Vertex;

class Particle {
    public var v1:Vertex = new Vertex(-1, -1, 0.0);
    public var v2:Vertex = new Vertex(1, -1, 0.0);
    public var v3:Vertex = new Vertex(1, 1, 0.0);
    public var v4:Vertex = new Vertex(-1, 1, 0.0);
    public var uv1:UV = new UV(0, 0);
    public var uv2:UV = new UV(1, 0);
    public var uv3:UV = new UV(1, 1);
    public var uv4:UV = new UV(0, 1);

    /*
     union {
     // Mode A: gravity, direction, radial accel, tangential accel
     struct {
     CGPoint		dir;
     float		radialAccel;
     float		tangentialAccel;
     } A;

     // Mode B: radius mode
     struct {
     float		angle;
     float		degreesPerSecond;
     float		radius;
     float		deltaRadius;
     } B;
     } mode;
     */
}