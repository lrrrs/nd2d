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
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.materials.Sprite2DMaterial;
    import de.nulldesign.nd2d.materials.Sprite2DScanlineMaterial;

    public class MaterialsTest extends Scene2D {

        [Embed(source="/assets/nd_logo.png")]
        private var spriteTexture:Class;

        [Embed(source="/assets/test_image.jpg")]
        private var imageTexture:Class;

        private var s:Sprite2D;
        private var s2:Sprite2D;
        private var scanlineMaterial:Sprite2DScanlineMaterial;
        private var scanlineMaterial2:Sprite2DScanlineMaterial;

        public function MaterialsTest() {
            s = new Sprite2D();
            scanlineMaterial = new Sprite2DScanlineMaterial(new imageTexture().bitmapData);
            s.setMaterial(scanlineMaterial);
            addChild(s);

            s2 = new Sprite2D();
            scanlineMaterial2 = new Sprite2DScanlineMaterial(new spriteTexture().bitmapData);
            s2.setMaterial(scanlineMaterial2);
            addChild(s2);
        }

        override protected function step(elapsed:Number):void {
            super.step(elapsed);

            s.x = s2.x = camera.sceneWidth * 0.5;
            s.y = s2.y = camera.sceneHeight * 0.5;

            s2.x += Math.sin(timeSinceStartInSeconds) * 100.0;
            s2.y += Math.cos(timeSinceStartInSeconds) * 50.0;
            s2.rotation += 1;

            scanlineMaterial.seed = scanlineMaterial2.seed = Math.round(timeSinceStartInSeconds * 20.0);
        }
    }
}
