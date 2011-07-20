# ND2D - A Flash Molehill GPU accelerated 2D engine.

ND2D is a 2D sprite engine using the new GPU hardware features of flash currently available in a beta build. To run this engine you must download and install the latest flash player:

[Flash Player 11 Beta](http://labs.adobe.com/downloads/flashplayer11.html) | [playerglobal.swc](http://download.macromedia.com/pub/labs/flashplatformruntimes/flashplayer11/flashplayer11_b1_playerglobal_071311.swc)

You have to compile ND2D with the FP11 beta playerglobal.swc to get it to work.

ND2D was built to make an ease use of hardware accelerated 2D content in the Flashplayer. The aim is to keep things simple and reintroduce familiar concepts. ND2D has a displaylist and quite the same methods to modify sprites as you are used to.

!!! It's still in early beta, so there will be bugs and things that do not work properly. Please file issues to the bugbase!!!

If you want to contribute, make bugfixes or extend the engine, feel free to fork it or email me: lars[at]nulldesign.de

Useful links:
[ND2D API Documentation](http://www.nulldesign.de/nd2d/docs/) | [Setting up FP11 for IntelliJ](http://www.lidev.com.ar/?p=422)

[![Launch Examples](http://nulldesign.de/nd2d/nd2d_examples.jpg)](http://nulldesign.de/nd2d/tests/)

(Click the image to see some demos. Be patient, no preloader!)

# Features:

- Flash-displaylist-like hierarchy for 2D elements
- 2D sprites with spritesheets for animation, tinting, blendmodes, pivot points
- Scenes
- 2D camera
- SpriteClouds for massive sprite rendering (batch drawing)
- Powerful particlesystem that runs entirely on the GPU
- Full mouseevent support for 2D sprites
- Utils (Color mixing, random number generation, …)
- Fast bitmap fonts
- Distortable 2D grid for wave / ripple effects
- Texturerenderer for displaylist elements

# Changelog:

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