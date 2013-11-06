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
	import cn.seisys.SGGISViewer.utils.LocalizationUtil;
	
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
			
			var i:int;
			var j:int;
			
			//================================================
			//Style configuration
			//================================================
			var styleAlpha:String = (XMLList(configXML.style.alpha).length() > 0) ? configXML.style.alpha : configXML.stylealpha;
			if (styleAlpha)
			{
				configData.styleAlpha = Number(styleAlpha);
			}
			
			var styleColors:Array = String(configXML.style.colors).split(",");
			if (styleColors.length == 1) // if style.colors are not specified, then check for stylecolors for backwards compatibility with version 2.1
			{
				styleColors = String(configXML.stylecolors).split(",");
			}
			
			var colorStr:String = "";
			for each (colorStr in styleColors)
			{
				configData.styleColors.push(uint(colorStr));
			}
			
			var applicationBackgroundAlpha:uint = configXML.style.applicationbackgroundalpha || 1;
			configData.applicationBackgroundAlpha = applicationBackgroundAlpha;
			
			var styleFontName:String = configXML.style.font.@name;
			var styleFontSize:String = configXML.style.font.@size;
			var font:Object =
				{
					id: "font",
					name: styleFontName,
					size: int(styleFontSize)
				};
			configData.font = font;
			
			var styleTitleFontName:String = configXML.style.titlefont.@name;
			var styleTitleFontSize:String = configXML.style.titlefont.@size;
			var titleFont:Object =
				{
					id: "titleFont",
					name: styleTitleFontName,
					size: int(styleTitleFontSize)
				};
			configData.titleFont = titleFont;
			
			var styleSubTitleFontName:String = configXML.style.subtitlefont.@name;
			var styleSubTitleFontSize:String = configXML.style.subtitlefont.@size;
			var subTitleFont:Object =
				{
					id: "subTitleFont",
					name: styleSubTitleFontName,
					size: int(styleSubTitleFontSize)
				};
			configData.subTitleFont = subTitleFont;
			
			//================================================
			//layoutDirection configuration
			//================================================
			var layoutDirection:String = configXML.layoutdirection;
			if (layoutDirection)
			{
				configData.layoutDirection = layoutDirection;
			}
			
			//================================================
			//user interface
			//================================================
			var configUI:Array = [];
			var value:String = configXML.title[0];
			var title:Object =
				{
					id: "title",
					value: value
				};
			configUI.push(title);
			
			value = configXML.subtitle[0];
			var subtitle:Object =
				{
					id: "subtitle",
					value: value
				};
			configUI.push(subtitle);
			
			value = configXML.logo[0];
			var logo:Object =
				{
					id: "logo",
					value: value
				};
			configUI.push(logo);
			
			value = configXML.splashpage.@url;
			if (value)
			{
				var splashConfig:String = configXML.splashpage.@config;
				var splashConfigXML:XML = null;
				if (splashConfig.charAt(0) === "#")
				{
					splashConfigXML = configXML.configuration.(@id == splashConfig.substr(1))[0];
				}
				var splashTitle:String = configXML.splashpage.@label;
				var splashPage:Object =
					{
						id: "splashpage",
						value: value,
						config: splashConfig,
						configXML: splashConfigXML,
						title: splashTitle
					};
				configUI.push(splashPage);
			}
			
			var wleft:String = configXML.widgetcontainer.@left;
			var wright:String = configXML.widgetcontainer.@right;
			var wtop:String = configXML.widgetcontainer.@top;
			var wbottom:String = configXML.widgetcontainer.@bottom;
			var wlayout:String = configXML.widgetcontainer.@layout;
			if (!wlayout)
			{
				wlayout = "horizontal";
			}
			
			if (wleft || wright || wtop || wbottom || wlayout)
			{
				var widgetContainer:Object =
					{
						id: "widgetcontainer",
						left: wleft,
						right: wright,
						top: wtop,
						bottom: wbottom,
						layout: wlayout
					};
				configUI.push(widgetContainer);
			}
			
			configData.viewerUI = configUI;
			
			//================================================
			//controls
			//================================================
			var configControls:Array = [];
			var controlList:XMLList = configXML.widget;
			var controlIdWeight:Number = 1000;
			for (i = 0; i < controlList.length(); i++)
			{
				var controlIcon:String = controlList[i].@icon;
				var controlLabel:String = controlList[i].@label;
				var controlLeft:String = controlList[i].@left;
				var controlRight:String = controlList[i].@right;
				var controlTop:String = controlList[i].@top;
				var controlBottom:String = controlList[i].@bottom;
				var controlHorizontalCenter:String = controlList[i].@horizontalcenter;
				var controlVerticalCenter:String = controlList[i].@verticalcenter;
				var controlVisible:String = controlList[i].@visible;
				var controlConfig:String = controlList[i].@config;
				var controlUrl:String = controlList[i].@url;
				
				var controlConfigXML:XML = null;
				if (controlConfig.charAt(0) === "#")
				{
					controlConfigXML = configXML.configuration.(@id == controlConfig.substr(1))[0];
				}
				
				var control:Object =
					{
						id: controlIdWeight + i,
							icon: controlIcon,
							label: controlLabel,
							left: controlLeft,
							right: controlRight,
							top: controlTop,
							bottom: controlBottom,
							horizontalCenter: controlHorizontalCenter,
							verticalCenter: controlVerticalCenter,
							visible: controlVisible,
							config: controlConfig,
							configXML: controlConfigXML,
							url: controlUrl
					};
				configControls.push(control);
			}
			configData.controls = configControls;
			
			//=================================================
			//widgets
			//================================================
			var configWidgets:Array = [];
			var widgetContainerList:XMLList = configXML.widgetcontainer;
			var widgetId:Number = 0;
			for (var w:int = 0; w < widgetContainerList.length(); w++)
			{
				var wContainer:XML = widgetContainerList[w] as XML;
				var isPartOfPanel:Boolean = wContainer.@paneltype[0] ? true : false;
				for (i = 0; i < wContainer.children().length(); i++)
				{
					var xmlObject:XML = wContainer.children()[i];
					if (xmlObject.name() == "widgetgroup")
					{
						var widgetGroupList:XMLList = XMLList(xmlObject);
						createWidgets(widgetGroupList.widget, true, isPartOfPanel, widgetGroupList.widget.length(), widgetGroupList.@label, widgetGroupList.@icon);
					}
					else
					{
						var widgetList:XMLList = XMLList(xmlObject);
						createWidgets(widgetList, false, isPartOfPanel);
					}
				}
			}
			
			function createWidgets(widgetList:XMLList, grouped:Boolean, isPartOfPanel:Boolean, groupLength:Number = 0, groupLabel:String = null, groupIcon:String = null):void
			{
				var widgetListLength:int = widgetList.length();
				for (var p:int = 0; p < widgetListLength; p++)
				{
					// if grouped
					var wGrouped:Boolean = grouped;
					var wGroupLength:Number = groupLength;
					var wGroupIcon:String = groupIcon;
					var wGroupLabel:String = groupLabel;
					
					var wLabel:String = widgetList[p].@label;
					var wIcon:String = widgetList[p].@icon;
					var wConfig:String = widgetList[p].@config;
					var wPreload:String = widgetList[p].@preload;
					var wWidth:String = widgetList[p].@width;
					var wHeight:String = widgetList[p].@height;
					var wUrl:String = widgetList[p].@url;
					var wx:String = widgetList[p].@x;
					var wy:String = widgetList[p].@y;
					var wLeft:String = widgetList[p].@left;
					var wTop:String = widgetList[p].@top;
					var wRight:String = widgetList[p].@right;
					var wBottom:String = widgetList[p].@bottom;
					
					// Look for embedded configuration
					var wConfigXML:XML = null;
					if (wConfig.charAt(0) === "#")
					{
						wConfigXML = configXML.configuration.(@id == wConfig.substr(1))[0];
					}
					if (!wGroupIcon)
					{
						wGroupIcon = ViewerContainer.DEFAULT_WIDGET_GROUP_ICON;
					}
					if (!wIcon)
					{
						wIcon = ViewerContainer.DEFAULT_WIDGET_ICON;
					}
					
					var widget:Object =
						{
							id: widgetId,
							grouped: wGrouped,
							groupLength: wGroupLength,
							groupIcon: wGroupIcon,
							groupLabel: wGroupLabel,
							label: wLabel,
							icon: wIcon,
							config: wConfig,
							configXML: wConfigXML, // reference to embedded XML configuration (if any)
							preload: wPreload,
							width: wWidth,
							height: wHeight,
							x: wx,
							y: wy,
							left: wLeft,
							top: wTop,
							right: wRight,
							bottom: wBottom,
							url: wUrl,
							isPartOfPanel: isPartOfPanel
						};
					configWidgets.push(widget);
					widgetId++;
				}
			}
			configData.widgets = configWidgets;
			
			//=================================================
			//widgetContainers
			//   [] ={container, widgets}
			//================================================
			
			var wContainers:XMLList = configXML.widgetcontainer;
			var configWContainers:Array = [];
			var wid:uint;
			var n:int;
			var xmlObj:XML;
			for (i = 0; i < wContainers.length(); i++)
			{
				//get container parameters
				var wcPanelType:String = wContainers[i].@paneltype;
				
				var wgContainer:Object;
				var contWidgets:Array = [];
				if (wcPanelType)
				{
					var wcSize:String = wContainers[i].@size;
					var wcInitialState:String = "open";
					if (wContainers[i].@initialstate[0])
					{
						wcInitialState = wContainers[i].@initialstate;
					}
					wgContainer =
						{
							id: i,
							panelType: wcPanelType,
							initialState: wcInitialState,
							size: wcSize,
							obj: null
						};
					
					//get widget for this container
					wid = 0;
					for (n = 0; n < wContainers[i].children().length(); n++)
					{
						xmlObj = wContainers[i].children()[n];
						
						var wgLabel:String = xmlObj.@label;
						var wgConfig:String = xmlObj.@config;
						var wgWidth:String = xmlObj.@width;
						var wgHeight:String = xmlObj.@height;
						var wgUrl:String = xmlObj.@url;
						
						var wgConfigXML:XML = null;
						if (wgConfig.charAt(0) === "#")
						{
							wgConfigXML = configXML.configuration.(@id == wgConfig.substr(1))[0];
						}
						var wg:Object =
							{
								id: wid,
								label: wgLabel,
								config: wgConfig,
								configXML: wgConfigXML, // reference to embedded XML configuration (if any)
								width: wgWidth,
								height: wgHeight,
								url: wgUrl,
								isPartOfPanel: true
							};
						contWidgets.push(wg);
						
						//indexing
						var windex:Object = { container: i, widget: wid };
						configData.widgetIndex.push(windex);
						wid++;
					}
				}
				else
				{
					var wcUrl:String = wContainers[i].@url;
					if (!wcUrl)
					{
						wcUrl = ViewerContainer.DEFAULT_WIDGET_CONTAINER_WIDGET;
					}
					
					var wcLeft:String = wContainers[i].@left;
					var wcRight:String = wContainers[i].@right;
					var wcTop:String = wContainers[i].@top;
					var wcBottom:String = wContainers[i].@bottom;
					var wcLayout:String = wContainers[i].@layout;
					
					if (!wcLayout)
					{
						wcLayout = ViewerContainer.DEFAULT_WIDGET_LAYOUT;
					}
					
					wgContainer =
						{
							id: i,
							left: wcLeft,
							right: wcRight,
							top: wcTop,
							bottom: wcBottom,
							layout: wcLayout,
							url: wcUrl,
							obj: null
						};
					
					//get widgets for this container
					wid = 0;
					for (n = 0; n < wContainers[i].children().length(); n++)
					{
						xmlObj = wContainers[i].children()[n];
						if (xmlObj.name() == "widgetgroup")
						{
							var widgetGrpList:XMLList = XMLList(xmlObj);
							getWidgetList(widgetGrpList.widget, true, widgetGrpList.widget.length(), widgetGrpList.@label, widgetGrpList.@icon);
						}
						else
						{
							var wdgtList:XMLList = XMLList(xmlObj);
							getWidgetList(wdgtList, false);
						}
					}
					
					function getWidgetList(wgList:XMLList, grouped:Boolean, groupLength:Number = 0, groupLabel:String = null, groupIcon:String = null):void
					{
						for (j = 0; j < wgList.length(); j++)
						{
							// if grouped
							var wgGrouped:Boolean = grouped;
							var wgGroupLength:Number = groupLength;
							var wgGroupIcon:String = groupIcon;
							var wgGroupLabel:String = groupLabel;
							
							var wgLabel:String = wgList[j].@label;
							var wgIcon:String = wgList[j].@icon;
							var wgConfig:String = wgList[j].@config;
							var wgPreload:String = wgList[j].@preload;
							var wgWidth:String = wgList[j].@width;
							var wgHeight:String = wgList[j].@height;
							var wgUrl:String = wgList[j].@url;
							var wgx:String = wgList[j].@x;
							var wgy:String = wgList[j].@y;
							var wgLeft:String = wgList[j].@left;
							var wgTop:String = wgList[j].@top;
							var wgRight:String = wgList[j].@right;
							var wgBottom:String = wgList[j].@bottom;
							var wHorizontalCenter:String = wgList[j].@horizontalcenter;
							var wVerticalCenter:String = wgList[j].@verticalcenter;
							
							var wgConfigXML:XML = null;
							if (wgConfig.charAt(0) === "#")
							{
								wgConfigXML = configXML.configuration.(@id == wgConfig.substr(1))[0];
							}
							if (!wgGroupIcon)
							{
								wgGroupIcon = ViewerContainer.DEFAULT_WIDGET_GROUP_ICON;
							}
							if (!wgIcon)
							{
								wgIcon = ViewerContainer.DEFAULT_WIDGET_ICON;
							}
							
							var wg:Object =
								{
									id: wid,
									grouped: wgGrouped,
									groupLength: wgGroupLength,
									groupIcon: wgGroupIcon,
									groupLabel: wgGroupLabel,
									label: wgLabel,
									icon: wgIcon,
									config: wgConfig,
									configXML: wgConfigXML, // reference to embedded XML configuration (if any)
									preload: wgPreload,
									width: wgWidth,
									height: wgHeight,
									x: wgx,
									y: wgy,
									left: wgLeft,
									right: wgRight,
									top: wgTop,
									bottom: wgBottom,
									horizontalCenter: wHorizontalCenter,
									verticalCenter: wVerticalCenter,
									url: wgUrl,
									isPartOfPanel: false
								};
							contWidgets.push(wg);
							
							//indexing
							var windex:Object = { container: i, widget: wid };
							configData.widgetIndex.push(windex);
							wid++;
						}
					}
				}
				
				var container:Object = { container: wgContainer, widgets: contWidgets };
				configWContainers.push(container);
			}
			configData.widgetContainers = configWContainers;
			
			var serverIp:String = configXML.serverip;
			if ( serverIp )
			{
				configData.serverIp = serverIp;
			}
			
			var baseServiceUrl:String = configXML.services.baseservice;
			baseServiceUrl = baseServiceUrl.replace( "{serverip}", serverIp );
			var featureServiceUrl:String = configXML.services.featureservice;
			featureServiceUrl = featureServiceUrl.replace( "{serverip}", serverIp );
			var mapServiceUrl:String = configXML.services.mapservice;
			mapServiceUrl = mapServiceUrl.replace( "{serverip}", serverIp );
			var queryServiceUrl:String = configXML.services.queryservice;
			queryServiceUrl = queryServiceUrl.replace( "{serverip}", serverIp );
			var spatialAnalysisServiceUrl:String = configXML.services.spatialanalysisservice;
			spatialAnalysisServiceUrl = spatialAnalysisServiceUrl.replace( "{serverip}", serverIp );
			var thematicMapServiceUrl:String = configXML.services.thematicmapservice;
			thematicMapServiceUrl = thematicMapServiceUrl.replace( "{serverip}", serverIp );
			var tileMapServiceUrl:String = configXML.services.tilemapservice;
			tileMapServiceUrl = tileMapServiceUrl.replace( "{serverip}", serverIp );
			var topoAnalysisServiceUrl:String = configXML.services.topoanalysisservice;
			topoAnalysisServiceUrl = topoAnalysisServiceUrl.replace( "{serverip}", serverIp );
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
			
			var userName:String = configXML.username;
			var password:String = configXML.password;
			configData.userName = userName;
			configData.password = password;
			
			AppEvent.dispatch(AppEvent.CONFIG_LOADED, configData);
		}
	}
}