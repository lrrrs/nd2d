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

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class SpriteHierarchyTest2 extends Scene2D {

        [Embed(source="/assets/crate.jpg")]
        private var spriteTexture:Class;

        private var s:Node2D;
        private var sc:Sprite2DCloud;

        public function SpriteHierarchyTest2() {

            s = new Node2D();
            addChild(s);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

            sc = new Sprite2DCloud(3, tex);
            sc.y = 300.0;
            addChild(sc);

            var tmp:Sprite2D;

            tmp = new Sprite2D(tex);
            tmp.tint = 0xFF0000;
            tmp.position = new Vector3D(200, 100);
            tmp.alpha = 0.7;
            tmp.rotation = 0.0;
            s.addChild(tmp);

            tmp = new Sprite2D(tex);
            tmp.tint = 0x00FF00;
            tmp.position = new Vector3D(300, 100);
            tmp.rotation = 20.0;
            tmp.alpha = 0.7;
            s.addChild(tmp);

            tmp = new Sprite2D(tex);
            tmp.tint = 0x0000FF;
            tmp.position = new Vector3D(400, 100);
            tmp.rotation = 40.0;
            tmp.alpha = 0.7;
            s.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0xFF0000;
            tmp.position = new Vector3D(200, 100);
            tmp.rotation = 0.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0x00FF00;
            tmp.position = new Vector3D(300, 100);
            tmp.rotation = 20.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0x0000FF;
            tmp.position = new Vector3D(400, 100);
            tmp.rotation = 40.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        private function removedFromStage(event:Event):void {
            stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
        }

        private function addedToStage(event:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        }

        private function keyUp(event:KeyboardEvent):void {
            // cycle z-index
            if(event.keyCode == Keyboard.C) {
                //s.addChild(s.getChildAt(0));
                //sc.addChild(sc.getChildAt(0));

                s.addChildAt(s.getChildAt(s.numChildren - 1), 0);
                sc.addChildAt(sc.getChildAt(sc.numChildren - 1), 0);

                //s.getChildAt(0).visible = !s.getChildAt(0).visible;
                //sc.getChildAt(0).visible = !sc.getChildAt(0).visible;
            }
        }
    }
}