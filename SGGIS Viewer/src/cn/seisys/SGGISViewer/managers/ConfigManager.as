package cn.seisys.SGGISViewer.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import cn.seisys.SGGISViewer.AppEvent;
	import cn.seisys.SGGISViewer.ConfigData;
	import cn.seisys.SGGISViewer.ViewerContainer;
	import cn.seisys.SGGISViewer.util.LocalizationUtil;
	
	[Event(name="configLoaded", type="cn.seisys.SGGISViewer.AppEvent")]
	
	public class ConfigManager extends EventDispatcher
	{
		public function ConfigManager()
		{
			AppEvent.addListener(ViewerContainer.CONTAINER_INITIALIZED, containerInitializedHandler);
		}
		
		private function containerInitializedHandler(event:Event):void
		{
			loadConfig();
		}
		
		private function loadConfig():void
		{
			var configService:HTTPService = new HTTPService();
			configService.url = ViewerContainer.configFile;
			configService.resultFormat = HTTPService.RESULT_FORMAT_TEXT;
			configService.addEventListener(ResultEvent.RESULT, configService_resultHandler);
			configService.addEventListener(FaultEvent.FAULT, configService_faultHandler);
			configService.send();
		}
		
		private function configService_faultHandler(event:FaultEvent):void
		{
			var sInfo:String = "";
			
			if (event.fault.rootCause is IOErrorEvent)
			{
				var ioe:IOErrorEvent = event.fault.rootCause as IOErrorEvent;
				// Missing config file
				if (ioe.errorID == 2032)
				{
					sInfo += LocalizationUtil.getDefaultString('missingConfigFileText', ViewerContainer.configFile) + "\n\n";
				}
				else
				{
					// some other IOError
					sInfo += event.fault.rootCause + "\n\n";
				}
			}
			
			if (event.fault.rootCause is SecurityErrorEvent)
			{
				var sec:SecurityErrorEvent = event.fault.rootCause as SecurityErrorEvent;
				// config file with crossdomain issue
				if (sec.errorID == 2048)
				{
					sInfo += LocalizationUtil.getDefaultString('configFileCrossDomain', "\n", sec.toString()) + "\n\n";
				}
					// some other Security error
				else
				{
					sInfo += event.fault.rootCause + "\n\n";
				}
			}
			
			if (event.statusCode) // e.g. 404 - Not Found - http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
			{
				sInfo += LocalizationUtil.getDefaultString('httpResponseStatus', event.statusCode) + "\n\n";
			}
			
			sInfo += LocalizationUtil.getDefaultString('faultCode', event.fault.faultCode) + "\n\n";
			sInfo += LocalizationUtil.getDefaultString('faultInfo', event.fault.faultString) + "\n\n";
			sInfo += LocalizationUtil.getDefaultString('faultDetail', event.fault.faultDetail);
			
			AppEvent.showError(sInfo, "ConfigManager");
		}
		
		private var configData:ConfigData;
		
		private function configService_resultHandler(event:ResultEvent):void
		{
			configData = new ConfigData();
			var configXML:XML = XML(event.result);
			
			var serverIp:String = configXML.serverip;
			if ( serverIp )
			{
				configData.serverIp = serverIp;
			}
			
			var baseServiceUrl:String = configXML.services.baseservice;
			var featureServiceUrl:String = configXML.services.featureservice;
			var mapServiceUrl:String = configXML.services.mapservice;
			var queryServiceUrl:String = configXML.services.queryservice;
			var spatialAnalysisServiceUrl:String = configXML.services.spatialanalysisservice;
			var thematicMapServiceUrl:String = configXML.services.thematicmapservice;
			var tileMapServiceUrl:String = configXML.services.tilemapservice;
			var topoAnalysisServiceUrl:String = configXML.services.topoanalysisservice;
			var mapServices:Object = 
				{ 
					baseServiceUrl: baseServiceUrl,
					featureServiceUrl: featureServiceUrl,
					mapServiceUrl: mapServiceUrl,
					queryServiceUrl: queryServiceUrl,
					spatialAnalysisServiceUrl: spatialAnalysisServiceUrl,
					thematicMapServiceUrl: thematicMapServiceUrl,
					tileMapServiceUrl: tileMapServiceUrl,
					topoAnalysisServiceUrl: topoAnalysisServiceUrl
				};
			configData.mapServices = mapServices;
			trace( baseServiceUrl );
			
			AppEvent.dispatch(AppEvent.CONFIG_LOADED, configData);
		}
	}
}