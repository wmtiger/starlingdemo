package game
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	import theme.MetalWorksMobileTheme;
	
	public class Game extends Sprite
	{
		protected var _cameraUI:CameraUI;
		private var imageLoader:Loader; 
		private var _tf:TextField;
		private var ldr:ImageLoader;
		
		public function Game()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * The Feathers Button control that we'll be creating.
		 */
		protected var button:Button;
		
		/**
		 * Where the magic happens. Start after the main class has been added
		 * to the stage so that we can access the stage property.
		 */
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			new MetalWorksMobileTheme();
			
			this.button = new Button();
			this.button.label = "Click Me";
			
			this.button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
			
			this.addChild(this.button);
			
			this.button.validate();
			
			this.button.x = (this.stage.stageWidth - this.button.width) / 2;
			this.button.y = (this.stage.stageHeight - this.button.height) / 2;
			
			_tf = new TextField(400,500,'','宋体',14);
			this.addChild(_tf);
			_tf.autoSize = 'bothDirections';
		}
		
		/**
		 * Listener for the Button's Event.TRIGGERED event.
		 */
		protected function button_triggeredHandler(event:Event):void
		{
//			const label:Label = new Label();
//			label.text = "Hi, I'm Feathers!\nHave a nice day.";
//			Callout.show(label, this.button);
			
//			initCamera();
//			initCameraUI();
			navigateToURL(new URLRequest('wx:18158138828'));
		}
		
		private var _cam:Camera;
		private var _v:Video;
		private var _img:Bitmap;
		private var _timer:Timer;
		
		private function initCamera():void
		{
			_img = new Bitmap();
			
			_cam = Camera.getCamera();
			log('Camera.names'+Camera.names);
			if(_cam)
			{
				_v = new Video(640,480);
//				_v.width = _cam.width;
//				_v.height = _cam.height; 
//				log('_cam.width, _cam.height',_cam.width, _cam.height);
				//				_v.attachCamera(_cam);
				//				addChild(_v);    
				
				_cam.setMode(_v.width,_v.height,30);
				_cam.setQuality(0, 0);
				_v.attachCamera(_cam);
				var nativeStage:flash.display.Sprite = Starling.current.nativeOverlay;
				nativeStage.addChild(_v);
				_v.x = 320;
				var s:flash.display.Shape = new Shape();
				s.graphics.beginFill(0xffff99,0);
				s.graphics.lineStyle(1,0xffffff);
				s.graphics.drawRect(220,140,200,200);
				s.graphics.endFill();
				nativeStage.addChild(s);
				s.x = _v.x;
				
				_timer = new Timer(5000);
				_timer.addEventListener(TimerEvent.TIMER, onTimerOk);
				_timer.start();
			}
			else
			{
				log('_cam is null');
			}
			
		}
		
		private function onTimerOk(e:TimerEvent):void
		{
			_timer.stop();
			log('onTimerOk');
			saveBmd();
		}
		
		private function saveBmd():void
		{
			var bmd:BitmapData = new BitmapData(_v.width,_v.height);
			bmd.draw(_v);
			var bmd2:BitmapData = new BitmapData(200,200);
			bmd2.copyPixels(bmd,new Rectangle(220,140,200,200),new Point());
			_v.clear();
			_v.attachCamera(null);
			log('numchildren:',Starling.current.nativeOverlay.numChildren);
			while(Starling.current.nativeOverlay.numChildren>0)
			{
				Starling.current.nativeOverlay.removeChildAt(0);
			}
			_cam = null;
			_v = null;
			var img:Image = new Image(Texture.fromBitmapData(bmd));
			this.addChild( img);
			img.y = 360;
			log('saveBmd over');
			log('result:'+ QRcoder.getStringCode(bmd2));
		}
		
		private function initCameraUI():void
		{
			if( CameraUI.isSupported )
			{
				log( "Initializing camera..." );
				_cameraUI = new CameraUI();
				_cameraUI.addEventListener( MediaEvent.COMPLETE, imageCaptured );
				_cameraUI.addEventListener( Event.CANCEL, captureCanceled );
				_cameraUI.addEventListener( ErrorEvent.ERROR, cameraError );
				_cameraUI.launch( MediaType.IMAGE );
			}
			else
			{
				log( "Camera interface is not supported.");
			}
		}
		
		private function imageCaptured( event:MediaEvent ):void
		{
			log( "Media captured...");
//			var bmd:BitmapData = stage.drawToBitmapData();
//			this.addChild(new Image(Texture.fromBitmapData(bmd)));
			var imagePromise:MediaPromise = event.data;
			log( "Media captured..." + imagePromise.file+','+imagePromise.isAsync );
			if( imagePromise.isAsync)
			{
				log( "Asynchronous media promise.");
				imageLoader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, asyncImageLoaded );
				imageLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, cameraError );
				imageLoader.contentLoaderInfo.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncError);
				imageLoader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR,securityErr);
				
				imageLoader.loadFilePromise( imagePromise );
			}
			else
			{
				log( "Synchronous media promise." );
				imageLoader.loadFilePromise( imagePromise );
				showMedia( imageLoader );
			}
		}
		
		protected function securityErr(event:SecurityErrorEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function asyncError(event:AsyncErrorEvent):void
		{
			log( "asyncError" );
		}
		
		private function captureCanceled( event:flash.events.Event ):void
		{
			log( "Media capture canceled." );
//			NativeApplication.nativeApplication.exit();
		}
		
		private function asyncImageLoaded( event:flash.events.Event ):void
		{
			log( "Media loaded in memory." );
			showMedia( imageLoader );    
		}
		
		private function showMedia( loader:Loader ):void
		{
			log( "showMedia." );
//			log( "showMedia."+','+Starling.current.viewPort.width+','+Starling.current.viewPort.height+','+Constant.scale );
			var bmd:BitmapData = new BitmapData(loader.contentLoaderInfo.content.width/2, loader.contentLoaderInfo.content.height/2);
			bmd.draw(loader.contentLoaderInfo.content,new Matrix(0.5,0,0,0.5));
			var img:Image = new Image(Texture.fromBitmapData(bmd));
			this.addChild( img);
			img.scaleX = img.scaleY = 1.6;
			
//			Starling.current.nativeOverlay.addChild(loader.contentLoaderInfo.content);
		}
		
		private function cameraError( error:ErrorEvent ):void
		{
			log( "Error:" + error.text );
//			NativeApplication.nativeApplication.exit();
		}
		
		private function log(...args):void
		{
			var t:String = _tf.text + '\n' + args;
			_tf.text = t;
		}
	}
}