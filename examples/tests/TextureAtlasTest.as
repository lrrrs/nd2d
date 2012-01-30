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

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureAtlas;

	public class TextureAtlasTest extends Scene2D {

        [Embed(source="/assets/textureatlas_cocos2d_allformats.png")]
        protected var textureAtlasBitmap:Class;

        [Embed(source="/assets/textureatlas_cocos2d.plist", mimeType="application/octet-stream")]
        protected var textureAtlasXML:Class;

        [Embed(source="/assets/textureatlas_zwoptex_default.png")]
        protected var textureAtlasBitmapZwoptex:Class;

        [Embed(source="/assets/textureatlas_zwoptex_default.plist", mimeType="application/octet-stream")]
        protected var textureAtlasXMLZwoptex:Class;

        protected var s:Sprite2D;

        [Embed(source="/assets/spritechar1.png")]
        protected var spriteTexture:Class;

        protected var s2:Sprite2DBatch;

        public function TextureAtlasTest() {
            init();
        }

        protected function init():void {
            backgroundColor = 0xDDDDDD;

            var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

            var sheet:SpriteSheet = new SpriteSheet(tex.bitmapWidth, tex.bitmapHeight, 24, 32, 5);
            sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
            sheet.playAnimation("blah", 0, true);
			/*
            var atlasTex:Texture2D = Texture2D.textureFromBitmapData(new textureAtlasBitmap().bitmapData);
			var atlas:TextureAtlas = new TextureAtlas(atlasTex.bitmapWidth, atlasTex.bitmapHeight, new XML(new textureAtlasXML()), TextureAtlas.XML_FORMAT_COCOS2D, 5, false);
            */
			var atlasTex:Texture2D = Texture2D.textureFromBitmapData(new textureAtlasBitmapZwoptex().bitmapData);
			var atlas:TextureAtlas = new TextureAtlas(atlasTex.bitmapWidth, atlasTex.bitmapHeight, new XML(new textureAtlasXMLZwoptex()), TextureAtlas.XML_FORMAT_ZWOPTEX, 5, false);

			s = addChild(new Sprite2D(atlasTex)) as Sprite2D;
            s.setSpriteSheet(atlas);

            atlas.addAnimation("blah", ["c01", "c02", "c03", "c04", "c05", "c06", "c07", "c08", "c09", "c10", "c11", "c12", "b01", "b02", "b03", "b04", "b05", "b06", "b07", "b08", "b09", "b10", "b11", "b12"], true);

            atlas.playAnimation("blah");

            //s2 = new Sprite2DBatch(tex);
            //s2 = new Sprite2DBatch(sheet);
            s2 = new Sprite2DBatch(atlasTex);
            s2.setSpriteSheet(atlas);

            //s2 = new Sprite2DCloud(100, tex);
            //s2 = new Sprite2DCloud(100, sheet);
            //s2 = new Sprite2DCloud(100, atlas);

            addChild(s2);

            for(var i:int = 0; i < 100; i++) {
                var batchChild:Sprite2D = new Sprite2D();
                batchChild.x = (i % 10) * 50.0;
                batchChild.y = Math.floor(i / 10) * 50.0;
                //batchChild.pivot.x = 10.0;
                //batchChild.pivot.y = 10.0;

                s2.addChild(batchChild);
                batchChild.spriteSheet.playAnimation("blah", i, true);
            }

            s.x = 200.0;
            s.y = 20.0;

            s2.x = 300.0;
            s2.y = 20.0;
        }

        override protected function step(elapsed:Number):void {
            super.step(elapsed);

            for(var i:int = 0; i < s2.children.length; i++) {
                s2.children[i].rotation += 0.1 + i * 0.1;
            }
        }
    }
}
