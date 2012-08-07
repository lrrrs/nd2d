package tests.effect
{
	import de.nulldesign.nd2d.display.Camera2D;
	import de.nulldesign.nd2d.display.Node2D;
	import tests.effect.ParticleEmitterBase;
	import tests.effect.ParticleSystemExtMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display3D.Context3D;

	public class ParticleSystemExt extends Node2D
	{
		protected var _particles:Vector.<ParticleExt>;
		protected var _emitter:ParticleEmitterBase;
		protected var _material:ParticleSystemExtMaterial;
		protected var _maxCapacity:uint = 0 ;
		protected var _lastIndex:int = -1;
		protected var _maxLiveIndex:int = -1;
		protected var _emitting:Boolean = false;
		
		public function ParticleSystemExt(maxCapacity:uint , emitter:ParticleEmitterBase , texture:Texture2D)
		{
			_maxCapacity = maxCapacity ;
			_particles = new Vector.<ParticleExt>(_maxCapacity, true);
			_emitter = emitter;
			_emitter.particleSystem = this;
			_material = new ParticleSystemExtMaterial(this,texture);
		}
		
		public function get particles():Vector.<ParticleExt>
		{
			return _particles;
		}
		
		public function get maxLiveIndex():int
		{
			return _maxLiveIndex;
		}

		public function get maxCapacity():uint
		{
			return _maxCapacity;
		}

		public function set emitter(value : ParticleEmitterBase) : void {_emitter = value;}
		public function get emitter() : ParticleEmitterBase {return _emitter;}
		
		public function generateParticle():ParticleExt
		{
			if(++_lastIndex >= _maxCapacity )
				_lastIndex = 0 ; 
			if(_maxLiveIndex < _maxCapacity - 1)
				_maxLiveIndex ++ ;
			
			if(_particles[_lastIndex])
			{
				_particles[_lastIndex].reset();
			}else
			{
				_particles[_lastIndex] = new ParticleExt(_lastIndex);
				_material.uploadParticle(_particles[_lastIndex],true);
			}
			
			return _particles[_lastIndex];
		}
		
		public function stop(immediately : Boolean) : void
		{
			_emitting = false;
			if(immediately)
			{	
				for(var i:int = 0 ; i<= _maxLiveIndex ; i++)
				{
					_particles[i].die();
				}
			}
		}
		
		public function start() : void 
		{
			_emitting = true;
		}
		

		public function uploadParticle(newParticle:ParticleExt):void
		{
			_material.uploadParticle(newParticle,false);
		}
		
		override protected function step(elapsed:Number):void 
		{
			for(var i:int = 0 ; i<= _maxLiveIndex ; i ++)
			{
				if(!_particles[i].isDead())
				{
					_particles[i].update(elapsed);
				}
			}
			
			if(_emitter && _emitting)
				_emitter.update(elapsed);
		}
		
		
		override public function handleDeviceLoss():void 
		{
			super.handleDeviceLoss();
			_material.handleDeviceLoss();
		}
		
		override protected function draw(context:Context3D, camera:Camera2D):void
		{
			
			_material.blendMode = blendMode;
			_material.modelMatrix = worldModelMatrix;
			_material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			_material.render(context, null, 0,(_maxLiveIndex+1) * 2); //dont use facelist
		}
		
		override public function dispose():void 
		{
			if(_material)
			{
				_material.dispose();
				_material = null;
			}
			super.dispose();
		}
	}
}