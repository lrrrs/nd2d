/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.display {
    import flash.display3D.Context3D;

    import flash.geom.Point;

    import flash.geom.Vector3D;

    import net.hires.debug.Stats;

    public class Scene2D extends Node2D {

        public var statsRef:Stats;

        public function Scene2D() {
            super();
        }

        override internal function stepNode(t:Number):void {
            for each(var child:Node2D in children) {
                child.stepNode(t);
            }
        }

        override internal function drawNode(context:Context3D, camera:Camera2D):void {

            var totalTris:int = 0;
            var drawCalls:int = 0;

            for each(var child:Node2D in children) {
                child.drawNode(context, camera);
                totalTris += child.numTris;
                drawCalls += 1;
            }

            statsRef.update(drawCalls, totalTris);
        }
    }
}