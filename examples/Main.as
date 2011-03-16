package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DRenderMode;

    import tests.MassiveSpriteCloudTest;
    import tests.MassiveSpritesTest;
    import tests.ParticleExplorerWorld;
    import tests.ParticleSystemTest;
    import tests.SpriteAnimTest;
    import tests.SpriteHierarchyTest;
    import tests.SpriteTest;
    import tests.StarFieldTest;

    //[SWF(width="1000", height="550", frameRate="60", backgroundColor="#000000")]

    public class Main extends Sprite {

        private var main3DView:Sprite;

        public function Main() {

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            //main3DView = new MassiveSpritesTest(Context3DRenderMode.AUTO);
            //main3DView = new MassiveSpriteCloudTest(Context3DRenderMode.AUTO);
            //main3DView = new SpriteHierarchyTest(Context3DRenderMode.AUTO);
            //main3DView = new SpriteTest(Context3DRenderMode.AUTO);
            main3DView = new SpriteAnimTest(Context3DRenderMode.AUTO);
            //main3DView = new StarFieldTest(Context3DRenderMode.AUTO);
            //main3DView = new ParticleSystemTest(Context3DRenderMode.AUTO, 60);
            //main3DView = new ParticleExplorerWorld();

            addChild(main3DView);
        }
    }
}
