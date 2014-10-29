package starling.display
{
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import starling.utils.RectangleUtil;
    
    /**
     * ...
     * @author dorofiy.com
     */
    public class SpriteBox extends Sprite
    {
        private static const HELP_MATRIX:Matrix = new Matrix();
        private static const HELP_RECT:Rectangle = new Rectangle();
        
        private var _contentArea:Rectangle;
        
        public function SpriteBox()
        {
            _contentArea = new Rectangle(0, 0, NaN, NaN);
        }
        
        override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
        {
            var isWidthInvalid:Boolean;
            var isHeightInvalid:Boolean;
            if (isNaN(_contentArea.width))
            {
                isWidthInvalid = true;
            }
            if (isNaN(_contentArea.height))
            {
                isHeightInvalid = true;
            }
            
            if (isWidthInvalid && isHeightInvalid)
            {
                return super.getBounds(targetSpace, resultRect);
            }
            
            if (isWidthInvalid || isHeightInvalid)
            {
                super.getBounds(targetSpace, HELP_RECT);
            }
            
            if (isWidthInvalid == false)
            {
                HELP_RECT.width = _contentArea.width;
            }
            if (isHeightInvalid == false)
            {
                HELP_RECT.height = _contentArea.height;
            }
            
            getTransformationMatrix(targetSpace, HELP_MATRIX);
            resultRect = RectangleUtil.getBounds(HELP_RECT, HELP_MATRIX, resultRect);
            
            if (isWidthInvalid)
            {
                resultRect.width = HELP_RECT.width;
            }
            if (isHeightInvalid)
            {
                resultRect.height = HELP_RECT.height;
            }
            return resultRect;
        }
        
        public function get contentWidth():Number
        {
            return _contentArea.width;
        }
        
        public function get contentHeight():Number
        {
            return _contentArea.height;
        }
        
        public function set contentWidth(value:Number):void
        {
            if (isNaN(value) || value <= 0)
            {
                value = NaN;
            }
            _contentArea.width = value;
        }
        
        public function set contentHeight(value:Number):void
        {
            if (isNaN(value) || value <= 0)
            {
                value = NaN;
            }
            _contentArea.height = value;
        }
        
        public function setContentSize(width:Number, height:Number):void
        {
            contentWidth = width;
            contentHeight = height;
        }
        
        public function updateContentSize():void
        {
            contentWidth = super.width;
            contentHeight = super.height;
        }
    }
}