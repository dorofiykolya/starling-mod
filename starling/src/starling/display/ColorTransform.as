package starling.display 
{
	/**
	 * ...
	 * @author dorofiy.com
	 */
	public class ColorTransform 
	{
		public var alphaMultiplier : Number = 1;
		public var redMultiplier : Number = 1;
		public var greenMultiplier : Number = 1;
		public var blueMultiplier : Number = 1;
		
		public var alpha : Number = 255;
		public var red : Number = 255;
		public var green : Number = 255;
		public var blue : Number = 255;
		
		public function ColorTransform(red:Number = 255.0, green:Number = 255.0, blue:Number = 255.0, alpha:Number = 255.0, redMultiplier:Number = 1.0, greenMultiplier:Number = 1.0, blueMultiplier:Number = 1.0, alphaMultiplier:Number = 1.0)
		{
			this.alphaMultiplier = alphaMultiplier;
			this.redMultiplier = redMultiplier;
			this.greenMultiplier = greenMultiplier;
			this.blueMultiplier = blueMultiplier;
			
			this.alpha = alpha;
			this.red = red;
			this.green = green;
			this.blue = blue;
		}
		
		/**
		 * RGB
		 */
		public function set color(value:uint):void
		{
			red = (value >> 16) & 0xFF;
			green = (value >> 8) & 0xFF;
			blue = value & 0xFF;
		}
		
		/**
		 * RGB
		 */
		public function get color():uint
		{
			return red << 16 ^ green << 8 ^ blue;
		}
		
		/**
		 * RGB
		 */
		public function set rgb(value:uint):void
		{
			red = (value >> 16) & 0xFF;
			green = (value >> 8) & 0xFF;
			blue = value & 0xFF;
		}
		
		/**
		 * RGB
		 */
		public function get rgb():uint
		{
			return red << 16 ^ green << 8 ^ blue;
		}
		
		/**
		 * RGBA
		 */
		public function set rgba(value:uint):void
		{
			alpha = (value >> 24) & 0xFF;
			red = (value >> 16) & 0xFF;
			green = (value >> 8) & 0xFF;
			blue = value & 0xFF;
		}
		
		/**
		 * RGBA
		 */
		public function get rgba():uint
		{
			return  alpha << 24 ^ red << 16 ^ green << 8 ^ blue;
		}
		
		public function get saturation():Number
		{
			var value:Number;
			var max:Number = Math.max(red / 255.0, Math.max(green / 255.0, blue / 255.0));
			var min:Number = Math.min(red / 255.0, Math.min(green / 255.0, blue / 255.0));
			var delta:Number = max - min;
			if (max != 0)
			{
				value = delta / max;
			}
			else
			{
				value = 0;
			}
			return value;
		}
		
		public function get brightness():Number
		{
			return Math.max(red / 255.0, Math.max(green / 255.0, blue / 255.0));
		}
		
		public function get hue():Number
		{
			var h:Number, s:Number;
			var r:Number = red / 255.0;
			var g:Number = green / 255.0;
			var b:Number = blue / 255.0;
			var max:Number = Math.max(r, Math.max(g, b));
			var min:Number = Math.min(r, Math.min(g, b));
			var delta:Number = max - min;
			if (max != 0)
			{
				s = delta / max;
			}
			else
			{
				s = 0;
			}
			if (s == 0)
			{
				h = NaN;
			}
			else
			{
				if (r == max)
				{
					h = (g - b) / delta;
				}
				else if (g == max)
				{
					h = 2 + (b - r) / delta
				}
				else if (b == max)
				{
					h = 4 + (r - g) / delta;
				}
				h = h * 60;
				if (h < 0)
				{
					h += 360;
				}
			}
			return h;
		}
		
		public function hsb(hue:Number, saturation:Number, brightness:Number):void
		{
			var r:Number, g:Number, b:Number;
			if (saturation == 0)
			{
				r = g = b = brightness;
			}
			else
			{
				var h:Number = (hue % 360) / 60;
				var i:int = int(h);
				var f:Number = h - i;
				var p:Number = brightness * (1 - saturation);
				var q:Number = brightness * (1 - (saturation * f));
				var t:Number = brightness * (1 - (saturation * (1 - f)));
				switch (i)
				{
					case 0: 
						r = brightness;
						g = t;
						b = p;
						break;
					case 1: 
						r = q;
						g = brightness;
						b = p;
						break;
					case 2: 
						r = p;
						g = brightness;
						b = t;
						break;
					case 3: 
						r = p;
						g = q;
						b = brightness;
						break;
					case 4: 
						r = t;
						g = p;
						b = brightness;
						break;
					case 5: 
						r = brightness;
						g = p;
						b = q;
						break;
				}
			}
			red = r * 255.0;
			green = g * 255.0;
			blue = b * 255.0;
		}
		
		public function reset():void
		{
			alpha = 255.0;
			red = 255.0;
			green = 255.0;
			blue = 255.0;
			
			alphaMultiplier = 1.0;
			redMultiplier = 1.0;
			greenMultiplier = 1.0;
			blueMultiplier = 1.0;
		}
		
		public function invert():void
		{
			color = 0xffffff - color;
		}
		
		public function offset(transform:ColorTransform):void
		{
			alpha += transform.alpha;
			red += transform.red;
			green += transform.green;
			blue += transform.blue;
			
			alphaMultiplier += transform.alphaMultiplier;
			redMultiplier += transform.redMultiplier;
			greenMultiplier += transform.greenMultiplier;
			blueMultiplier += transform.blueMultiplier;
		}
		
		public function copyFrom(transform:ColorTransform):void
		{
			alpha = transform.alpha;
			red = transform.red;
			green = transform.green;
			blue = transform.blue;
			
			alphaMultiplier = transform.alphaMultiplier;
			redMultiplier = transform.redMultiplier;
			greenMultiplier = transform.greenMultiplier;
			blueMultiplier = transform.blueMultiplier;
		}
		
		public function clone():ColorTransform
		{
			var transform:ColorTransform = new ColorTransform();
			transform.alpha = alpha;
			transform.red = red;
			transform.green = green;
			transform.blue = blue;
			transform.alphaMultiplier = alphaMultiplier;
			transform.redMultiplier = redMultiplier;
			transform.greenMultiplier = greenMultiplier;
			transform.blueMultiplier = blueMultiplier;
			return transform;
		}
		
	}

}