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

package tests.objects {

	import de.nulldesign.nd2d.display.Grid2D;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	public class MorphGrid extends Grid2D {

        private var strength:Number;

        public function MorphGrid(stepsX:uint, stepsY:uint, textureObject:Texture2D = null, strength:Number = 0.07) {
            this.strength = strength;
            super(stepsX, stepsY, textureObject);
        }

        override protected function step(elapsed:Number):void {

            var yPos:uint;
            var xPos:uint;

            var newX:Number;
            var newY:Number;

            var v:Vertex;

            for(var i:int = 0; i < vertexList.length; i++) {

                yPos= Math.floor(i / (stepsX + 1));
                xPos = i % (stepsY + 1);

                v = vertexList[i];

                if(xPos > 0 && yPos > 0 && xPos < stepsX && yPos < stepsY) {

                    newX = v.x + v.x * Math.sin(v.length * 10.0 + timeSinceStartInSeconds * 2.0) * strength;
                    newY = v.y + v.y * Math.cos(v.length * 10.0 + timeSinceStartInSeconds * 2.0) * strength;

                    material.modifyVertexInBuffer(v.bufferIdx, newX, newY);
                }
            }
        }
    }
}
