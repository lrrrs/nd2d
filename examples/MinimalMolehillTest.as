package {

	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.system.System;
	import flash.text.TextField;

	public class MinimalMolehillTest extends Sprite {

        private var context3D:Context3D;
        private var vertexBuffer:VertexBuffer3D;
        private var indexBuffer:IndexBuffer3D;
        private var program:Program3D;
        private var clipSpaceMatrix:Matrix3D;
        private var debugText:TextField;

        private var vector:Vector.<Vector3D>;

        public function MinimalMolehillTest() {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        private function addedToStage(event:Event):void {

            debugText = new TextField();
            debugText.textColor = 0xFFFFFF;
            addChild(debugText);

            vector = new Vector.<Vector3D>();

            // TEST
            for(var i:int = 0; i < 512; i++) {
                vector.push(new Vector3D(10.0, 20.0, 30.0, 1.0));
            }

            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

            stage.frameRate = 60;
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3DCreated);
            stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, context3DError);
            stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
        }

        private function context3DError(e:ErrorEvent):void {
            throw new Error("ERROR creating 3D context");
        }

        private function context3DCreated(e:Event):void {

            stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, context3DCreated);
            stage.stage3Ds[0].removeEventListener(ErrorEvent.ERROR, context3DError);

            context3D = stage.stage3Ds[0].context3D;
            context3D.enableErrorChecking = true;
            context3D.setCulling(Context3DTriangleFace.NONE);
            context3D.setDepthTest(true, Context3DCompareMode.LESS);
            stage.stage3Ds[0].x = 0.0;
            stage.stage3Ds[0].y = 0.0;

            context3D.configureBackBuffer(800, 600, 2, false);

            clipSpaceMatrix = makeOrthoProjection(800, 600, 0, 100);

            program = context3D.createProgram();

            var vertexShader:Array = [
                "m44 op, va0, vc0",
                "mov v0, va1"
            ];
            var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));

            var fragmentShader:Array = [
                "mov oc, v0"
            ];
            var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));

            program.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);

            vertexBuffer = context3D.createVertexBuffer(3, 6);

            vertexBuffer.uploadFromVector(Vector.<Number>([
                                                              -100.0, 100.0,      1.0, 0.0, 0.0, 1.0,
                                                              -100.0,-100.0,      0.0, 1.0, 0.0, 1.0,
                                                              100.0,-100.0,      0.0, 0.0, 1.0, 1.0
                                                          ]), 0, 3);

            indexBuffer = context3D.createIndexBuffer(3);
            indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2]), 0, 3);

            addEventListener(Event.ENTER_FRAME, loop);
        }

        private function makeOrthoProjection(w:Number, h:Number, n:Number, f:Number):Matrix3D {
            return new Matrix3D(Vector.<Number>([
                                                    2 / w, 0  ,       0,        0,
                                                    0  , 2 / h,       0,        0,
                                                    0  , 0  , 1 / (f - n), -n / (f - n),
                                                    0  , 0  ,       0,        1
                                                ]));
        }

        protected function loop(e:Event):void {

            context3D.clear(0.2, 0.2, 0.2, 1.0);

            context3D.setProgram(program);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);
            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
            context3D.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_4); //color

            context3D.drawTriangles(indexBuffer, 0, 1);

            context3D.present();

            var blah:Number;

            for(var i:int = 0; i < vector.length; i++) {
                // LEAK TEST!
                blah = vector[i].x * vector[i].length;
                // OK
                //blah = (vector[i] as Vector3D).x * (vector[i] as Vector3D).length;
            }

            debugText.text = String(System.totalMemory);
        }

    }
}
