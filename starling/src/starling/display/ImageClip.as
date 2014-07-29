package starling.display
{
	import starling.animation.IAnimatable;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author dorofiy.com
	 */
	
	/** Dispatched whenever the movie has displayed its last frame. */
	[Event(name="complete",type="starling.events.Event")]
	
	public class ImageClip extends Image implements IAnimatable
	{
		private var mTextures:Vector.<Texture>;
		private var mCurrentTime:Number;
		private var mCurrentFrame:int;
		private var mLoop:Boolean;
		private var mPlaying:Boolean;
		private var mFps:Number;
		private var mDefaultFrameDuration:Number;
		private var mTexturesCount:int;
		
		public function ImageClip(textures:Vector.<Texture>, fps:Number = 12)
		{
			if (textures.length > 0)
			{
				super(textures[0]);
				init(textures, fps);
			}
			else
			{
				throw new ArgumentError("Empty texture array");
			}
		}
		
		private function init(textures:Vector.<Texture>, fps:Number):void
		{
			if (fps <= 0)
				throw new ArgumentError("Invalid fps: " + fps);
			var numFrames:int = textures.length;
			
			mFps = fps;
			mDefaultFrameDuration = 1.0 / fps;
			mLoop = true;
			mPlaying = true;
			mCurrentTime = 0.0;
			mCurrentFrame = 0;
			mTextures = textures.slice();
			mTexturesCount = mTextures.length;
		}
		
		/** Starts playback. Beware that the clip has to be added to a juggler, too! */
		public function play():void
		{
			mPlaying = true;
		}
		
		/** Pauses playback. */
		public function pause():void
		{
			mPlaying = false;
		}
		
		/** Stops playback, resetting "currentFrame" to zero. */
		public function stop():void
		{
			mPlaying = false;
			currentFrame = 0;
		}
		
		/** Indicates if the clip is still playing. Returns <code>false</code> when the end
		 *  is reached. */
		public function get isPlaying():Boolean
		{
			if (mPlaying)
				return mLoop || mCurrentTime < totalTime;
			else
				return false;
		}
		
		/** Indicates if a (non-looping) movie has come to its end. */
		public function get isComplete():Boolean
		{
			return !mLoop && mCurrentTime >= totalTime;
		}
		
		/** The time that has passed since the clip was started (each loop starts at zero). */
		public function get currentTime():Number
		{
			return mCurrentTime;
		}
		
		/** The total number of frames. */
		public function get numFrames():int
		{
			return mTexturesCount;
		}
		
		/** Indicates if the clip should loop. */
		public function get loop():Boolean
		{
			return mLoop;
		}
		
		public function set loop(value:Boolean):void
		{
			mLoop = value;
		}
		
		/** The total duration of the clip in seconds. */
		public function get totalTime():Number
		{
			return mTexturesCount * mDefaultFrameDuration;
		}
		
		/** The index of the frame that is currently displayed. */
		public function get currentFrame():int
		{
			return mCurrentFrame;
		}
		
		public function set currentFrame(value:int):void
		{
			mCurrentFrame = value;
			mCurrentTime = mDefaultFrameDuration * value;
			texture = mTextures[mCurrentFrame];
		}
		
		/** The default number of frames per second. Individual frames can have different
		 *  durations. If you change the fps, the durations of all frames will be scaled
		 *  relatively to the previous value. */
		public function get fps():Number
		{
			return mFps;
		}
		
		public function set fps(value:Number):void
		{
			if (value <= 0)
				throw new ArgumentError("Invalid fps: " + value);
			mFps = value;
			mDefaultFrameDuration = 1.0 / mFps;
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(passedTime:Number):void
		{
			if (!mPlaying || passedTime <= 0.0)
				return;
			
			var finalFrame:int = mTexturesCount - 1;
			var previousFrame:int = mCurrentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;
			var dispatchCompleteEvent:Boolean = false;
			var totalTime:Number = this.totalTime;
			
			if (mLoop && mCurrentTime >= totalTime)
			{
				mCurrentTime = 0.0;
				mCurrentFrame = 0;
			}
			
			if (mCurrentTime < totalTime)
			{
				mCurrentTime += passedTime;
				finalFrame = mTextures.length - 1;
				
				while (mCurrentTime > mDefaultFrameDuration)
				{
					if (mCurrentFrame == finalFrame)
					{
						if (mLoop && !hasEventListener(Event.COMPLETE))
						{
							mCurrentTime -= totalTime;
							mCurrentFrame = 0;
						}
						else
						{
							breakAfterFrame = true;
							restTime = mCurrentTime - totalTime;
							dispatchCompleteEvent = true;
							mCurrentFrame = finalFrame;
							mCurrentTime = totalTime;
						}
					}
					else
					{
						mCurrentFrame++;
					}
					if (breakAfterFrame)
						break;
				}
				
				// special case when we reach *exactly* the total time.
				if (mCurrentFrame == finalFrame && mCurrentTime == totalTime)
					dispatchCompleteEvent = true;
			}
			
			// special case when we reach *exactly* the total time.
			if (mCurrentFrame == finalFrame && mCurrentTime == totalTime)
				dispatchCompleteEvent = true;
			
			if (mCurrentFrame != previousFrame)
				texture = mTextures[mCurrentFrame];
			
			if (dispatchCompleteEvent)
				dispatchEventWith(Event.COMPLETE);
			
			if (mLoop && restTime > 0.0)
				advanceTime(restTime);
		}
	}
}