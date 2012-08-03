package org.integratedsemantics.flexibleliferayair.app
{
	import com.esria.samples.dashboard.managers.PodLayoutManager;
	import com.esria.samples.dashboard.view.IPodContentBase;	
	import com.esria.samples.dashboard.view.PieChartContent;
	import com.esria.samples.dashboard.view.Pod;
	import com.esria.samples.dashboard.view.PodContentBase;
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;	
	import flash.utils.Dictionary;
	
	import flexlib.mdi.containers.MDICanvas;
	import flexlib.mdi.containers.MDIWindow;
	import flexlib.mdi.managers.MDIManager;
	
	import mx.charts.chartClasses.DataTip;	
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.Module;
	import mx.modules.ModuleManager;	
	import mx.core.IVisualElement;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.mxml.RemoteObject;	

	import org.integratedsemantics.flexibledashboard.data.RemoteObjectDataService;
	import org.integratedsemantics.flexibledashboard.data.SoapDataService;
	import org.integratedsemantics.flexibledashboard.data.XmlDataService;

	import org.integratedsemantics.flexibleliferay.login.LiferayLogin;
	import org.integratedsemantics.flexibleliferay.login.LiferayLoginEvent;
	import org.integratedsemantics.flexibleliferay.model.LiferayServerConfig;
	import org.integratedsemantics.flexibleliferay.vo.LayoutVO;
	import org.integratedsemantics.flexibleliferay.vo.PlaceVO;
	import org.integratedsemantics.flexibleliferay.vo.UserVO;
	import org.integratedsemantics.flexibleliferayair.pod.LiferayHtmlPod;

	import org.springextensions.actionscript.context.support.FlexXMLApplicationContext;
	import org.springextensions.actionscript.module.ISASModule;		
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TabBar;
	import spark.components.WindowedApplication;
	import spark.events.IndexChangeEvent;
	
	
	public class FlexibleLiferayAirAppBase extends WindowedApplication
	{
		// flexible dashboard vars
		
		[Bindable]
		public var viewStack:ViewStack;

		public var tabBar:TabBar;
		
		public var placesMenuBar:MenuBar;

		public var signInBtn:Button;
		public var signOutBtn:Button;
		public var userLabel:Label;
		
		public var placesService:RemoteObject;
		public var layoutService:RemoteObject;
		public var userService:RemoteObject;

		// states
		public static const MAIN_VIEW_STATE:String = "MainViewState";

		// Array of PodLayoutManagers
		private var podLayoutManagers:Array = new Array();
		
		// Stores the xml data keyed off of a PodLayoutManager.
		//protected var podDataDictionary:Dictionary = new Dictionary();
	
		// Stores PodLayoutManagers keyed off of a Pod.
		// Used for podLayoutManager calls after pods have been created for the first time.
		// Also, used for look-ups when saving pod content ViewStack changes.
		//protected var podHash:Object = new Object();
				
		private var _moduleConfigList:Dictionary = new Dictionary();
		private var _moduleLayoutMgrList:Dictionary = new Dictionary();
		
		private var numPodsDoneInView:Number;
		private var numPodsInView:Number;  
			
		// current tab / viewstack index
		private var viewIndex:int = 0;

		// force compiler to include these classes
		private var remoteObjectDataService:RemoteObjectDataService;
		private var soapDataService:SoapDataService;
		private var xmlDataService:XmlDataService;

		private var _applicationContext:FlexXMLApplicationContext;		

		
		// flexible liferay specific vars
		
		
		// Stores the layout keyed off of a PodLayoutManager.
		private var layoutForLayoutMgrMap:Dictionary = new Dictionary();
		
		// Stores PodLayoutManagers keyed off of a Pod.
		// Used for podLayoutManager calls after pods have been created for the first time.
		private var layoutMgrForPodMap:Object = new Object();		
		
		// liferay places layouts
        private var allLayouts:Array = new Array();

		// login dialog displayed when click sign in button
		private var loginDlg:LiferayLogin;

		// logined user
        private var userVO:UserVO;
        
        // place/group ids
        private var userGroupId:uint;
        private var guestGroupId:uint;
        
        // given groupId (group == place) get PlaceVO
        private var idToPlaceVoMap:Object = new Object();

        // liferay  places menu data
        private var rootMenuItemData:Object = new Object();
		
		private var liferayServerConfig:LiferayServerConfig;       		
				
		private var managerForPod:PodLayoutManager;
		
		
		public function FlexibleLiferayAirAppBase()
		{
			super();            
        }

        protected function onApplicationComplete():void
        {
            placesMenuBar.addEventListener(MenuEvent.ITEM_CLICK, menuHandler);
                        
			// have just menu title in my places menu until login
            rootMenuItemData.name = "My Places";
            rootMenuItemData.data = "";
            rootMenuItemData.children = new Array();   
            placesMenuBar.dataProvider = rootMenuItemData;   
                			                       
			this.currentState = MAIN_VIEW_STATE;    
			
			// spring actionscript config
			_applicationContext = new FlexXMLApplicationContext("FlexibleLiferayConfig.xml");
			_applicationContext.addEventListener(Event.COMPLETE, onLoadContextComplete);
			_applicationContext.load();                                          
        }

		private function onLoadContextComplete(event:Event):void
		{
			liferayServerConfig = _applicationContext.getObject("liferayServerConfig"); 
			
			var baseUrl:String = liferayServerConfig.portalUrl; 
			
			var channelSet:ChannelSet = new ChannelSet();
			
			// setup a channel for remoting to liferay via blazeds in liferay root
			var channelUrl:String = baseUrl + "/" + liferayServerConfig.webDir + "/messagebroker/amf";
			var channelId:String = "my-amf";
			var channel:AMFChannel = new AMFChannel(channelId, channelUrl);            
			channelSet.addChannel(channel);
			
			placesService.channelSet = channelSet;        
			layoutService.channelSet = channelSet;
			userService.channelSet = channelSet;      
		}		
		     	
		
		protected function loadPodConfig(url:String):void
		{
			// Load pod.xml, which contains the pod config.
			var httpService:HTTPService = new HTTPService();
			httpService.url = url + "/pod.xml";
			httpService.resultFormat = "e4x";
			httpService.addEventListener(FaultEvent.FAULT, onFaultHttpService);
			httpService.addEventListener(ResultEvent.RESULT, onResultHttpService);
			httpService.send();			
		}
		
		protected function onFaultHttpService(e:FaultEvent):void
		{
			Alert.show("Unable to load pod.xml.");
		}
		
		protected function onResultHttpService(e:ResultEvent):void
		{
			var podConfig:XML = e.result as XML;			
			
			// load flex module for pod
			var info:IModuleInfo = ModuleManager.getModule(podConfig.@module);
			_moduleConfigList[info] = podConfig;
			_moduleLayoutMgrList[info] = managerForPod;			
			info.addEventListener(ModuleEvent.READY, handleModuleReady);
			info.addEventListener(ModuleEvent.ERROR, handleModuleError);
			info.load(new ApplicationDomain(ApplicationDomain.currentDomain));																	
		}
		
		
		protected function onChangeTabBar(e:IndexChangeEvent):void
		{
			var index:Number = e.newIndex;
			viewIndex = index;
			
			viewStack.selectedIndex = index;
			
			// If data exists then add the pods. After the pods have been added the data is cleared.
			var podLayoutManager:PodLayoutManager = podLayoutManagers[index];
			if (layoutForLayoutMgrMap[podLayoutManager] != null)
			{
				addPods(podLayoutManagers[index]);
			}
		}
						            
        /**
         * Handle click on a My Places menu item
         * 
         * @param event menu event
         * 
         */
        protected function menuHandler(event:MenuEvent):void
        {
            var isPrivate:Boolean = event.item.isPrivate;
            var groupId:uint = event.item.groupId;
            
            layoutService.getLayouts(userVO.userId, groupId, isPrivate);
        }            

        protected function onClickSignIn(event:Event):void
        {
            loginDlg = new LiferayLogin();
            loginDlg.emailAddress = liferayServerConfig.defaultEmailAddress;
            loginDlg.password = liferayServerConfig.defaultPassword;
            PopUpManager.addPopUp(loginDlg, this, true);
            PopUpManager.centerPopUp(loginDlg);
            loginDlg.addEventListener("liferayLogin", onLogin);
        }
				
        /**
         * Login with liferay when get liferayLogin event from LiferayLogin dialog
         *  
         * @param event login event
         * 
         */
        private function onLogin(event:LiferayLoginEvent):void
        {
	        userService.login(event.emailAddress, event.password);
        }      
		
		protected function loginResult(e:ResultEvent):void
		{
			userVO = e.result as UserVO;
			
			this.signInBtn.visible = false;
			this.signInBtn.includeInLayout = false;
			this.signOutBtn.visible = true;
			this.signOutBtn.includeInLayout = true;	     
			
			userLabel.text = "Welcome " + userVO.fullName + "!";   	
			
			// get places for My Places menu
			placesService.getMyPlaces(userVO.userId);                    
		}

		protected function onClickSignOut(event:Event):void
		{
			// remove any current pages
			viewStack.removeAllChildren();
			podLayoutManagers = new Array(); 
			
			this.userLabel.text = "";
			
			// clear out my places menu
			rootMenuItemData.children = new Array();          			
			
			this.signInBtn.visible = true;
			this.signInBtn.includeInLayout = true;        		
			this.signOutBtn.visible = false;
			this.signOutBtn.includeInLayout = false;	
		}
		
		/**
		 * Populate the My Places menu with places returned from Places Service
		 * @param e result
		 * 
		 */
		protected function getPlacesResult(e:ResultEvent):void
		{            
			var places:Array = e.result as Array;
			for (var i:int = 0; i < places.length; i++)
			{
				var placeVO:PlaceVO = places[i] as PlaceVO;
				this.idToPlaceVoMap[placeVO.groupId] = placeVO;
				
				var menuItemData:Object = new Object();
				menuItemData.name = placeVO.displayName;
				menuItemData.data = placeVO;
				menuItemData.children = new Array();          
				rootMenuItemData.children.push(menuItemData);
				
				var menuItemDataPublic:Object = new Object();                
				menuItemDataPublic.name = "Public Pages (" + placeVO.publicLayoutsPageCount + ")";
				menuItemDataPublic.isPrivate = false;
				menuItemDataPublic.groupId = placeVO.groupId;
				menuItemData.children.push(menuItemDataPublic);
				
				var menuItemDataPrivate:Object = new Object();                
				menuItemDataPrivate.name = "Private Pages (" + placeVO.privateLayoutsPageCount + ")";
				menuItemDataPrivate.isPrivate = true;
				menuItemDataPrivate.groupId = placeVO.groupId;
				menuItemData.children.push(menuItemDataPrivate);
				
				// get initial public Home (guest) layout pages
				if (placeVO.displayName == "Guest")
				{
					layoutService.getLayouts(userVO.userId, placeVO.groupId, false);
					this.guestGroupId = placeVO.groupId;
				}
				else if (placeVO.isUser == true)
				{
					this.userGroupId = placeVO.groupId;
				}
			}
			
			placesMenuBar.dataProvider = rootMenuItemData;
		}
		
		/**
		 * Add tab views for layouts returned from the Layout Service
		 * @param e result event
		 * 
		 */
		protected function getLayoutsResult(e:ResultEvent):void
		{
			var layouts:Array = e.result as Array;            
			var containerWindowManagerHash:Object = new Object();
			
			// remove any current pages
			viewStack.removeAllChildren();
			podLayoutManagers = new Array(); 
			
			for (var i:Number = 0; i < layouts.length; i++) 
			{
				var layout:LayoutVO = layouts[i];
				
				// Create a canvas and mgr for each view node.
				var canvas:MDICanvas = new MDICanvas();	
				var manager:PodLayoutManager = new PodLayoutManager(canvas);
				canvas.windowManager = manager;
				
				canvas.label = layout.name;
				canvas.percentWidth = 100;
				canvas.percentHeight = 100;                             
				canvas.windowManager.tilePadding = 10;
				
				viewStack.addChild(canvas);
				
				manager.id = layout.name;
				
				// todo: should listen to other events instead that mdimgr sends, layoutchangeevent no longer sent 				
				//todo manager.addEventListener(LayoutChangeEvent.UPDATE, StateManager.setPodLayout);
				
				// Store the data. Used when view is first made visible.
				layoutForLayoutMgrMap[manager] = layout;
				podLayoutManagers.push(manager);
			}
			
			var index:Number = this.viewIndex;
			// Make sure the index is not out of range.
			// This can happen if a tab view was saved but then tabs were subsequently removed from the XML.
			index = Math.min(tabBar.numChildren - 1, index);
			onChangeTabBar(new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false, -1, index));
			tabBar.selectedIndex = index;        
		}		
		
		
		// Adds the pods / portlets to a  tab view (liferay layout)
		private function addPods(manager:PodLayoutManager):void
		{
			var layout:LayoutVO = layoutForLayoutMgrMap[manager];
			var place:PlaceVO = idToPlaceVoMap[layout.groupId];
			
			numPodsDoneInView = 0;
			numPodsInView =  layout.portletIds.length;
			
			
			for (var i:Number = 0; i < numPodsInView; i++)
			{
				var podId:String = layout.portletIds[i];

				var type:String = "web"; 
				if (layout.isPrivate == true)
				{
					if (layout.groupId == this.userGroupId)
					{
						type = "user";
					}
					else 
					{
						type = "group";
					}
				}
				
				if (podId.indexOf("flexpod") == -1)
				{
					// regular liferay portlet
					
					var pod:Pod = new Pod();
					pod.id = podId;
					pod.title = "Portlet";                                  

					var podContent:LiferayHtmlPod = new LiferayHtmlPod();						
					podContent.portalUrl = liferayServerConfig.portalUrl + "/";

					podContent.portletUrl =  podContent.portalUrl + "widget/" + type + place.friendlyUrl + layout.friendlyUrl + "/-/" + layout.portletIds[i];
					pod.addElement(podContent);
										
					manager.addItemAt(pod, -1, false);			
					layoutMgrForPodMap[pod] = manager;
					
					numPodsDoneInView++;													
				}
				else
				{
					// all flex pod 
					
					var url:String =  liferayServerConfig.portalUrl + layout.contextPaths[i];
					
					// load pod.xml from portlet webapp dir
					managerForPod = manager;
					loadPodConfig(url);                              									
				}
			}
			
			// Delete the saved data.
			delete layoutForLayoutMgrMap[manager];				
			
			if (numPodsDoneInView == numPodsInView)
			{
				// all pods complete so now the layout can be done correctly. 
				layoutAfterCreationComplete(manager);				
			}						
		}
								
		private function handleModuleReady(event:ModuleEvent):void
		{
			var info:IModuleInfo = event.module;
			
			//var podContent:IPodContentBase = info.factory.create() as IPodContentBase;					
			
			var module:ISASModule = info.factory.create() as ISASModule;
			//set the applicationContext property, inside the BasicSASModule this
			//will automatically be set as the moduleApplicationContext's parent
			module.applicationContext = _applicationContext;
			(module as Module).data = info;		
			var podContent:IPodContentBase = module as IPodContentBase;								
			
			var podConfig:XML = _moduleConfigList[info] as XML;
			var manager:PodLayoutManager = _moduleLayoutMgrList[info];			
			cleanupInfo(info);
			
			var viewId:String = manager.id;
			var podId:String = podConfig.@id;
			
			podContent.properties = podConfig;
			var pod:Pod = new Pod();
			pod.id = podId;
			pod.title = podConfig.@title;
			
			podContent.pod = pod;
			podContent.podManager = manager;
			
			pod.addElement(podContent);
			
			manager.addItemAt(pod, -1, false);						
			
			layoutMgrForPodMap[pod] = manager;		
			
			numPodsDoneInView++;
			if (numPodsDoneInView == numPodsInView)
			{
				// all pods complete so now the layout can be done correctly. 
				layoutAfterCreationComplete(manager);				
			}						
		}
		
		private function handleModuleError(event:ModuleEvent):void
		{
			Alert.show(event.errorText);
		}
		
		private function cleanupInfo(info:IModuleInfo):void 
		{
			delete _moduleConfigList[info];
			delete _moduleLayoutMgrList[info];
			info.removeEventListener(ModuleEvent.READY, handleModuleReady);
			info.removeEventListener(ModuleEvent.ERROR, handleModuleError);
		}		
		
		// Pod has been created so update the respective PodLayoutManager.
		private function layoutAfterCreationComplete(manager:PodLayoutManager):void
		{
			manager.removeNullItems();
			manager.tile(false, 10);
			manager.updateLayout(false);			
		}	
		
		// mdi
		protected function tile():void
		{
			var index:int = viewStack.selectedIndex;
			var mgr:PodLayoutManager = podLayoutManagers[index];
			if (mgr != null)
			{
				mgr.tile(false, 10);  
			}
		}
		
		// mdi
		protected function cascade():void
		{
			var index:int = viewStack.selectedIndex;
			var mgr:PodLayoutManager = podLayoutManagers[index];
			if (mgr != null)
			{
				mgr.cascade();
			}
		}		
		
	}
	
}
