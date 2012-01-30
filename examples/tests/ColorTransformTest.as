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

	import com.bit101.components.HUISlider;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureAtlas;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class ColorTransformTest extends TextureAtlasTest {

        [Embed(source="/assets/nd_logo.png")]
        protected var spriteBitmap:Class;

        [Embed(source="/assets/circle_mask.png")]
        protected var maskBitmap:Class;

        private var spriteCloud:Sprite2DCloud;
        private var spriteBatch:Sprite2DBatch;
        private var spriteWithMask:Sprite2D;
        private var maskSprite:Sprite2D;

        private var panel:Sprite;

        private var sliders:Vector.<HUISlider> = new Vector.<HUISlider>();

        public function ColorTransformTest() {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            super();
        }

        override protected function init():void {

            backgroundColor = 0x666666;

            var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

            var sheet:SpriteSheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 24, 32, 10);
            sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
            sheet.playAnimation("blah", 0, true);

            var atlasTex:Texture2D = Texture2D.textureFromBitmapData(new textureAtlasBitmap().bitmapData);
            var atlas:TextureAtlas = new TextureAtlas(atlasTex.bitmapWidth, atlasTex.bitmapHeight, new XML(new textureAtlasXML()), TextureAtlas.XML_FORMAT_COCOS2D, 10, false);

            atlas.addAnimation("blah", ["c01", "c02", "c03", "c04", "c05", "c06", "c07", "c08", "c09", "c10", "c11", "c12", "b01", "b02", "b03", "b04", "b05", "b06", "b07", "b08", "b09", "b10", "b11", "b12"], true);

            atlas.playAnimation("blah");

            s = addChild(new Sprite2D(tex)) as Sprite2D;
            s.setSpriteSheet(sheet);
            s.x = 200.0;
            s.y = 200.0;
            s.scaleX = s.scaleY = 1.0;
            s.blendMode = BlendModePresets.BLEND;

            spriteCloud = addChild(new Sprite2DCloud(1, tex)) as Sprite2DCloud;
            spriteCloud.setSpriteSheet(sheet);
            spriteCloud.x = 220.0;
            spriteCloud.y = 200.0;
            spriteCloud.addChild(new Sprite2D());
            spriteCloud.scaleX = spriteCloud.scaleY = 1.0;
            spriteCloud.blendMode = BlendModePresets.BLEND;
            Sprite2D(spriteCloud.getChildAt(0)).spriteSheet.playAnimation("blah");

            spriteBatch = addChild(new Sprite2DBatch(atlasTex)) as Sprite2DBatch;
            spriteBatch.setSpriteSheet(atlas);
            spriteBatch.x = 240.0;
            spriteBatch.y = 200.0;
            spriteBatch.scaleX = spriteBatch.scaleY = 1.0;
            spriteBatch.addChild(new Sprite2D());
            spriteBatch.blendMode = BlendModePresets.BLEND;
            Sprite2D(spriteBatch.getChildAt(0)).spriteSheet.playAnimation("blah");

            spriteWithMask = addChild(new Sprite2D(tex)) as Sprite2D;
            spriteWithMask.setSpriteSheet(sheet);
            spriteWithMask.x = 260.0;
            spriteWithMask.y = 200.0;
            spriteWithMask.blendMode = BlendModePresets.BLEND;
            spriteWithMask.scaleX = spriteWithMask.scaleY = 1.0;

            maskSprite = new Sprite2D(Texture2D.textureFromBitmapData(new maskBitmap().bitmapData));
            maskSprite.x = 280.0;
            maskSprite.y = 200.0;
            maskSprite.scaleY = 0.2;
            spriteWithMask.setMask(maskSprite);
        }

        override protected function step(elapsed:Number):void {
            maskSprite.y = 200.0 + Math.sin(timeSinceStartInSeconds * 2.0) * 20.0;
        }

        private function removedFromStage(e:Event):void {
            if(panel) {
                stage.removeChild(panel);
            }
        }

        protected function addedToStage(event:Event):void {

            var c:HUISlider;

            if(!panel) {
                panel = new Sprite();
                panel.y = 280.0;
                panel.graphics.beginFill(0x000000, 1.0);
                panel.graphics.drawRect(0.0, 0.0, 180.0, 160.0);
                panel.graphics.endFill();

				Style.LABEL_TEXT = 0xFFFFFF;

                c = new HUISlider(panel, 0, 0, "redMultiplier", changeHandler);
                c.minimum = 0.0;
                c.maximum = 1.0;
                c.value = 1.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 20, "greenMultiplier", changeHandler);
                c.minimum = 0.0;
                c.maximum = 1.0;
                c.value = 1.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 40, "blueMultiplier", changeHandler);
                c.minimum = 0.0;
                c.maximum = 1.0;
                c.value = 1.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 60, "alphaMultiplier", changeHandler);
                c.minimum = 0.0;
                c.maximum = 1.0;
                c.value = 1.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 80, "redOffset", changeHandler);
                c.minimum = 0.0;
                c.maximum = 255.0;
                c.value = 0.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 100, "greenOffset", changeHandler);
                c.minimum = 0.0;
                c.maximum = 255.0;
                c.value = 0.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 120, "blueOffset", changeHandler);
                c.minimum = 0.0;
                c.maximum = 255.0;
                c.value = 0.0;

                sliders.push(c);

                c = new HUISlider(panel, 0, 140, "alphaOffset", changeHandler);
                c.minimum = 0.0;
                c.maximum = 255.0;
                c.value = 0.0;

                sliders.push(c);
            }

            stage.addChild(panel);
        }

        private function changeHandler(e:Event):void {

            var c:ColorTransform = new ColorTransform();
            c.redMultiplier = sliders[0].value;
            c.greenMultiplier = sliders[1].value;
            c.blueMultiplier = sliders[2].value;
            c.alphaMultiplier = sliders[3].value;
            c.redOffset = sliders[4].value;
            c.greenOffset = sliders[5].value;
            c.blueOffset = sliders[6].value;
            c.alphaOffset = sliders[7].value;

            s.colorTransform = c;
            spriteCloud.colorTransform = c;
            spriteBatch.colorTransform = c;
            spriteWithMask.colorTransform = c;
        }
    }
}