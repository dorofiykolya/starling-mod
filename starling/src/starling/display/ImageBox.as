package starling.display
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.Align;
	import starling.utils.RectangleUtil;
	
	/**
	 * ...
	 * @author dorofiy.com
	 */
	public class ImageBox extends Sprite
	{
		public static const NORMAL:String = "normal";
		public static const FIT:String = "fit";
		public static const FILL:String = "fill";
		public static const ZOOM:String = "zoom";
		public static const STRETCH:String = "stretch";
		
		private static const sHelpRect:Rectangle = new Rectangle();
		private static const sHelperMatrix:Matrix = new Matrix();
		
		private var _texture:Texture;
		private var _vAlign:String;
		private var _hAlign:String;
		private var _mode:String;
		private var _image:Image;
		private var _hitArea:Rectangle;
		
		public function ImageBox(texture:Texture = null)
		{
			_hitArea = new Rectangle();
			_vAlign = Align.CENTER;
			_hAlign = Align.CENTER;
			_mode = ZOOM;
			_texture = texture;
			if (_texture)
			{
				_hitArea.width = _texture.frame ? _texture.frame.width : _texture.width;
				_hitArea.height = _texture.frame ? _texture.frame.height : _texture.height;
				validateImage();
			}
		}
		
		public function get clip():Boolean
		{
			return clipRect != null;
		}
		
		public function set clip(value:Boolean):void
		{
			if (value)
			{
				clipRect = _hitArea;
			}
			else
			{
				clipRect = null;
			}
		}
		
		public function get mode():String
		{
			return _mode;
		}
		
		public function set mode(value:String):void
		{
			if (_mode != value)
			{
				_mode = value;
				validatePosition();
			}
		}
		
		public function get hAlign():String
		{
			return _hAlign;
		}
		
		public function get vAlign():String
		{
			return _vAlign;
		}
		
		public function set vAlign(value:String):void
		{
			if (_vAlign != value && Align.isValid(value))
			{
				_vAlign = value;
				validateAlign();
			}
		}
		
		public function set hAlign(value:String):void
		{
			if (_hAlign != value && Align.isValid(value))
			{
				_hAlign = value;
				validateAlign();
			}
		}
		
		private function validateImage():void
		{
			if (_image == null && _texture)
			{
				_image = new Image(_texture);
			}
			else if (_texture)
			{
				_image.texture = _texture;
				_image.readjustSize();
			}
			
			if (_texture && _image.parent == null)
			{
				insert(_image);
			}
			else if (_texture == null && _image)
			{
				_image.cutFromParent();
			}
			
			validatePosition();
		}
		
		private function validatePosition():void
		{
			if (_image == null)
			{
				return;
			}
			
			switch (_mode)
			{
				case NORMAL: 
					_image.scaleX = _image.scaleY = 1;
					break;
				case FIT: 
					_image.scaleX = _image.scaleY = 1;
					_image.getBounds(_image, sHelpRect);
					_image.scaleX = _image.scaleY = calculateScaleRatioToFit(sHelpRect.width, sHelpRect.height, _hitArea.width, _hitArea.height);
					break;
				case FILL: 
					_image.scaleX = _image.scaleY = 1;
					_image.getBounds(_image, sHelpRect);
					_image.scaleX = _image.scaleY = calculateScaleRatioToFill(sHelpRect.width, sHelpRect.height, _hitArea.width, _hitArea.height);
					break;
				case ZOOM: 
					_image.scaleX = _image.scaleY = 1;
					_image.getBounds(_image, sHelpRect);
					_image.scaleX = _image.scaleY = calculateScaleRatioToFit(sHelpRect.width, sHelpRect.height, _hitArea.width, _hitArea.height);
					if (_image.scaleX > 1)
						_image.scaleX = _image.scaleY = 1;
					break;
				case STRETCH: 
					_image.scaleX = _image.scaleY = 1;
					_image.width = _hitArea.width;
					_image.height = _hitArea.height;
					return;
			}
			validateAlign();
		}
		
		private function validateAlign():void
		{
			if (_image == null)
			{
				return;
			}
			
			_image.getBounds(_image.parent, sHelpRect);
			
			switch (_vAlign)
			{
				case VAlign.TOP: 
					_image.y = 0;
					break;
				case VAlign.CENTER: 
					_image.y = (_hitArea.height - sHelpRect.height) / 2;
					break;
				case VAlign.BOTTOM: 
					_image.y = _hitArea.height - sHelpRect.height;
					break;
			}
			
			switch (_hAlign)
			{
				case HAlign.LEFT: 
					_image.x = 0;
					break;
				case HAlign.CENTER: 
					_image.x = (_hitArea.width - sHelpRect.width) / 2;
					break;
				case HAlign.RIGHT: 
					_image.x = _hitArea.width - sHelpRect.width;
					break;
			}
		}
		
		public function get texture():Texture
		{
			return _texture;
		}
		
		public function set texture(value:Texture):void
		{
			if (_texture != value)
			{
				_texture = value;
				validateImage();
			}
		}
		
		public function readjustSize():void
		{
			if (_image && _texture)
			{
				_image.scaleX = _image.scaleY = 1;
				_image.readjustSize();
				setSize(_image.width, _image.height);
			}
		}
		
		public function setSize(aWidth:Number, aHeigth:Number):void
		{
			if (_hitArea.width != aWidth || _hitArea.height != aHeigth)
			{
				_hitArea.width = aWidth;
				_hitArea.height = aHeigth;
				validatePosition();
			}
		}
		
		/** @inheritDoc */
		public override function set width(value:Number):void
		{
			if (_hitArea.width != value)
			{
				_hitArea.width = value;
				validatePosition();
			}
		}
		
		/** @inheritDoc */
		public override function set height(value:Number):void
		{
			if (_hitArea.height != value)
			{
				_hitArea.height = value;
				validatePosition();
			}
		}
		
		/** @inheritDoc */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			getTransformationMatrix(targetSpace, sHelperMatrix);
			resultRect = RectangleUtil.getBounds(_hitArea, sHelperMatrix, resultRect);
			return resultRect;
		}
		
		public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
		{
			if (forTouch && (!visible || !touchable))
				return null;
			else if (_hitArea.containsPoint(localPoint))
				return this;
			else
				return null;
		}
		
		public function calculateScaleRatioToFill(originalWidth:Number, originalHeight:Number, targetWidth:Number, targetHeight:Number):Number
		{
			var widthRatio:Number = targetWidth / originalWidth;
			var heightRatio:Number = targetHeight / originalHeight;
			if (widthRatio > heightRatio)
			{
				return widthRatio;
			}
			return heightRatio;
		}
		
		public function calculateScaleRatioToFit(originalWidth:Number, originalHeight:Number, targetWidth:Number, targetHeight:Number):Number
		{
			var widthRatio:Number = targetWidth / originalWidth;
			var heightRatio:Number = targetHeight / originalHeight;
			if (widthRatio < heightRatio)
			{
				return widthRatio;
			}
			return heightRatio;
		}
	
	}

}