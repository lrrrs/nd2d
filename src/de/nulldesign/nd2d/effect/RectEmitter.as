package de.nulldesign.nd2d.effect
{
	
	import flash.geom.Vector3D;
	
	public class RectEmitter extends ParticleEmitterBase
	{
		
		public var lifeTime:int = 2;
		public var lifeTimeRange:int = 0;
		public var color:uint = 0xffffff;
		public var colorRange:uint = 0x000000;
		public var alpha:Number = 1;
		public var alphaRange : Number = 0;
		public var sizeX : Number = 10;
		public var sizeY : Number = 10;
		public var sizeRange : Number = 0;
		public var directionFrom : Vector3D = new Vector3D(0,1,0);
		public var directionTo : Vector3D = new Vector3D(0,1,0);
		public var vel : int = 100;
		public var velRange : int = 0;
		public var rot : Number = 0;
		public var rotRange : Number = 0;
		public var rotVel : Number = 1;
		public var rotVelRange : Number = 0;
		public var EmitterRectFrom : Vector3D = new Vector3D(-100,-100,0);
		public var EmitterRectTo : Vector3D = new Vector3D(100,100,0);
		
		public function RectEmitter()
		{
			super();
		} 
		
		override protected function initParticle(newParticle:ParticleExt):void
		{
			newParticle.color = color + colorRange * Math.random();
			newParticle.alpha = alpha + alphaRange * Math.random();
			newParticle.u = 0;
			newParticle.v = 0;
			newParticle.remainTime = lifeTime + lifeTimeRange * Math.random();
			newParticle.dir.x = directionFrom.x * Math.random() + directionTo.x * Math.random();
			newParticle.dir.y = directionFrom.y * Math.random() + directionTo.y * Math.random();
			newParticle.dir.z = directionFrom.z * Math.random() + directionTo.z * Math.random();
			newParticle.dir.normalize();
			newParticle.vel = vel + velRange * Math.random();
			var sizeRand : Number = sizeRange * Math.random();
			newParticle.sizeX = sizeX + sizeRand;
			newParticle.sizeY = sizeY + sizeRand;
			newParticle.rot = rot +  rotRange * Math.random();
			newParticle.rotVel = rotVel + rotVelRange * Math.random();
			
			newParticle.pos.x += (EmitterRectTo.x - EmitterRectFrom.x) * Math.random() + EmitterRectFrom.x;
			newParticle.pos.y += (EmitterRectTo.y - EmitterRectFrom.y) * Math.random() + EmitterRectFrom.y;
//			newParticle.pos.z += (EmitterRectTo.z - EmitterRectFrom.z) * Math.random() + EmitterRectFrom.z;
		}
	}
}