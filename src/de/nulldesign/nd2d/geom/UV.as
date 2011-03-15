/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.geom {

    public class UV {

        private static var UI_COUNT:Number = 0;
        public var uid:Number = ++UI_COUNT;

        public var u:Number;
        public var v:Number;

        public function UV(u:Number = 0, v:Number = 0) {
            this.u = u;
            this.v = v;
        }

        public function toString():String {
            return "UV: " + u + " / " + v;
        }

        public function clone():UV {
            return new UV(u, v);
        }
    }
}
