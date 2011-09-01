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

    import de.nulldesign.nd2d.display.ParticleSystem2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.Sprite2DCloud;
    import de.nulldesign.nd2d.materials.BlendModePresets;
    import de.nulldesign.nd2d.materials.SpriteSheet;
    import de.nulldesign.nd2d.utils.NumberUtil;
    import de.nulldesign.nd2d.utils.ParticleSystemPreset;

    import flash.display.BitmapData;
    import flash.events.Event;

    import tests.objects.MorphGrid;

    public class SideScrollerTest extends Scene2D {

        [Embed(source="/assets/particle_small.png")]
        private var particleTexture:Class;

        [Embed(source="/assets/star_particle.png")]
        private var particleTexture2:Class;

        [Embed(source="/assets/world_background.png")]
        private var backgroundTexture:Class;

        [Embed(source="/assets/world_background2.png")]
        private var backgroundTexture2:Class;

        [Embed(source="/assets/ceiling_texture.png")]
        private var ceilingTexture:Class;

        [Embed(source="/assets/grass_ground.png")]
        private var grassTexture:Class;

        [Embed(source="/assets/blur_tree.png")]
        private var treeTexture:Class;

        [Embed(source="/assets/plantsheet.png")]
        private var plantTexture:Class;

        private var grassSprites:Vector.<Sprite2D> = new Vector.<Sprite2D>();
        private var ceilingSprites:Vector.<Sprite2D> = new Vector.<Sprite2D>();
        private var backgroundSprites:Vector.<Sprite2D> = new Vector.<Sprite2D>();
        private var backgroundSprites2:Vector.<Sprite2D> = new Vector.<Sprite2D>();
        private var treeSprites:Vector.<Sprite2D> = new Vector.<Sprite2D>();

        private var plasma:ParticleSystem2D;
        private var wind:ParticleSystem2D;

        private var scrollX:Number = 0.0;

        public function SideScrollerTest() {

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        private function addedToStage(e:Event):void {

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            var backgroundTex:BitmapData = new backgroundTexture().bitmapData;
            var cloud:Sprite2DCloud = new Sprite2DCloud(3, backgroundTex);
            addChild(cloud);

            backgroundSprites.push(cloud.addChild(new Sprite2D()));
            backgroundSprites.push(cloud.addChild(new Sprite2D()));
            backgroundSprites.push(cloud.addChild(new Sprite2D()));

            var i:int;

            for(i = 0; i < backgroundSprites.length; i++) {
                backgroundSprites[i].x = i * backgroundSprites[i].width + backgroundSprites[i].width * 0.5;
            }

            var backgroundTex2:BitmapData = new backgroundTexture2().bitmapData;
            //cloud = new Sprite2DCloud(3, backgroundTex2);
            //addChild(cloud);

            backgroundSprites2.push(addChild(new MorphGrid(16, 8, backgroundTex2, 0.04)));
            backgroundSprites2.push(addChild(new MorphGrid(16, 8, backgroundTex2, 0.04)));
            backgroundSprites2.push(addChild(new MorphGrid(16, 8, backgroundTex2, 0.04)));

            for(i = 0; i < backgroundSprites2.length; i++) {
                backgroundSprites2[i].blendMode = BlendModePresets.ADD;
                backgroundSprites2[i].x = i * backgroundSprites2[i].width + backgroundSprites2[i].width * 0.5;
            }

            // wind
            var plasmaPreset:ParticleSystemPreset = new ParticleSystemPreset();
            plasmaPreset.minStartSize = 0.5;
            plasmaPreset.maxStartSize = 1.0;
            plasmaPreset.minEndSize = 0.01;
            plasmaPreset.maxEndSize = 0.01;

            plasmaPreset.startColor = plasmaPreset.startColorVariance = 0xFFFFFF;
            plasmaPreset.endColor = plasmaPreset.endColorVariance = 0xFFFFFF;
            plasmaPreset.startAlpha = 0.0;
            plasmaPreset.endAlpha = 0.6;
            plasmaPreset.minStartPosition.x = -stage.stageWidth * 0.5;
            plasmaPreset.maxStartPosition.x = stage.stageWidth * 0.5;
            plasmaPreset.minStartPosition.y = -stage.stageHeight * 0.5;
            plasmaPreset.maxStartPosition.y = stage.stageHeight * 0.5;
            plasmaPreset.spawnDelay = 0.0;

            wind = new ParticleSystem2D(new particleTexture2().bitmapData, 400, plasmaPreset);
            wind.blendMode = BlendModePresets.ADD;
            addChild(wind);

            // trees
            var treeTex:BitmapData = new treeTexture().bitmapData;
            treeSprites.push(addChild(new Sprite2D(treeTex)));
            treeSprites.push(addChild(new Sprite2D(treeTex)));
            treeSprites.push(addChild(new Sprite2D(treeTex)));

            for(i = 0; i < treeSprites.length; i++) {
                treeSprites[i].x = NumberUtil.rndMinMax(0, 1024);
                treeSprites[i].scaleX = treeSprites[i].scaleY = NumberUtil.rndMinMax(0.3, 1.5);
                treeSprites[i].scaleX *= Math.random() > 0.5 ? 1 : -1;
            }

            // grass
            var grassTex:BitmapData = new grassTexture().bitmapData;
            grassSprites.push(addChild(new Sprite2D(grassTex)));
            grassSprites.push(addChild(new Sprite2D(grassTex)));
            grassSprites.push(addChild(new Sprite2D(grassTex)));

            for(i = 0; i < grassSprites.length; i++) {
                grassSprites[i].x = i * grassSprites[i].width + grassSprites[i].width * 0.5;
            }

            // plants
            var plantTex:BitmapData = new plantTexture().bitmapData;

            // TODO add reverse loop option to spritesheet
            var sheet:SpriteSheet = new SpriteSheet(plantTex, 200, 147, 20);
            var ar:Array = [];
            for(i = 2; i < 35; ++i) {
                ar.push(i);
            }

            for(i = 34; i >= 2; --i) {
                ar.push(i);
            }

            sheet.addAnimation("wave", ar, true);

            cloud = new Sprite2DCloud(100, sheet);

            grassSprites[0].addChild(cloud);

            var plant:Sprite2D = new Sprite2D();
            plant.scaleX = plant.scaleY = 3.0;
            plant.y = -220;

            cloud.addChild(plant);

            plant = new Sprite2D();
            plant.scaleX = plant.scaleY = 4.0;
            plant.x = 100;
            plant.y = -220;

            cloud.addChild(plant);

            plant.spriteSheet.playAnimation("wave", 30, true);

            plant = new Sprite2D();
            plant.scaleX = -2.0;
            plant.scaleY = 2.0;
            plant.x = 450;
            plant.y = -150;

            cloud.addChild(plant);

            plant.spriteSheet.playAnimation("wave", 15, true);

            plant = new Sprite2D();
            plant.scaleX = 1.0;
            plant.scaleY = 1.0;
            plant.x = 620;
            plant.y = -120;

            cloud.addChild(plant);

            plant.spriteSheet.playAnimation("wave", 10, true);

            // ceiling
            var ceilingTex:BitmapData = new ceilingTexture().bitmapData;
            cloud = new Sprite2DCloud(3, ceilingTex);
            addChild(cloud);

            ceilingSprites.push(cloud.addChild(new Sprite2D()));
            ceilingSprites.push(cloud.addChild(new Sprite2D()));
            ceilingSprites.push(cloud.addChild(new Sprite2D()));

            for(i = 0; i < ceilingSprites.length; i++) {
                ceilingSprites[i].x = i * ceilingSprites[i].width + ceilingSprites[i].width * 0.5;
            }

            plasmaPreset = new ParticleSystemPreset();
            plasmaPreset.minStartSize = 1.0;
            plasmaPreset.maxStartSize = 2.0;
            plasmaPreset.minEndSize = 0.3;
            plasmaPreset.maxEndSize = 0.1;

            plasmaPreset.startColor = plasmaPreset.startColorVariance = 0x633888;
            plasmaPreset.endColor = plasmaPreset.endColorVariance = 0x1bb099;
            plasmaPreset.minStartPosition.x = -25;
            plasmaPreset.maxStartPosition.x = 25;
            plasmaPreset.minEmitAngle = 170.0;
            plasmaPreset.maxEmitAngle = 190.0;
            plasmaPreset.spawnDelay = 2.0;

            plasma = new ParticleSystem2D(new particleTexture().bitmapData, 200, plasmaPreset);
            plasma.x = 225;
            plasma.y = -55;
            plasma.blendMode = BlendModePresets.ADD;

            grassSprites[0].addChild(plasma);
        }

        override protected function step(elapsed:Number):void {

            var i:int;

            scrollX = -(mouseX - camera.sceneWidth * 0.5) * 0.05;

            for(i = 0; i < backgroundSprites.length; i++) {
                backgroundSprites[i].x += scrollX * 0.25;
                backgroundSprites[i].height = camera.sceneHeight;
                backgroundSprites[i].y = camera.sceneHeight * 0.5;
            }

            manageInfiniteScroll(backgroundSprites);

            for(i = 0; i < backgroundSprites2.length; i++) {
                backgroundSprites2[i].x += scrollX * 0.5;
                backgroundSprites2[i].height = camera.sceneHeight;
                backgroundSprites2[i].y = camera.sceneHeight * 0.5;
            }

            manageInfiniteScroll(backgroundSprites2);

            for(i = 0; i < grassSprites.length; i++) {
                grassSprites[i].x += scrollX;
                grassSprites[i].y = camera.sceneHeight - grassSprites[i].height * 0.5;
            }

            manageInfiniteScroll(grassSprites);

            for(i = 0; i < ceilingSprites.length; i++) {
                ceilingSprites[i].x += scrollX;
                ceilingSprites[i].y = ceilingSprites[i].height * 0.5;
            }

            manageInfiniteScroll(ceilingSprites);

            // scroll trees
            for(i = 0; i < treeSprites.length; i++) {
                treeSprites[i].x += scrollX * 0.75;
                treeSprites[i].y = camera.sceneHeight - 120 - treeSprites[i].height * 0.5;

                // left out
                if(treeSprites[i].x < -treeSprites[i].width * 0.5 && scrollX < 0) {

                    treeSprites[i].x = camera.sceneWidth + NumberUtil.rndMinMax(300, 800);

                } else if(treeSprites[i].x - treeSprites[i].width * 0.5 > camera.sceneWidth && scrollX > 0) {

                    treeSprites[i].x = NumberUtil.rndMinMax(-300, -800);
                }
            }

            if(wind) {
                wind.x = camera.sceneWidth * 0.5;
                wind.y = camera.sceneHeight * 0.5;
                wind.gravity.x = 200.0 * scrollX;
            }
        }

        private function manageInfiniteScroll(ar:Vector.<Sprite2D>):void {

            var tmp:Sprite2D;
            var tmp2:Sprite2D;

            // left out
            if(ar[0].x < -ar[0].width * 0.5) {
                tmp = ar[0];
                tmp2 = ar[2];

                tmp.x = tmp2.x + tmp2.width;

                ar[0] = ar[1];
                ar[1] = tmp2;
                ar[2] = tmp;

            } else if(ar[2].x - ar[2].width * 0.5 > camera.sceneWidth) {

                tmp = ar[0];
                tmp2 = ar[2];

                tmp2.x = tmp.x - tmp.width;

                ar[0] = ar[2];
                ar[2] = ar[1];
                ar[1] = tmp;
            }
        }
    }
}
