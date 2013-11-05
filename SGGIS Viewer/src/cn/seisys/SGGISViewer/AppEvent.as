package cn.seisys.SGGISViewer
{
	import flash.events.Event;
	
	import cn.seisys.SGGISViewer.managers.EventBus;
	
	public class AppEvent extends Event
	{
		/**
		 * The error event type. This event type is used to send a user friendly
		 * error message via the event bus. A error window will display the error
		 * message.
		 *
		 * <p>When sending the error message, the data sent with the AppEvent is the
		 * error string. For example: </p>
		 *
		 * <listing>
		 * AppEvent.dispatch(AppEvent.APP_ERROR, "An Error Message"));
		 * </listing>
		 *
		 * @see cn.seisys.TGISViewer.components.ErrorWindow
		 */
		public static const APP_ERROR:String = "appError";
		
		/**
		 * This event type indicates that the Flex Viewer application has completed loading the
		 * configuration file. The ConfigManager sends this event so that other components that
		 * are interested in obtaining configuration data can listen to this event.
		 *
		 * @see ConfigManager
		 */
		public static const CONFIG_LOADED:String = "configLoaded";
		
		
		public function AppEvent(type:String, data:Object = null, callback:Function = null)
		{
			super(type);
			_data = data;
			_callback = callback;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		private var _data:Object;
		
		private var _callback:Function;
		
		/**
		 * The data will be passed via the event. It allows the event dispatcher to publish
		 * data to event listener(s).
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		/**
		 * The callback function associated with this event.
		 */
		public function get callback():Function
		{
			return _callback;
		}
		
		/**
		 * @private
		 */
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		
		/**
		 * Override clone
		 */
		public override function clone():Event
		{
			return new AppEvent(this.type, this.data, this.callback);
		}
		
		/**
		 * Dispatch this event.
		 */
		public function dispatch():Boolean
		{
			return EventBus.instance.dispatchEvent(this);
		}
		
		/**
		 * Dispatch an AppEvent for specified type and with optional data and callback reference.
		 */
		public static function dispatch(type:String, data:Object = null, callback:Function = null):Boolean
		{
			return EventBus.instance.dispatchEvent(new AppEvent(type, data, callback));
		}
		
		public static function addListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			EventBus.instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			EventBus.instance.removeEventListener(type, listener, useCapture);
		}
		
		public static function showError(content:String, title:String):void
		{
			var errorMessage:ErrorMessage = new ErrorMessage(content, title);
			dispatch(AppEvent.APP_ERROR, errorMessage);
		}
	}
}