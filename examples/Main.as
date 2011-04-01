package {
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.World2D;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DRenderMode;

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
