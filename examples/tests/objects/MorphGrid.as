/*
 *
 *  ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 *  Author: Lars Gerckens
 *  Copyright (c) nulldesign 2011
 *  Repository URL: http://github.com/nulldesign/nd2d
 *
 *
 *  Licence Agreement
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 * /
 */

package tests.objects {
    import de.nulldesign.nd2d.display.Grid2D;

    import flash.display.BitmapData;

    public class MorphGrid extends Grid2D {
        public function MorphGrid(stepsX:uint, stepsY:uint, bitmapTexture:BitmapData = null) {
            super(stepsX, stepsY, bitmapTexture);
        }

        override protected function step(t:Number):void {
            super.step(t);

            for(var i:int = 0; i < vertexList.length; i++) {

                if(i > stepsX && i < vertexList.length - stepsX) {
                    var newX:Number = vertexList[i].x + vertexList[i].x * Math.sin(vertexList[i].length + t * 2.0) * 0.1;
                    var newY:Number = vertexList[i].y + vertexList[i].y * Math.cos(vertexList[i].length + t * 2.0) * 0.1;

                    material.modifyVertexInBuffer(vertexList[i].bufferIdx, newX, newY);
                }
            }
        }
    }
}
