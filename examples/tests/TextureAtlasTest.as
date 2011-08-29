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
package tests {

    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.materials.TextureAtlas;

    public class TextureAtlasTest extends Scene2D {

        [Embed(source="/assets/textureatlas_test.png")]
        private var textureAtlasBitmap:Class;

        [Embed(source="/assets/textureatlas_test.plist", mimeType="application/octet-stream")]
        private var textureAtlasXML:Class;

        private var s:Sprite2D;

        [Embed(source="/assets/spritechar1.png")]
        private var spriteTexture:Class;

        private var s2:Sprite2D;

        public function TextureAtlasTest() {

            backGroundColor = 0xDDDDDD;

            var atlas:TextureAtlas = new TextureAtlas(new textureAtlasBitmap().bitmapData,
                                                      new XML(new textureAtlasXML()), 5);
            s = addChild(new Sprite2D(atlas)) as Sprite2D;

            atlas.addAnimation("blah", ["c01", "c02", "c03", "c04", "c05", "c06", "c07", "c08", "c09", "c10", "c11", "c12",
                                        "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"], true);

            //atlas.addAnimation("blah", ["c01", "c02", "c03", "c04", "c05", "c06", "c07", "c08", "c09", "c10", "c11", "c12"], true);
            atlas.playAnimation("blah");

            var sheet:SpriteSheet = new SpriteSheet(new spriteTexture().bitmapData, 24, 32, 5);
            sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true);
            sheet.playAnimation("blah", 0, true);

            s2 = new Sprite2D();
            s2.setSpriteSheet(sheet);
            addChild(s2);
        }

        override protected function step(elapsed:Number):void {
            super.step(elapsed);

            s.x = stage.stageWidth * 0.5;
            s.y = stage.stageHeight * 0.5;

            s2.x = stage.stageWidth * 0.5 + 30.0;
            s2.y = stage.stageHeight * 0.5;
        }
    }
}
