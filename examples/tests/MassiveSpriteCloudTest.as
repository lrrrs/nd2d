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

package tests {

	import com.bit101.components.PushButton;

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class MassiveSpriteCloudTest extends Scene2D {

        [Embed(source="/assets/spritechar2.png")]
        private var cubeTexture:Class;

        private var sprites:Vector.<Sprite2D>;
        private var spriteCloud:Sprite2DCloud;

        private var numSprites:uint = 1600;

        private var addSpritesButton:PushButton;

        public function MassiveSpriteCloudTest() {

            backgroundColor = 0x666666;

            sprites = new Vector.<Sprite2D>();
            var tex:Texture2D = Texture2D.textureFromBitmapData(new cubeTexture().bitmapData);
            var s:Sprite2D;

            var sheet:SpriteSheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 24, 32, 10);
            sheet.addAnimation("up", [0, 1, 2], true);
            sheet.addAnimation("right", [3, 4, 5], true);
            sheet.addAnimation("down", [6, 7, 8], true);
            sheet.addAnimation("left", [9, 10, 11], true);

            spriteCloud = new Sprite2DCloud(numSprites, tex);
            //spriteCloud = new Sprite2DBatch(tex);
            spriteCloud.setSpriteSheet(sheet);

            addSpritesClick();

            addChild(spriteCloud);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        private function addSpritesClick(event:MouseEvent = null):void {

            var s:Sprite2D;
            for(var i:int = 0; i < 100; i++) {

                s = new Sprite2D();
                s.x = Math.round(Math.random() * 1000);
                s.y = Math.round(Math.random() * 1000);
                s.vx = (Math.random() - Math.random()) * 3;
                s.vy = (Math.random() - Math.random()) * 3;
                s.pivot = new Point(0, -15);

                if(spriteCloud.addChild(s)) {
                    sprites.push(s);
                }

                if(sprites.length == 1) {   // alpha, tint & scale test for sprites in clouds
                    s.alpha = 0.2;
                    s.tint = 0x00FF00;
                    s.scaleX = s.scaleY = 2.0;
                }
            }
        }

        private function removedFromStage(event:Event):void {
            if(stage.contains(addSpritesButton)) {
                stage.removeChild(addSpritesButton);
            }
        }

        private function addedToStage(event:Event):void {

            if(!addSpritesButton) {
                addSpritesButton = new PushButton(stage, 0.0, 150.0, "addChild", addSpritesClick);
            }

            if(!stage.contains(addSpritesButton)) {
                stage.addChild(addSpritesButton);
            }
        }

        override protected function step(elapsed:Number):void {

            var s:Sprite2D;
            var len:int = sprites.length;
            var i:int = len;
            var vxabs:Number;
            var vyabs:Number;

            while(--i > -1) {
                s = sprites[i];
                s.x += s.vx;
                s.y += s.vy;

                //s.rotation += 10;

                if(s.x < 0) {
                    s.x = 0;
                    s.vx *= -1;
                }

                if(s.x > stage.stageWidth) {
                    s.x = stage.stageWidth;
                    s.vx *= -1;
                }

                if(s.y < 0) {
                    s.y = 0;
                    s.vy *= -1;
                }

                if(s.y > stage.stageHeight) {
                    s.y = stage.stageHeight;
                    s.vy *= -1;
                }

                vxabs = Math.abs(s.vx);
                vyabs = Math.abs(s.vy);

                if(s.vx > 0 && vxabs > vyabs) { // right
                    s.spriteSheet.playAnimation("right");
                } else if(s.vx < 0 && vxabs > vyabs) { // left
                    s.spriteSheet.playAnimation("left");
                } else if(s.vy > 0 && vyabs > vxabs) { // down
                    s.spriteSheet.playAnimation("down");
                } else if(s.vy < 0 && vyabs > vxabs) { // up
                    s.spriteSheet.playAnimation("up");
                }

                s.rotation += 5.0;
            }
        }
    }
}
