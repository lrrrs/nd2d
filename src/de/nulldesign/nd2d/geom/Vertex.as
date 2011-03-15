/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.geom {
    import flash.geom.Vector3D;

    public class Vertex extends Vector3D {

        private static var UI_COUNT:Number = 0;
        public var uid:Number = ++UI_COUNT;

        public var color:Number = 0xFFFFFF;
        public var faceRefs:Vector.<Face> = new Vector.<Face>();
        public var normal:Vector3D;

        public var targetVertex:Vertex;

        public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0, color:Number = NaN) {
            super(x, y, z, 1.0);
        }

        public function get r():Number {
            return (color >> 16) / 0xFF;
        }

        public function get g():Number {
            return (color >> 8 & 0xFF) / 0xFF;
        }

        public function get b():Number {
            return (color & 0xFF) / 0xFF;
        }

        public var a:Number = 1.0;

        override public function clone():Vector3D {
            return new Vertex(x, y, z, color);
        }
    }
}
