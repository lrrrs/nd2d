/**
 * ND2D Molehill Engine v0.1
 * @author Lars Gerckens www.nulldesign.de
 *
 */

package de.nulldesign.nd2d.materials {
    import de.nulldesign.nd2d.utils.*;

    import flash.display3D.Context3DBlendFactor;

    public class BlendModePresets {

        public static const ADD:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
        public static const BLEND:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        public static const FILTER:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
        public static const MODULATE:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);

        public static const NORMAL:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        public static const ADD2:NodeBlendMode = new NodeBlendMode(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
    }
}
