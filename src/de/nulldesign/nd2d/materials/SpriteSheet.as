/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
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

package de.nulldesign.nd2d.materials {
    import de.nulldesign.nd2d.utils.TextureHelper;

    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    public class SpriteSheet {

        protected var _spriteWidth:Number;
        protected var _spriteHeight:Number;

        protected var ctime:Number = 0.0;
        protected var otime:Number = 0.0;
        protected var interp:Number = 0.0;
        protected var fps:uint;

        protected var activeAnimation:SpriteSheetAnimation;
        protected var animationMap:Dictionary = new Dictionary();

        protected var numSheetsPerRow:uint;
        protected var numRows:uint;
        protected var numSheets:uint;

        public var bitmapData:BitmapData;
        public var uvOffset:Point = new Point(0.0, 0.0);
        public var uvSize:Point = new Point(0.0, 0.0);

        public function get spriteWidth():Number {
            return _spriteWidth;
        }

        public function get spriteHeight():Number {
            return _spriteHeight;
        }

        protected var frameIdx:uint = 0;

        public var frameUpdated:Boolean = true;

        protected var _frame:uint = 0;

        public function get frame():uint {
            return _frame;
        }

        public function set frame(value:uint):void {
            if(frame != value) {
                _frame = value;
                frameUpdated = true;
            }
        }

        public function get totalFrames():uint{
            return numSheets;
        }

        public function SpriteSheet(bitmapData:BitmapData, spriteWidth:Number, spriteHeight:Number, fps:uint) {
            this.bitmapData = bitmapData;
            this._spriteWidth = spriteWidth;
            this._spriteHeight = spriteHeight;
            this.fps = fps;

            init();
        }

        private function init():void {

            var textureDimensions:Point = TextureHelper.getTextureDimensionsFromBitmap(bitmapData);

            uvOffset = new Point((textureDimensions.x - bitmapData.width) / 2.0,
                                 (textureDimensions.y - bitmapData.height) / 2.0);
            uvOffset.x /= textureDimensions.x;
            uvOffset.y /= textureDimensions.y;

            uvSize = new Point(spriteWidth / textureDimensions.x, spriteHeight / textureDimensions.y);

            numSheetsPerRow = Math.round(bitmapData.width / spriteWidth);
            numRows = Math.round(bitmapData.height / spriteHeight);
            numSheets = numSheetsPerRow * numRows;
        }

        public function update(t:Number):void {

            if(!activeAnimation) return;

            ctime = t;

            // Update the timer part, to get time based animation
            interp += fps * (ctime - otime);
            if(interp >= 1.0) {
                frameIdx++;
                interp = 0;
            }

            if(activeAnimation.loop) {
                frameIdx = frameIdx % activeAnimation.numFrames;
            } else {
                frameIdx = Math.min(frameIdx, activeAnimation.numFrames - 1);
            }

            frame = activeAnimation.frames[frameIdx];

            otime = ctime;
        }

        public function getOffsetForFrame():Point {

            var rowIdx:uint = frame % numSheetsPerRow;
            var colIdx:uint = Math.floor(frame / numSheetsPerRow);

            var offset:Point = new Point();

            offset.x = uvSize.x * rowIdx;
            offset.y = uvSize.y * colIdx;

            return offset;
        }

        public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {
            activeAnimation = new SpriteSheetAnimation(keyFrames, loop);
            animationMap[name] = activeAnimation;
        }

        public function playAnimation(name:String, startIdx:uint = 0, restart:Boolean = false):void {
            if(restart || activeAnimation != animationMap[name]) {
                frameIdx = startIdx;
                activeAnimation = animationMap[name];
            }
        }

        public function clone():SpriteSheet {
            var s:SpriteSheet = new SpriteSheet(bitmapData, _spriteWidth, _spriteHeight, fps);
            s.frame = frame;

            for(var name:String in animationMap) {
                var anim:SpriteSheetAnimation = animationMap[name];
                s.addAnimation(name, anim.frames.concat(), anim.loop);
            }

            return s;
        }
    }
}
