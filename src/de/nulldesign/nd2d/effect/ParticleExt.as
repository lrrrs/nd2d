package de.nulldesign.nd2d.effect
{
	import flash.geom.Vector3D;

	public class ParticleExt
	{
		public var index : int;
		public var noDead : Boolean = false;
		private var _remainTime:Number;
		public var pastTime:Number;
		public var pos : Vector3D = new Vector3D;
		public var dir : Vector3D = new Vector3D;
		public var vel : Number = 0;
		public var sizeX : Number  = 0;
		public var sizeY : Number = 0;
		
		public var rot : Number = 0;
		public var rotVel : Number = 0;
		public var color : uint = 0xffffff;
		public var alpha : Number = 1.0;
		public var u : Number = 0.0;
		public var v : Number = 0.0;
		public var su : Number = 1.0;
		public var sv : Number = 1.0;
		
		public function ParticleExt(index:int)
		{
			this.index = index;
		}
		
		public function get r() : Number {return ((color & 0xff0000) >> 16) / 0xff;}
		public function get g() : Number {return ((color & 0x00ff00) >> 8) / 0xff;}
		public function get b() : Number {return (color & 0x0000ff) / 0xff;}
		
		public function reset() : void
		{
			_remainTime = 0;
			pastTime = 0;
			sizeX = 0;
			sizeY = 0;
			vel = 0;
			rot = 0;
			rotVel = 0;
			color = 0xffffff;
			alpha = 1.0;
			u = 0;
			v = 0;
			pos.setTo(0,0,0);
			dir.setTo(0,1,0);
		}
		
		public function set remainTime(value : int) : void
		{
			_remainTime = value;
			pastTime = 0;
		}
		public function get remainTime() : int {return _remainTime;}
		public function isDead() : Boolean {return _remainTime <= 0 && !noDead ; } 
		public function die() : void { pastTime += _remainTime; _remainTime = 0; noDead = false; }
		
		public function update(elapsed:Number) : void
		{
			_remainTime -= elapsed;
			pastTime += elapsed;
			if(noDead && _remainTime<=0)
			{
				_remainTime = pastTime + _remainTime;
				pastTime = 0;
			}
		}
	}
}