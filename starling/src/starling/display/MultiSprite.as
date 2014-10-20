package starling.display
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;
    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;
    
    /**
     * Sprite able to render images using up to 4 different textures. Use with care - this is not finished, not uniform
     * solution targeted for research only.
     * Special attention should be paid to MAX_TEXTURES, NUMBERS_PER_VERTES, and TEXTURE_MASK_FLOAT_TYPE static values.
     * They are all dependant. When you change MAX_TEXTURES value - set corresponding FLOAT_* value for
     * TEXTURE_MASK_FLOAT_TYPE.
     *
     * @author dorofiy.com
     */
    public class MultiSprite extends Sprite
    {
        /**
         * Number of textures to load. These textures will be always loaded, and program size depends on this particular
         * value. Unfortunately, this has to be done, because otherwise you cannot know how many textures are gonna be used
         * here, and pre-allocate buffer size. Maybe one day... I think we will change the way we render, and configure each
         * MultiSprite seperately.
         */
        public static const MAX_TEXTURES:uint = 4;
        /**
         * Number of numbers per single vertex. X, Y, color(r,g,b,a), u, v, texture-masks
         */
        public static const NUMBERS_PER_VERTEX:uint = 4 + 4 + MAX_TEXTURES;
        /**
         * start name
         */
        private static const PROGRAM_NAME:String = "MS_";
        
        private var _hasTexture:Boolean;
        
        private var _vertexData:Vector.<Number>;
        private var _indexData:Vector.<uint>;
        
        private var _vertexBufferSize:int;
        private var _vertexBuffer:VertexBuffer3D;
        private var _indexBuffer:IndexBuffer3D;
        
        private var _tinted:Boolean;
        private var _indexId:uint;
        private var _vertexId:uint;
        private var _textureMask:Vector.<int>;
        private var _textures:Vector.<Texture>;
        private var _smoothing:String;
        private var _context3DVertexBufferFormat:Vector.<String>;
        private var _tintedTextures:Vector.<Boolean>;
        
        public function MultiSprite()
        {
            _indexId = 0;
            _vertexId = 0;
            _vertexData = new Vector.<Number>();
            _indexData = new Vector.<uint>();
            _textureMask = new <int>[0, 0, 0, 0];
            _smoothing = TextureSmoothing.BILINEAR;
            _textures = new <Texture>[null, null, null, null];
            _tintedTextures = new <Boolean>[false, false, false, false];
            _context3DVertexBufferFormat = new <String>[null, Context3DVertexBufferFormat.FLOAT_1, Context3DVertexBufferFormat.FLOAT_2, Context3DVertexBufferFormat.FLOAT_3, Context3DVertexBufferFormat.FLOAT_4];
            
            Starling.current.addEventListener(starling.events.Event.CONTEXT3D_CREATE, onContext3DCreate);
        }
        
        public function get smoothing():String
        {
            return _smoothing;
        }
        
        public function set smoothing(value:String):void
        {
            if (TextureSmoothing.isValid(value))
            {
                _smoothing = value;
            }
        }
        
        private function onContext3DCreate(event:Event):void
        {
            if (_vertexBuffer != null)
            {
                _vertexBuffer.dispose();
                _vertexBuffer = null;
                _indexBuffer.dispose();
                _indexBuffer = null;
            }
        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
            if (numChildren != 0 && hasVisibleArea)
            {
                prepareToRender();
                batchContainer(this, support, parentAlpha * alpha);
                renderCustom(support);
            }
        }
        
        private function prepareToRender():void
        {
            _vertexId = 0;
            _indexId = 0;
            _tinted = false;
            _hasTexture = false;
            for (var i:int = 0; i < MAX_TEXTURES; i++)
            {
                _textures[i] = null;
                _textureMask[i] = 0;
            }
        }
        
        private function renderCustom(support:RenderSupport):void
        {
            support.finishQuadBatch();
            
            if (_vertexId == 0)
            {
                return;
            }
            
            var context:Context3D = Starling.context;
            var target:Starling = Starling.current;
            var program:Program3D;
            var index:int;
            if (_vertexBuffer == null || _vertexBufferSize != _vertexId / NUMBERS_PER_VERTEX)
            {
                if (_vertexBuffer != null)
                {
                    _vertexBuffer.dispose();
                    _indexBuffer.dispose();
                }
                _vertexBufferSize = _vertexId / NUMBERS_PER_VERTEX;
                _vertexBuffer = context.createVertexBuffer(_vertexBufferSize, NUMBERS_PER_VERTEX);
                _indexBuffer = context.createIndexBuffer(_indexId);
            }
            
            for (var j:int = 0; j < _textures.length; j++)
            {
                if (_textures[j])
                {
                    index++;
                }
            }
            
            _vertexBuffer.uploadFromVector(_vertexData, 0, _vertexId / NUMBERS_PER_VERTEX);
            _indexBuffer.uploadFromVector(_indexData, 0, _indexId);
            
            context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // x, y
            if (_tinted || !_hasTexture)
            {
                context.setVertexBufferAt(3, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_4); // color
            }
            if (_hasTexture)
            {
                context.setVertexBufferAt(1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2); // u, v
                context.setVertexBufferAt(2, _vertexBuffer, 8, _context3DVertexBufferFormat[index]); // tx1, tx2, tx3, tx4
            }
            context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            
            program = getProgram(_textures, _tintedTextures, index, _smoothing);
            
            context.setProgram(program);
            
            if (_hasTexture)
            {
                context.setTextureAt(0, _textures[0].base);
                if (null != _textures[1])
                {
                    context.setTextureAt(1, _textures[1].base);
                }
                if (MAX_TEXTURES > 2)
                {
                    if (null != _textures[2])
                    {
                        context.setTextureAt(2, _textures[2].base);
                    }
                    if (MAX_TEXTURES > 3)
                    {
                        if (null != _textures[3])
                        {
                            context.setTextureAt(3, _textures[3].base);
                        }
                    }
                }
            }
            support.raiseDrawCount();
            context.drawTriangles(_indexBuffer);
            for (var i:int = 0; i < MAX_TEXTURES; i++)
            {
                context.setTextureAt(i, null);
                _textures[i] = null;
                _tintedTextures[i] = false;
            }
            
            context.setVertexBufferAt(0, null);
            if (_hasTexture)
            {
                context.setVertexBufferAt(1, null); // u, v
                context.setVertexBufferAt(2, null); // tx1, tx2, tx3, tx4
            }
            if (_tinted || !_hasTexture)
            {
                context.setVertexBufferAt(3, null); // color
            }
        }
        
        private function batchContainer(target:DisplayObjectContainer, support:RenderSupport, parentAlpha:Number):void
        {
            var child:DisplayObject;
            var container:DisplayObjectContainer;
            for each (child in target.children)
            {
                if (child.hasVisibleArea)
                {
                    container = child as DisplayObjectContainer;
                    support.pushMatrix();
                    support.transformMatrix(child);
                    if (container)
                    {
                        batchContainer(container, support, child.alpha * parentAlpha);
                    }
                    else
                    {
                        batchChild(child, support, child.alpha * parentAlpha);
                    }
                    support.popMatrix();
                }
            }
        }
        
        private function batchChild(child:DisplayObject, support:RenderSupport, alpha:Number):void
        {
            var matrix:Matrix;
            var index:int;
            var j:int;
            var texture:Texture;
            var image:Image = child as Image;
            if (image)
            {
                texture = image.texture;
                for (; j < MAX_TEXTURES; ++j)
                {
                    _textureMask[0] = 0;
                    _textureMask[1] = 0;
                    _textureMask[2] = 0;
                    _textureMask[3] = 0;
                    for (i = 0; i < MAX_TEXTURES; ++i)
                    {
                        if (_textures[i] == null)
                        {
                            _textures[i] = texture;
                            _hasTexture = true;
                        }
                        if (_textures[i].base == texture.base)
                        {
                            _textureMask[i] = 1;
                            index = i;
                            break;
                        }
                    }
                    if (i < MAX_TEXTURES)
                    {
                        break;
                    }
                    renderCustom(support);
                }
                
                matrix = support.mvpMatrix;
                var vvid:uint = _vertexId / NUMBERS_PER_VERTEX;
                _indexData[int(_indexId++)] = vvid;
                _indexData[int(_indexId++)] = vvid + 1;
                _indexData[int(_indexId++)] = vvid + 2;
                _indexData[int(_indexId++)] = vvid + 1;
                _indexData[int(_indexId++)] = vvid + 2;
                _indexData[int(_indexId++)] = vvid + 3;
                for (var i:int = 0; i < 4; ++i)
                {
                    if (image.copyVertexDataToVector(i, _vertexData, _vertexId, matrix, alpha))
                    {
                        _tinted = true;
                        _tintedTextures[index] = true;
                    }
                    _vertexId += 8;
                    
                    for (j = 0; j < MAX_TEXTURES; ++j)
                    {
                        _vertexData[int(_vertexId++)] = _textureMask[j];
                    }
                }
                if (vvid / 4 > QuadBatch.MAX_NUM_QUADS)
                {
                    renderCustom(support);
                }
            }
            else
            {
                renderCustom(support);
                child.render(support, alpha);
            }
        }
        
        private function getProgramName(textures:Vector.<Texture>, tinted:Vector.<Boolean>, textureCount:int, smoothing:String):String
        {
            var flag:uint = 0;
            var result:uint = 0;
            var textureInfo:Texture;
            for (var i:int = 0; i < textureCount; i++)
            {
                textureInfo = textures[i];
                flag = 0;
                if (textureInfo.mipMapping)
                    flag |= 1;
                if (textureInfo.repeat)
                    flag |= 1 << 1;
                if (tinted[i])
                    flag |= 1 << 2;
                if (textureInfo.format == Context3DTextureFormat.COMPRESSED)
                    flag |= 1 << 3;
                if (textureInfo.format == Context3DTextureFormat.COMPRESSED_ALPHA)
                    flag |= 1 << 4;
                if (smoothing == TextureSmoothing.BILINEAR)
                    flag |= 1 << 5;
                else if (smoothing == TextureSmoothing.TRILINEAR)
                    flag |= 1 << 6;
                if (i != 0)
                {
                    result |= (flag << 8 * i);
                }
                else
                {
                    result = flag;
                }
            }
            return PROGRAM_NAME + result.toString(16);
        }
        
        private function getProgram(textures:Vector.<Texture>, tinted:Vector.<Boolean>, textureCount:int, smoothing:String):Program3D
        {
            var name:String = getProgramName(textures, tinted, textureCount, smoothing);
            var program:Program3D = Starling.current.getProgram(name);
            if (!program)
            {
                program = registerProgram(name, textures, tinted, textureCount, smoothing);
            }
            return program;
        }
        
        private function registerProgram(programName:String, textures:Vector.<Texture>, tinted:Vector.<Boolean>, textureCount:int, smoothing:String):Program3D
        {
            var vertexASM:String = _tinted ? ["mov op, va0", "mov v0, va1", "mov v1, va2", "mov v2, va3"].join("\n") : ["mov op, va0", "mov v0, va1", "mov v1, va2"].join("\n");
            
            var fragmentArray:Vector.<String> = new <String>[];
            var mask:Array = ["xxxx", "yyyy", "zzzz", "wwww"];
            var texture:Texture;
            var i:int = 0;
            for (; i < textureCount; ++i)
            {
                texture = textures[i];
                if (!texture)
                {
                    break;
                }
                fragmentArray.push("tex ft{index}, v0, fs{index} <???>");
                fragmentArray.push("mul ft{index}, ft{index}, v1.{mask}");
                if (tinted[i])
                {
                    fragmentArray.push("mul ft{index}, ft{index}, v2");
                }
                if (i != 0)
                {
                    fragmentArray.push("add ft0, ft0, ft{index}");
                }
                var flags:String = RenderSupport.getTextureLookupFlags(texture.format, texture.mipMapping, texture.repeat, smoothing);
                for (var name:String in fragmentArray)
                {
                    var current:String = fragmentArray[name];
                    current = current.split("{index}").join(i);
                    current = current.split("{mask}").join(mask[i]);
                    current = current.split("<???>").join(flags);
                    fragmentArray[name] = current;
                }
            }
            fragmentArray.push("mov oc, ft0");
            var fragmentASM:String = fragmentArray.join("\n");
            return Starling.current.registerProgramFromSource(programName, vertexASM, fragmentASM);
        }
    }
}