/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.materials {
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    public class SpriteSheet {

        protected var spriteWidth:Number;
        protected var spriteHeight:Number;

        protected var ctime:Number = 0.0;
        protected var otime:Number = 0.0;
        protected var interp:Number = 0.0;
        protected var fps:uint;

        protected var activeAnimation:SpriteSheetAnimation;
        protected var animationMap:Dictionary = new Dictionary();

        public var bitmapData:BitmapData;
        public var uvOffset:Point = new Point(0.0, 0.0);
        public var uvSize:Point = new Point(0.0, 0.0);
        public var numSheetsPerRow:uint;

        public function get width():Number {
            return spriteWidth;
        }

        public function get height():Number {
            return spriteHeight;
        }

        protected var frameIdx:uint = 0;

        protected var _frame:uint = 0;

        public function get frame():uint {
            return _frame;
        }

        public function set frame(value:uint):void {
            _frame = value;
        }

        public function SpriteSheet(bitmapData:BitmapData, spriteWidth:Number, spriteHeight:Number, fps:uint) {
            this.bitmapData = bitmapData;
            this.spriteWidth = spriteWidth;
            this.spriteHeight = spriteHeight;
            this.fps = fps;

            init();
        }

        private function init():void {

            var textureDimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmapData);

            uvOffset = new Point((textureDimensions.x - bitmapData.width) / 2.0, (textureDimensions.y - bitmapData.height) / 2.0);
            uvOffset.x /= textureDimensions.x;
            uvOffset.y /= textureDimensions.y;

            uvSize = new Point(width / textureDimensions.x, height / textureDimensions.y);

            numSheetsPerRow = Math.round(bitmapData.width / width);
        }

        public function update(t:Number):void {
            ctime = t;

            // Update the timer part, to get time based animation
            interp += fps * (ctime - otime);
            if (interp >= 1.0) {
                frameIdx++;
                interp = 0;
            }

            if (activeAnimation.loop) {
                frameIdx = frameIdx % activeAnimation.numFrames;
            } else {
                frameIdx = Math.min(frameIdx, activeAnimation.numFrames - 1);
            }

            frame = activeAnimation.frames[frameIdx];

            otime = ctime;
        }

        public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {
            activeAnimation = new SpriteSheetAnimation(keyFrames, loop);
            animationMap[name] = activeAnimation;
        }

        public function playAnimation(name:String):void {
            activeAnimation = animationMap[name];
        }

        public function clone():SpriteSheet {
            var s:SpriteSheet = new SpriteSheet(bitmapData, spriteWidth, spriteHeight, fps);
            for (var name:String in animationMap) {
                var anim:SpriteSheetAnimation = animationMap[name];
                s.addAnimation(name, anim.frames.concat(), anim.loop);
            }

            return s;
        }
    }
}
