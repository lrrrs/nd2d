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

package de.nulldesign.nd2d.utils {

	import flash.geom.Point;

	public class ParticleSystemPreset {

        public var minStartPosition:Point = new Point(-5.0, 0.0);
        public var maxStartPosition:Point = new Point(5.0, 0.0);

        public var minSpeed:Number = 100.0;
        public var maxSpeed:Number = 300.0;

        public var minEmitAngle:Number = 0.0;
        public var maxEmitAngle:Number = 360.0;

        public var startColor:Number = 0xD60606;
        public var startColorVariance:Number = 0xD60606;

        public var startAlpha:Number = 1.0;

        public var endColor:Number = 0xF9D101;
        public var endColorVariance:Number = 0xF9D101;

        public var endAlpha:Number = 0.0;

        public var spawnDelay:Number = 10.0;

        public var minLife:Number = 2000.0;
        public var maxLife:Number = 3000.0;

        public var minStartSize:Number = 1.0;
        public var maxStartSize:Number = 1.0;

        public var minEndSize:Number = 1.0;
        public var maxEndSize:Number = 2.0;
    }
}