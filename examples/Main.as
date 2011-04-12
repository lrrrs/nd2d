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

package {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.World2D;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DRenderMode;

    import tests.Grid2DTest;
    import tests.MassiveSpriteCloudTest;
    import tests.MassiveSpritesTest;
    import tests.ParticleExplorer;
    import tests.ParticleSystemTest;
    import tests.SpriteAnimTest;
    import tests.SpriteHierarchyTest;
    import tests.SpriteTest;
    import tests.StarFieldTest;

    //[SWF(width="1000", height="550", frameRate="60", backgroundColor="#000000")]

    public class Main extends World2D {

        private var mainScene:Scene2D;

        public function Main() {

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            super(Context3DRenderMode.AUTO, 60);

            //mainScene = new MassiveSpritesTest();
            //mainScene = new MassiveSpriteCloudTest();
            //mainScene = new SpriteHierarchyTest();
            //mainScene = new Grid2DTest();
            mainScene = new SpriteTest();
            //mainScene = new SpriteAnimTest();
            //mainScene = new StarFieldTest();
            //mainScene = new ParticleSystemTest();
            //statsVisible = false;
            //mainScene = new ParticleExplorer();

            setActiveScene(mainScene);
        }
    }
}
