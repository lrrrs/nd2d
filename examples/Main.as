package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3DRenderMode;

    //[SWF(width="1000", height="550", frameRate="60", backgroundColor="#000000")]

    public class Main extends Sprite {

        private var main3DView:Sprite;

        /**
         *  TODO's:

         INTERNAL NAMESPACES! INSTEAD OF PUBLIC drawNode, etc...

         ND2D:
         - REPLACE ortographic camera with perspective one! for rotationX/Y/Z
         + sprites
         + load spritesheets into sprites with rect for first tile
         - textureatlas?? for quads??
         + spriteimages with custom sizes, automatic 2^n texture set and bounding box
         + position, alpha, rotation, tint
         + pivot point for sprites
         + picking / click!! bounding box und pixelgenau (bmpdata check)
         + blendmodes
         - glow
         - blur
         + camera
         - scene management (octtree 2d)
         - box2dphysics?
         - lights: point, spotlight, directional
         - text rendering? bitmap fonts!
         + colorutil: mix colors, hex2rgb
         - PVTR support for textures
         + SpriteCloud performance + rotation
         - Particlesystem (smoke, fire, glow, etc)
         - Scenes, layers?!, hierachies
         - Audio Engine
         - Distortion grid (wave effect, ripple, etc.)
         - removechild from sprite2dclouds runtime? MAX CAPACITY of vertexbuffer? fixed size?! only resize buffer, if more children than initially added
         - backgroundcolor change
         - box2d integration
         - collision (box, tilemap?)
         - tilemaps based on files?
         - animations: flicker, blink, fade, etc.
         - fonts?
         - pause!!!
         - random number generators
         - sorting objects
         - scene management!!!
         - scene transitions???

         http://www.lidev.com.ar/?p=422
         */
        public function Main() {

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            //main3DView = new MassiveSpritesTest(Context3DRenderMode.AUTO);
            //main3DView = new MassiveSpriteCloudTest(Context3DRenderMode.AUTO);
            //main3DView = new SpriteHierarchyTest(Context3DRenderMode.AUTO);
            //main3DView = new SpriteTest(Context3DRenderMode.AUTO);
            //main3DView = new SpriteAnimTest(Context3DRenderMode.AUTO);
            main3DView = new StarFieldTest(Context3DRenderMode.AUTO);
            //main3DView = new ParticleSystemTest(Context3DRenderMode.AUTO, 60);

            addChild(main3DView);
        }
    }
}
