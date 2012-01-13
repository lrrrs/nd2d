/**
 * de.nulldesign.nd2d.events
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 10.01.12 23:52
 */
package de.nulldesign.nd2d.events {

	import flash.events.Event;

	public class SpriteSheetAnimationEvent extends Event {

		public static const ANIMATION_FINISHED:String = "animationFinished";

		public function SpriteSheetAnimationEvent(type:String) {
			super(type);
		}
	}
}
