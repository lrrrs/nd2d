/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.utils {
    import flash.geom.Point;

    public class ParticleSystemPreset {

        public var gravity:Point = new Point(0.0, 0.0);

        public var minStartPosition:Point = new Point(-5.0, 0.0);
        public var maxStartPosition:Point = new Point(5.0, 0.0);

        public var minSpeed:Number = 100.0;
        public var maxSpeed:Number = 300.0;

        public var minEmitAngle:Number = 0.0;
        public var maxEmitAngle:Number = 360.0;

        public var startColor:Number = 0xD60606;
        //public var startColorVariance:Number = 0.0;
        public var startAlpha:Number = 1.0;

        public var endColor:Number = 0xF9D101;
        //public var endColorVariance:Number = 0.0;
        public var endAlpha:Number = 0.0;

        public var spawnDelay:Number = 10.0;

        public var minLife:Number = 2000.0;
        public var maxLife:Number = 3000.0;

        public var minStartSize:Number = 1.0;
        public var maxStartSize:Number = 1.0;

        public var minEndSize:Number = 1.0;
        public var maxEndSize:Number = 2.0;

        public function ParticleSystemPreset() {
        }
    }
}