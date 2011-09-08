/**
 * (c) 2010 by nulldesign
 * Created by lars
 * Date: 08.09.11 12:00
 */
package de.nulldesign.nd2d.materials {

    import flash.display3D.textures.Texture;

    public class Texture2D {

        public var texture:Texture;
        public var textureWidth:Number;
        public var textureHeight:Number;

        public function Texture2D(texture:Texture, textureWidth:Number, textureHeight:Number) {
            this.texture = texture;
            this.textureWidth = textureWidth;
            this.textureHeight = textureHeight;
        }
    }
}
