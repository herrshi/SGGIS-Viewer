package cn.seisys.SGGISViewer
{
	public class ConfigData
	{
		public var serverIp:String;
		public var mapServices:Object;
		public var viewerUI:Array;
		public var styleColors:Array;
		public var styleAlpha:Number;
		public var applicationBackgroundAlpha:uint;
		public var font:Object;
		public var titleFont:Object;
		public var subTitleFont:Object;
		public var layoutDirection:String;
		
		public var userName:String;
		public var password:String;
		
		public var controls:Array;
		public var widgetContainers:Array;
		public var widgets:Array;
		public var widgetIndex:Array;
		
		public function ConfigData()
		{
			viewerUI = [];
			styleColors = [];
			styleAlpha = 0.8;
			controls = [];
			widgets = [];
			widgetContainers = []; //[i]={container, widgets]
			widgetIndex = []; //[i]={container, inx}
		}
	}
}