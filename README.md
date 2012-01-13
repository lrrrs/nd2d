# ND2D - A Flash Molehill (Stage3D) GPU accelerated 2D engine.

ND2D is a 2D framework using the new GPU hardware features of flash. To run this engine you must download and install the latest flash player:

[Flash Player 11 & playerglobal.swc](http://get.adobe.com/de/flashplayer/)

You have to compile ND2D with the FP11 playerglobal.swc and the compiler option -swf-version=13 to get it to work.

ND2D was built to make an ease use of hardware accelerated 2D content in the Flashplayer. The aim is to keep things simple and reintroduce familiar concepts. ND2D has a displaylist and quite the same methods to modify sprites as you are used to, but a few things are different. There are optimizations in ND2D, that enable you to display thousands of sprites at a high framerate. Have a look at the examples for the Sprite2DCloud or Sprite2DBatch and in the Wiki.

If you want to contribute, make bugfixes or extend the engine, feel free to fork it or email me: lars[at]nulldesign.de

Important links:

[ND2D Forum](http://www.nulldesign.de/nd2d/forum/) Yes, we have one now!

[ND2D API Documentation](http://www.nulldesign.de/nd2d/docs/)

[Setting up FP11 for IntelliJ](http://www.lidev.com.ar/?p=422)

[![Launch Examples](http://nulldesign.de/nd2d/nd2d_examples.jpg)](http://nulldesign.de/nd2d/tests/)

(Click the image to see some demos. Be patient, no preloader!)

[Detailed technical information, Tips, Tricks and deep dives into ND2D](http://www.nulldesign.de/category/experiments/nd2d/)

# Features:

- Flash-displaylist-like hierarchy for 2D elements
- 2D sprites with tinting, blendmodes, pivot points
- Support for spritesheets and texture atlases
- Scenes
- 2D camera
- SpriteCloud / Batch for massive sprite rendering
- Powerful particlesystem that runs entirely on the GPU
- Full mouseevent support for 2D sprites
- Utils (Color mixing, random number generation, …)
- Fast bitmap fonts
- Distortable 2D grid for wave / ripple effects
- Texturerenderer for post process effects
- Extendable material system that makes it easy to write own effects and shaders with PixelBender3D or AGAL
- Device loss is handled by the framework automatically, you don't have to care about this.

[Check out the WIKI for more details](https://github.com/nulldesign/nd2d/wiki)

# Changelog:

2012-01-13

- FIXED: GUI layer rendering
- ADDED: animation end event
- ADDED: pixel perfect collisions for Sprite2D (see example SpriteHierarchyTest)

2011-12-07

- ADDED: getChildByTag and tag property for Node2D
- ADDED: Sprite2DBlurMaterial - GPU powered blurX / blurY

2011-12-02

- FIXED: BitmapFont2D non 2^n texture sizes
- REFACTORED: TextureRenderer, no event needed anymore
- ADDED: GUI layer in Scene2D, see example: CameraTest

2011-11-28

- FIXED: texture distribution for Sprite2D in a batch
- FIXED: Premultiplied alpha bug in ParticlySystem2D
- RENAMED: blendmode ADD -> ADD_PREMULTIPLIED_ALPHA

2011-11-23

- ADDED: Support for TouchEvents
- ADDED: Support for ATF Textures
- ADDED: Support for non premultiplied alpha textures
- FIXED: hitTest for Scene2D
- FIXED: spriteSheet distribution for Sprite2DBatch

2011-11-15

- MERGED: optimizations from komelgman (Thanks!)
- ADDED: possibility to add a custom hitTest for nodes
- ADDED: new displayobject: Quad2D - A quad with four colors
- ADDED: TextField2D - use native Flash TextFields in ND2D (thanks Ryan!)
- ADDED: Burst mode for ParticleSystem2D
- FIXED: spritesheet distribution in Sprite2DBatch
- FIXED: TextureAtlas offset calculation from sourceColorRect to support dynamic generation
- RENAMED: Font2D to BitmapFont2D

2011-11-14

- FIXED: device loss is working again :)

2011-11-06

- ADDED: uvMultiplier for Sprite2DMaterial. You can scale your textures now. See TextureAndRotationOptionsTest
- ADDED: Texture filtering options: LOW, MED, HIGH, ULTRA and texture repeat options: CLAMP, REPEAT. See TextureAndRotationOptionsTest
- ADDED: rotationX,Y,Z for nodes. You can rotate your objects in 2.5D now, just like the Flash 10 2.5D API. See Transform3DTest
- CHANGED: constructor arguments of Sprite2D, Cloud and Batch take only a Texture2D now.
- FIXED: mask size is not restriced to 2^ anymore
- tint is a uint now.
- cleaned up a lot of stuff

2011-10-24

- FIXED: Sprite2D width / height bug, when a TextureAtlas was set
- ADDED: setChildIndex(), thanks Björn!


2011-10-20

- FIXED: nested nodes movement bug
- FIXED: mouse handling for nodes
- FIXED: camera movement
- FIXED: Vector allocations. PERFORMANCE BOOST in all materials (Thanks Shawn!)

2011-10-19

- CHANGE: mouseEvents, behave like you're used to in flash now. Only the topmost node will dispatch the event.
- TODO: Pixel precise mouseevents are on the way, stay tuned

2011-10-17

- NEW: globalToLocal / localToGlobal methods in Node2D
- set some properties to internal
- getIndexForFrame added for TextureAtlas

2011-10-08

- API Changes:
    All nodes (Sprite2D, Sprite2DCloud, etc.) take only a BitmapData or a Texture2D as constructor argument now.
    You have to set the material or spritesheet via setMaterial or setSpriteSheet now.
    Constructor of TextureAtlas and SpriteSheet slightly different.
- Bugfix in Sprite2DBatch

2011-10-06

- FIXED: Node2D.alpha property was ignored
- REMOVED: timer based loop option in World2D. You should never use that, it's just not the way to render.

2011-10-05

- ADDED: mipmapgeneration for all textures. Rotated and scaled nodes look a lot smoother now
- OPTIMIZED: fragment shaders (thanks kutu)

2011-10-04

- Fixed issues: #17, #14
- Uploaded v0.1.0 SWC

2011-09-26

- DELETED pb3dlib.swc. Dependency removed. ParticleSystem2DMaterial converted to AGAL
- NEW: UV offsets are now animateable. See updated example StarFieldTest

2011-09-21

- NEW: colorTransform property for all display objects. (See new example ColorTransformTest)

2011-09-08

- Sprite2DCloud pivot points fixed
- ADDED: Post process demo with TextureRenderer
- FIXED: Device loss handling for all objects

2011-08-30

- NEW: Sprite2DBatch - Batches drawCalls, Alternative to Sprite2DCloud, not yet finished

2011-08-29

- Arguments of Sprite2D / Sprite2DMaterial reduced to one (non typed)
- Refactored SpriteSheet classes
- NEW: Cocos2D-TexturePacker compatible TextureAtlas (not pixel precise and fully implemented yet!)
- Added example for TexturePacker

2011-07-20

- !!! API CHANGE IN World2D: You have to call start() now to get the engine running, otherwise your screen will be black.
- Blendmodes have been renamed and fixed for premultiplied alpha bitmaps: NORMAL -> NORMAL_PREMULTIPLIED_ALPHA.

2011-07-14

- updated engine for new public FP11 beta player. stage3Ds[i].x/y used instead of old rectangle

2011-07-05

- Fixed runtime cloud child visibility 

2011-07-02

- altered addChild method: existing childs are removed first, before added again

2011-06-22

- added some ; to satisfy FDT4 ;) 