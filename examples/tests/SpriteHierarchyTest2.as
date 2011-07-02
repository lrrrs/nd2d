package tests {

    import de.nulldesign.nd2d.display.Node2D;
    import de.nulldesign.nd2d.display.Scene2D;
    import de.nulldesign.nd2d.display.Sprite2D;
    import de.nulldesign.nd2d.display.Sprite2DCloud;

    import flash.display.Sprite;

    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;

    public class SpriteHierarchyTest2 extends Scene2D {

        [Embed(source="/assets/crate.jpg")]
        private var spriteTexture:Class;

        private var s:Node2D;
        private var sc:Sprite2DCloud;

        public function SpriteHierarchyTest2() {

            s = new Node2D();
            addChild(s);

            sc = new Sprite2DCloud(3, new spriteTexture().bitmapData);
            sc.y = 300.0;
            addChild(sc);

            var tmp:Sprite2D;

            tmp = new Sprite2D(new spriteTexture().bitmapData);
            tmp.tint = 0xFF0000;
            tmp.position = new Point(200, 100);
            tmp.alpha = 0.7;
            tmp.rotation = 0.0;
            s.addChild(tmp);

            tmp = new Sprite2D(new spriteTexture().bitmapData);
            tmp.tint = 0x00FF00;
            tmp.position = new Point(300, 100);
            tmp.rotation = 20.0;
            tmp.alpha = 0.7;
            s.addChild(tmp);

            tmp = new Sprite2D(new spriteTexture().bitmapData);
            tmp.tint = 0x0000FF;
            tmp.position = new Point(400, 100);
            tmp.rotation = 40.0;
            tmp.alpha = 0.7;
            s.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0xFF0000;
            tmp.position = new Point(200, 100);
            tmp.rotation = 0.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0x00FF00;
            tmp.position = new Point(300, 100);
            tmp.rotation = 20.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            tmp = new Sprite2D();
            tmp.tint = 0x0000FF;
            tmp.position = new Point(400, 100);
            tmp.rotation = 40.0;
            tmp.alpha = 0.7;
            sc.addChild(tmp);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
        }

        private function removedFromStage(event:Event):void {
            stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
        }

        private function addedToStage(event:Event):void {
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        }

        private function keyUp(event:KeyboardEvent):void {
            // cycle z-index
            if(event.keyCode == Keyboard.C) {
                s.addChild(s.getChildAt(0));
                sc.addChild(sc.getChildAt(0));

                //s.addChildAt(s.getChildAt(s.numChildren - 1), 0);
                //sc.addChildAt(sc.getChildAt(sc.numChildren - 1), 0);
            }
        }
    }
}