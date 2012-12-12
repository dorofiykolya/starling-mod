package 
{
    import flash.display.Sprite;
    import flash.system.Capabilities;
    
    import starling.core.Starling;
    import starling.events.Event;
    import starling.textures.Texture;
    
    import utils.AssetManager;
    
    // If you set this class as your 'default application', it will run without a preloader.
    // To use a preloader, see 'Preloader.as'.
    
    [SWF(width="320", height="480", frameRate="60", backgroundColor="#222222")]
    public class Startup_Web extends Sprite
    {
        [Embed(source = "../../demo/system/startup.jpg")]
        private var Background:Class;
        
        private var mStarling:Starling;
        
        public function Startup_Web()
        {
            if (stage) start();
            else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function start():void
        {
            var isMac:Boolean = Capabilities.manufacturer.indexOf("Macintosh") != -1;
            
            Starling.multitouchEnabled = true;   // useful on mobile devices
            Starling.handleLostContext = !isMac; // required on Windows, needs more memory
            
            mStarling = new Starling(Game, stage);
            mStarling.simulateMultitouch = true;
            mStarling.enableErrorChecking = Capabilities.isDebugger;
            mStarling.start();
            
            // this event is dispatched when stage3D is set up
            mStarling.addEventListener(Event.ROOT_CREATED, onRootCreated);
        }
        
        private function onAddedToStage(event:Object):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            start();
        }
        
        private function onRootCreated(event:Event, game:Game):void
        {
            // set framerate to 30 in software mode
            if (mStarling.context.driverInfo.toLowerCase().indexOf("software") != -1)
                mStarling.nativeStage.frameRate = 30;
            
            // define which resources to load
            var assets:AssetManager = new AssetManager();
            assets.verbose = Capabilities.isDebugger;
            assets.enqueue(EmbeddedAssets);
            
            // background texture is embedded, because we need it right away!
            var bgTexture:Texture = Texture.fromBitmap(new Background());
            
            // game will first load resources, then start menu
            game.start(bgTexture, assets);
        }
    }
}