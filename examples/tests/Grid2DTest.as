
package tests {
    import de.nulldesign.nd2d.display.Grid2D;
    import de.nulldesign.nd2d.display.Scene2D;

    import tests.objects.MorphGrid;

    public class Grid2DTest extends Scene2D {

        [Embed(source="/assets/water_texture.jpg")]
        private var spriteTexture:Class;

        private var grid:Grid2D;

        public function Grid2DTest() {

            grid = new MorphGrid(8, 8, new spriteTexture().bitmapData);
            addChild(grid);
        }

        override protected function step(t:Number):void {
            grid.x = stage.stageWidth * 0.5;
            grid.y = stage.stageHeight * 0.5;
        }
    }
}
