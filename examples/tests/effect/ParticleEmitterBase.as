package tests.effect
{

	public class ParticleEmitterBase
	{
		protected var _particleSystem:ParticleSystemExt;
		protected var _newParticleCount:Number = 0;
		
		public var emitPeriod:Number = 0;
		public var emitTime:Number = 1;
		public var emitRate:Number = 5;
		
		protected var pastTime:Number = 0;
		protected var inEmitTime : Boolean = true;

		public function update(elapsed:Number):void
		{
			if(!_particleSystem)
				return ;
			
			pastTime += elapsed;
			if(emitTime >= emitPeriod || emitPeriod <= 0)
				inEmitTime = true;
			else
			{
				var remainTime:Number = pastTime % emitPeriod ;
				inEmitTime = (remainTime <= emitTime );
			}
			if(!inEmitTime) return ;
			
			_newParticleCount += Number(elapsed * emitRate) ; 
			while( _newParticleCount > 1)
			{
				var newParticle:ParticleExt = _particleSystem.generateParticle();
				if(newParticle)
				{	
					initParticle(newParticle);
					if(_particleSystem)
						_particleSystem.uploadParticle(newParticle);
				}
				
				_newParticleCount--;
			}
		}
		
		protected function initParticle(newParticle:ParticleExt):void
		{
			throw new Error();
		}
		
		public function set particleSystem(value:ParticleSystemExt) : void
		{
			if(_particleSystem)
			{	
				_particleSystem.emitter = null;
			}
			_particleSystem = value;
		}
	}
}