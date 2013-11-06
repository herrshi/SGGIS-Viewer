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
		
		/**
		 * For widget chain and data manager to manage the session generated data.
		 */
		public static const DATA_PUBLISH:String = "dataPublishing";
		
		/**
		 * For widget chain. TBD
		 */
		public static const DATA_NEW_PUBLISHED:String = "dataPublished";
		
		/**
		 * for widget chain. TBD
		 */
		public static const DATA_FETCH_ALL:String = "dataFetchAll";
		
		public static const DATA_FETCH:String = "dataFetch";
		
		public static const DATA_SENT:String = "dataFetched";
		
		public static const DATA_OPT_LAYERS:String = "dataOperationalLayers";
		
		public static const DATA_CREATE_INFOWIDGET:String = "createInfoWidget";
		
		/**
		 * This event type is used by the Controller to indicate a widget run request
		 */
		public static const WIDGET_RUN:String = "widgetRunRequested";
		
		/**
		 * used to send message to widget to change its state such as close, min and max
		 * var data:Object {
		 *    id: widgetId, //as Number
		 *    state: stateString //as String
		 * }
		 * AppEvent.publish(AppEvent.WIDGET_CHANGE_STATE, data);
		 */
		public static const WIDGET_CHANGE_STATE:String = "widgetChangeState";
		
		public static const WIDGET_STATE_CHANGED:String = "widgetStateChanged";
		
		/**
		 * for widget layout
		 */
		public static const WIDGET_FOCUS:String = "focusWidget";
		
		public static const WIDGET_CHAIN_NEXT:String = "widgetChainNextRequested";
		
		public static const WIDGET_CHAIN_START:String = "widgetChainStartRequested"
		
		public static const WIDGET_MGR_RESIZE:String = "widgetManagerResize";
		
		public static const WIDGET_ADD:String = "addWidget";
		
		public static const WIDGET_ADDED:String = "widgetAdded";
		
		public static const WIDGET_CLOSE:String = "closeWidget";
		
		public static const INFOWIDGET_REQUEST:String = "requestInfoWidget";
		
		public static const INFOWIDGET_READY:String = "infoWidgetReady";
		
		/**
		 * Builder events.
		 */
		public static const SET_TITLES:String = 'setTitles';
		
		public static const SET_LOGO:String = 'setLogo';
		
		public static const SET_TITLE_COLOR:String = 'setTitleColor';
		
		public static const SET_TEXT_COLOR:String = 'setTextColor';
		
		public static const SET_BACKGROUND_COLOR:String = 'setBackgroundColor';
		
		public static const SET_ROLLOVER_COLOR:String = 'setRolloverColor';
		
		public static const SET_SELECTION_COLOR:String = 'setSelectionColor';
		
		public static const SET_APPLICATION_BACKGROUND_COLOR:String = 'setApplicationBackgroundColor';
		
		public static const SET_ALPHA:String = 'setAlpha';
		
		public static const SET_FONT_NAME:String = 'setFontName';
		
		public static const SET_APP_TITLE_FONT_NAME:String = 'setAppTitleFontName';
		
		public static const SET_SUB_TITLE_FONT_NAME:String = 'setSubTitleFontName';
		
		public static const SET_PREDEFINED_STYLES:String = 'setPredefinedStyles';
		
		
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