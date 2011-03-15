/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.materials {
    public class SpriteSheetAnimation {

        public var loop:Boolean;
        public var frames:Array;
        public var numFrames:uint;

        public function SpriteSheetAnimation(frames:Array, loop:Boolean) {
            this.loop = loop;
            this.frames = frames;
            this.numFrames = frames.length;
        }
    }
}
