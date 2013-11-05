package cn.seisys.SGGISViewer.managers
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="configLoaded", type="cn.seisys.SGGISViewer.AppEvent")]
	
	public class ConfigManager extends EventDispatcher
	{
		public function ConfigManager(target:IEventDispatcher=null)
		{
			
		}
	}
}