/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.geom {
    import flash.geom.Vector3D;

    public class Face {

        public var v1:Vertex;
        public var v2:Vertex;
        public var v3:Vertex;

        public var uv1:UV;
        public var uv2:UV;
        public var uv3:UV;

        /**
         * Constructor of a Face
         * @param    reference to the mesh
         * @param    first vertex
         * @param    second vertex
         * @param    third vertex
         * @param    first uv
         * @param    second uv
         * @param    third uv
         */
        public function Face(v1:Vertex, v2:Vertex, v3:Vertex, uv1:UV = null, uv2:UV = null, uv3:UV = null) {

            this.v1 = v1;
            this.v2 = v2;
            this.v3 = v3;

            v1.faceRefs.push(this);
            v2.faceRefs.push(this);
            v3.faceRefs.push(this);

            this.uv1 = uv1;
            this.uv2 = uv2;
            this.uv3 = uv3;
        }

        public function getNormal():Vector3D {
            return getNormalFromVertices(v1, v2, v3);
        }

        public static function getNormalFromVertices(vert1:Vertex, vert2:Vertex, vert3:Vertex):Vector3D {
            var ab:Vertex;
            var ac:Vertex;
            var n:Vector3D;

            ab = new Vertex(vert2.x - vert1.x, vert2.y - vert1.y, vert2.z - vert1.z);
            ac = new Vertex(vert2.x - vert3.x, vert2.y - vert3.y, vert2.z - vert3.z);

            n = ac.crossProduct(ab);
            n.normalize();
            return n;
        }

        public function toString():String {
            return "Face: " + v1 + "/" + v2 + "/" + v3 + " / " + uv1 + " / " + uv2 + " / " + uv3;
        }
    }
}
