package tests {

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.events.Event;

	public class SpriteCloudVisibilityTest extends Scene2D {

		private static const MAX_TRACK_POINTS:uint = 10;

		[Embed(source="/assets/particle_small.png")]
		private var particleClass:Class;

		[Embed(source="/assets/starfield.jpg")]
		private var starFieldTexture:Class;

		private var starfield1:Sprite2D;

		private var trackCloud:Sprite2DCloud;
		private var trackPoints:Vector.<Sprite2D>;
		private var texSize:int;

		public function SpriteCloudVisibilityTest() {
			trackPoints = new Vector.<Sprite2D>();

			var tex:Texture2D = Texture2D.textureFromBitmapData(new particleClass().bitmapData);
			texSize = tex.bitmapWidth;
			trackCloud = new Sprite2DCloud(MAX_TRACK_POINTS, tex);

			for(var i:int = 0; i < MAX_TRACK_POINTS; i++) {
				var s:Sprite2D = new Sprite2D();
				s.scaleX = s.scaleY = 0.7;
				trackPoints.push(s);
				trackCloud.addChild(s);
			}

			starfield1 = new Sprite2D(Texture2D.textureFromBitmapData(new starFieldTexture().bitmapData));
			starfield1.alpha = 0.1;
			addChild(starfield1);

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void {
			starfield1.width = stage.stageWidth;
			starfield1.scaleY = starfield1.scaleX;
			starfield1.x = stage.stageWidth / 2;
			starfield1.y = stage.stageHeight / 2;

			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addChild(trackCloud);
		}

		override protected function step(elapsed:Number):void {
			var n:int = (mouseX / stage.stageWidth) * MAX_TRACK_POINTS;
			if(n > MAX_TRACK_POINTS)
				n = MAX_TRACK_POINTS;

			for(var i:int = 0; i < n; i++) {
				trackPoints[i].visible = true;
				trackPoints[i].x = mouseX + i * 2 * texSize;
				trackPoints[i].y = mouseY;
			}

			for(var j:int = n; j < MAX_TRACK_POINTS; j++) {
				trackPoints[j].visible = false;
			}
		}
	}
}