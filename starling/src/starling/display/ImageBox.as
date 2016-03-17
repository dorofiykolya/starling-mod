package starling.display
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.utils.HAlign;
    import starling.utils.RectangleUtil;
    import starling.utils.VAlign;
    
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
        
        private var mTexture:Texture;
        private var mVAlign:String;
        private var mHAlign:String;
        private var mMode:String;
        private var mImage:Image;
        private var mHitArea:Rectangle;
        private var mToolTip:String;
        
        public function ImageBox(texture:Texture = null)
        {
            mHitArea = new Rectangle();
            mVAlign = VAlign.CENTER;
            mHAlign = HAlign.CENTER;
            mMode = ZOOM;
            mTexture = texture;
            if (mTexture)
            {
                mHitArea.width = mTexture.frame ? mTexture.frame.width : mTexture.width;
                mHitArea.height = mTexture.frame ? mTexture.frame.height : mTexture.height;
                validateImage();
            }
        }
        
        public function get toolTip():String
        {
            return mToolTip;
        }
        
        public function set toolTip(value:String):void
        {
            mToolTip = value;
        }
        
        public function get clip():Boolean
        {
            return clipRect != null;
        }
        
        public function set clip(value:Boolean):void
        {
            if (value)
            {
                clipRect = mHitArea;
            }
            else
            {
                clipRect = null;
            }
        }
        
        public function get mode():String
        {
            return mMode;
        }
        
        public function set mode(value:String):void
        {
            if (mMode != value)
            {
                mMode = value;
                validatePosition();
            }
        }
        
        public function get hAlign():String
        {
            return mHAlign;
        }
        
        public function get vAlign():String
        {
            return mVAlign;
        }
        
        public function set vAlign(value:String):void
        {
            if (mVAlign != value && VAlign.isValid(value))
            {
                mVAlign = value;
                validateAlign();
            }
        }
        
        public function set hAlign(value:String):void
        {
            if (mHAlign != value && HAlign.isValid(value))
            {
                mHAlign = value;
                validateAlign();
            }
        }
        
        private function validateImage():void
        {
            if (mImage == null && mTexture)
            {
                mImage = new Image(mTexture);
            }
            else if (mTexture)
            {
                mImage.texture = mTexture;
                mImage.readjustSize();
            }
            
            if (mTexture && mImage.parent == null)
            {
                AddChild(mImage);
            }
            else if (mTexture == null && mImage)
            {
                mImage.RemoveFromParent();
            }
            
            validatePosition();
        }
        
        private function validatePosition():void
        {
            if (mImage == null)
            {
                return;
            }
            
            switch (mMode)
            {
                case NORMAL: 
                    mImage.scaleX = mImage.scaleY = 1;
                    break;
                case FIT: 
                    mImage.scaleX = mImage.scaleY = 1;
                    mImage.getBounds(mImage, sHelpRect);
                    mImage.scaleX = mImage.scaleY = calculateScaleRatioToFit(sHelpRect.width, sHelpRect.height, mHitArea.width, mHitArea.height);
                    break;
                case FILL: 
                    mImage.scaleX = mImage.scaleY = 1;
                    mImage.getBounds(mImage, sHelpRect);
                    mImage.scaleX = mImage.scaleY = calculateScaleRatioToFill(sHelpRect.width, sHelpRect.height, mHitArea.width, mHitArea.height);
                    break;
                case ZOOM: 
                    mImage.scaleX = mImage.scaleY = 1;
                    mImage.getBounds(mImage, sHelpRect);
                    mImage.scaleX = mImage.scaleY = calculateScaleRatioToFit(sHelpRect.width, sHelpRect.height, mHitArea.width, mHitArea.height);
                    if (mImage.scaleX > 1)
                        mImage.scaleX = mImage.scaleY = 1;
                    break;
                case STRETCH: 
                    mImage.scaleX = mImage.scaleY = 1;
                    mImage.width = mHitArea.width;
                    mImage.height = mHitArea.height;
                    return;
            }
            validateAlign();
        }
        
        private function validateAlign():void
        {
            if (mImage == null)
            {
                return;
            }
            
            mImage.getBounds(mImage.parent, sHelpRect);
            
            switch (mVAlign)
            {
                case VAlign.TOP: 
                    mImage.y = 0;
                    break;
                case VAlign.CENTER: 
                    mImage.y = (mHitArea.height - sHelpRect.height) / 2;
                    break;
                case VAlign.BOTTOM: 
                    mImage.y = mHitArea.height - sHelpRect.height;
                    break;
            }
            
            switch (mHAlign)
            {
                case HAlign.LEFT: 
                    mImage.x = 0;
                    break;
                case HAlign.CENTER: 
                    mImage.x = (mHitArea.width - sHelpRect.width) / 2;
                    break;
                case HAlign.RIGHT: 
                    mImage.x = mHitArea.width - sHelpRect.width;
                    break;
            }
        }
        
        public function get texture():Texture
        {
            return mTexture;
        }
        
        public function set texture(value:Texture):void
        {
            if (mTexture != value)
            {
                mTexture = value;
                validateImage();
            }
        }
        
        public function readjustSize():void
        {
            if (mImage && mTexture)
            {
                mImage.scaleX = mImage.scaleY = 1;
                mImage.readjustSize();
                setSize(mImage.width, mImage.height);
            }
        }
        
        public function setSize(aWidth:Number, aHeigth:Number):void
        {
            if (mHitArea.width != aWidth || mHitArea.height != aHeigth)
            {
                mHitArea.width = aWidth;
                mHitArea.height = aHeigth;
                validatePosition();
            }
        }
        
        /** @inheritDoc */
        public override function set width(value:Number):void
        {
            if (mHitArea.width != value)
            {
                mHitArea.width = value;
                validatePosition();
            }
        }
        
        /** @inheritDoc */
        public override function set height(value:Number):void
        {
            if (mHitArea.height != value)
            {
                mHitArea.height = value;
                validatePosition();
            }
        }
        
        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
        {
            getTransformationMatrix(targetSpace, sHelperMatrix);
            resultRect = RectangleUtil.getBounds(mHitArea, sHelperMatrix, resultRect);
            return resultRect;
        }
        
        public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;
            else if (mHitArea.containsPoint(localPoint))
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