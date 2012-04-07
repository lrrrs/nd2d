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

package
{

	import avmplus.getQualifiedClassName;

	import com.bit101.components.PushButton;

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.World2D;

	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import net.hires.debug.Stats;

	import tests.BatchTest;
	import tests.BlurTest;
	import tests.CameraTest;
	import tests.ColorTransformTest;
	import tests.Font2DTest;
	import tests.Grid2DTest;
	import tests.MaskTest;
	import tests.MassiveSpriteCloudTest;
	import tests.MassiveSpritesTest;
	import tests.ParticleExplorer;
	import tests.ParticleSystemTest;
	import tests.PostProcessingTest;
	import tests.QuadMaterialTest;
	import tests.SideScrollerTest;
	import tests.SpeedTest;
	import tests.Sprite2DCloudParticles;
	import tests.SpriteAnimTest;
	import tests.SpriteHierarchyTest;
	import tests.SpriteHierarchyTest2;
	import tests.SpriteTest;
	import tests.StarFieldTest;
	import tests.SpriteCloudVisibilityTest;
	import tests.TextFieldTest;
	import tests.TextureAndRotationOptionsTest;
	import tests.TextureAtlasTest;
	import tests.TextureRendererTest;
	import tests.Transform3DTest;

	[SWF(width = "1000", height = "550", frameRate = "60", backgroundColor = "#000000")]
	public class Main extends World2D
	{

		private var scenes:Vector.<Class> = new Vector.<Class>();
		private var activeSceneIdx:uint = 0;
		public static var stats:Stats = new Stats();

		private var sceneText:TextField;

		public function Main()
		{

			super(Context3DRenderMode.AUTO, 60);
		}

		override protected function addedToStage(event:Event):void
		{
			super.addedToStage(event);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			enableErrorChecking = false;

			scenes.push(SideScrollerTest);
			scenes.push(MassiveSpritesTest);
			scenes.push(MassiveSpriteCloudTest);
			scenes.push(SpriteHierarchyTest);
			scenes.push(SpriteHierarchyTest2);
			scenes.push(Font2DTest);
			scenes.push(Grid2DTest);
			scenes.push(SpriteTest);
			scenes.push(SpriteAnimTest);
			scenes.push(StarFieldTest);
			scenes.push(ParticleSystemTest);
			scenes.push(CameraTest);
			scenes.push(ParticleExplorer);
			scenes.push(MaskTest);
			scenes.push(TextureAtlasTest);
			scenes.push(BatchTest);
			scenes.push(TextureRendererTest);
			scenes.push(PostProcessingTest);
			scenes.push(ColorTransformTest);
			scenes.push(Sprite2DCloudParticles);
			scenes.push(SpeedTest);
			scenes.push(TextureAndRotationOptionsTest);
			scenes.push(Transform3DTest);
			scenes.push(TextFieldTest);
			scenes.push(QuadMaterialTest);
			scenes.push(BlurTest);
			scenes.push(SpriteCloudVisibilityTest);

			var tf:TextFormat = new TextFormat("Arial", 11, 0xFFFFFF, true);

			sceneText = new TextField();
			sceneText.width = 500;
			sceneText.defaultTextFormat = tf;

			addChild(sceneText);

			addChild(stats);

			stage.addEventListener(Event.RESIZE, stageResize);
			stageResize(null);

			activeSceneIdx = scenes.length - 1;
			nextDemo();

			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

			start();
		}

		private function keyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.D)
			{
				// simulate device loss
				context3D.dispose();
			}
			else if (e.keyCode == Keyboard.SPACE)
			{
				nextDemo();
			}
			else if (e.keyCode == Keyboard.F)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}

		public function nextDemo():void
		{
			if(scene) {
				scene.dispose();
			}

			camera.reset();

			sceneText.text = "(" + (activeSceneIdx + 1) + "/" + scenes.length + ") " + getQualifiedClassName(scenes[activeSceneIdx]) + " // hit space for next test. f for fullscreen";

			var sceneClass:Class = scenes[activeSceneIdx++] as Class;
			var currentScene:Scene2D = new sceneClass();

			setActiveScene(currentScene);

			if (activeSceneIdx > scenes.length - 1)
			{
				activeSceneIdx = 0;
			}
		}

		private function stageResize(e:Event):void
		{
			sceneText.x = 5;
			sceneText.y = stage.stageHeight - 20;
		}

		override protected function mainLoop(e:Event):void
		{
			super.mainLoop(e);
			stats.update(statsObject.totalDrawCalls, statsObject.totalTris);
		}

		override protected function context3DCreated(e:Event):void
		{

			super.context3DCreated(e);

			if (context3D)
			{
				stats.driverInfo = context3D.driverInfo;
			}
		}
	}
}
