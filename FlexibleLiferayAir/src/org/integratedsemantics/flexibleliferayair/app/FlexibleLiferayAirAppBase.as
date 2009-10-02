package org.integratedsemantics.flexibleliferayair.app
{
	import com.esria.samples.dashboard.events.LayoutChangeEvent;
	import com.esria.samples.dashboard.managers.PodLayoutManager;
	import com.esria.samples.dashboard.managers.StateManager;
	import com.esria.samples.dashboard.view.Pod;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import flexlib.mdi.containers.MDICanvas;
	
	import mx.containers.ViewStack;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.MenuBar;
	import mx.controls.TabBar;
	import mx.core.WindowedApplication;
	import mx.events.IndexChangedEvent;
	import mx.events.ItemClickEvent;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	import org.integratedsemantics.flexibledashboardair.liferay.LiferayHtmlPod;
	import org.integratedsemantics.flexibleliferay.login.LiferayLogin;
	import org.integratedsemantics.flexibleliferay.login.LiferayLoginEvent;
	import org.integratedsemantics.flexibleliferay.model.LiferayServerConfig;
	import org.integratedsemantics.flexibleliferay.vo.LayoutVO;
	import org.integratedsemantics.flexibleliferay.vo.PlaceVO;
	import org.integratedsemantics.flexibleliferay.vo.UserVO;
	import org.springextensions.actionscript.context.support.FlexXMLApplicationContext;


	public class FlexibleLiferayAirAppBase extends WindowedApplication
	{
		public var modeViewStack:ViewStack;
		
		public var viewStack:ViewStack;
		public var tabBar:TabBar;
		
		public var placesMenuBar:MenuBar;
		public var userLabel:Label;
		public var signInBtn:Button;
		public var signOutBtn:Button;

		public var login:LiferayLogin;
		
        // for spring actionscript config
        public var applicationContext:FlexXMLApplicationContext;

        // view modes
        public static const MAIN_VIEW_MODE_INDEX:int = 0;

		// Array of PodLayoutManagers
		protected var podLayoutManagers:Array = new Array();
		
		// Stores the xml data keyed off of a PodLayoutManager.
		protected var podDataDictionary:Dictionary = new Dictionary();
		
		// Stores PodLayoutManagers keyed off of a Pod.
		// Used for podLayoutManager calls after pods have been created for the first time.
		// Also, used for look-ups when saving pod content ViewStack changes.
		protected var podHash:Object = new Object();
		
        // liferay places layouts
        private var allLayouts:Array = new Array();
    
        public var placesService:RemoteObject;
        public var layoutService:RemoteObject;
        public var userService:RemoteObject;
        
        // logined user
        protected var userVO:UserVO;
        
        // places are groups in liferay
        private var userGroupId:uint;
        private var guestGroupId:uint;
        
        // given groupId (group == place) get PlaceVO
        private var placesHash:Object = new Object();

        // liferay  places menu data
        private var rootMenuItemData:Object = new Object();

		protected var liferayServerConfig:LiferayServerConfig;
		 
          
		public function FlexibleLiferayAirAppBase()
		{
			super();

            loadConfig();            			                                      
        }

        protected function loadConfig():void
        {
            // spring actionscript config
            applicationContext = new FlexXMLApplicationContext("FlexibleLiferayConfig.xml");
            applicationContext.addEventListener(Event.COMPLETE, onApplicationContextComplete);
            applicationContext.load();                                          
        }

        protected function onApplicationContextComplete(event:Event):void
        {
            liferayServerConfig = applicationContext.getObject("liferayServerConfig"); 

            var baseUrl:String = liferayServerConfig.portalUrl; 
        	
            var channelSet:ChannelSet = new ChannelSet();
       
            // setup a channel for remoting to liferay via blazeds in liferay root
            var channelUrl:String = baseUrl + "messagebroker/amf";
            var channelId:String = "my-amf";
            var channel:AMFChannel = new AMFChannel(channelId, channelUrl);            
            channelSet.addChannel(channel);
                
            placesService.channelSet = channelSet;        
            layoutService.channelSet = channelSet;
            userService.channelSet = channelSet;            
        }
					
        protected function onApplicationComplete():void
        {
            placesMenuBar.addEventListener(MenuEvent.ITEM_CLICK, menuHandler);
                        
			// have just menu title in my places menu until login
            rootMenuItemData.name = "My Places";
            rootMenuItemData.data = "";
            rootMenuItemData.children = new Array();   
            placesMenuBar.dataProvider = rootMenuItemData;   
                			                       
            modeViewStack.selectedIndex = MAIN_VIEW_MODE_INDEX;          	                			                       
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
									
		protected function onItemClickTabBar(e:ItemClickEvent):void
		{
			var index:Number = e.index;
			StateManager.setViewIndex(index); // Save the view index.
			
			viewStack.selectedIndex = index;
			
			// If data exists then add the pods. After the pods have been added the data is cleared.
			var podLayoutManager:PodLayoutManager = podLayoutManagers[index];
			if (podDataDictionary[podLayoutManager] != null)
			{
				addPods(podLayoutManagers[index]);
			}
		}
		
		// Adds the pods / portlets to a  tab view (lifray layout)
		protected function addPods(manager:PodLayoutManager):void
		{
			// Loop through the pod nodes for each view node.
			var layout:LayoutVO = podDataDictionary[manager];
			var place:PlaceVO = placesHash[layout.groupId];
			
			var podLen:Number = layout.portletIds.length;
			var unsavedPodCount:Number = 0;
			for (var j:Number = 0; j < podLen; j++)
			{
				var podContent:LiferayHtmlPod = new LiferayHtmlPod();						
				
                podContent.portalUrl = "http://localhost:8080/";
        
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

                podContent.portletUrl =  podContent.portalUrl + "widget/" + type + place.friendlyUrl + layout.friendlyUrl + "/-/" + layout.portletIds[j];
                				
				var viewId:String = manager.id;
				var podId:String = layout.portletIds[j];
				
				var pod:Pod = new Pod();
				pod.id = podId;
				pod.title = "Portlet";

				pod.addChild(podContent);
															
				manager.addItemAt(pod, j, false);						
				
				pod.addEventListener(IndexChangedEvent.CHANGE, onChangePodView);
				
				podHash[pod] = manager;
			}
			
			// Delete the saved data.
			delete podDataDictionary[manager];
			
            // Listen for the last pod to complete so the layout from the ContainerWindowManager is done correctly. 
            var argsArray:Array = new Array();
            argsArray.push(manager); 
            callLater(onCreationCompletePod, argsArray);
		}
		
		// Pod has been created so update the respective PodLayoutManager.
        protected function onCreationCompletePod(manager:PodLayoutManager):void
		{
			manager.removeNullItems();
			manager.tile();
		}
		
		// Saves the pod content ViewStack state.
		protected function onChangePodView(e:IndexChangedEvent):void
		{
			var pod:Pod = Pod(e.currentTarget);
			var viewId:String = PodLayoutManager(podHash[pod]).id;
			StateManager.setPodViewIndex(viewId, pod.id, e.newIndex);
		}
		
        /**
         * Tile portlet windows using flexmdi 
         * 
         */
		protected function tile():void
		{
		    var index:int = viewStack.selectedIndex;
		    var mgr:PodLayoutManager = podLayoutManagers[index];
		    if (mgr != null)
		    {
		    	mgr.tile();
	    	}  
		}
        
        /**
         * Cascade portlet windows using flexmdi 
         * 
         */
        protected function cascade():void
        {
            var index:int = viewStack.selectedIndex;
            var mgr:PodLayoutManager = podLayoutManagers[index];
            if (mgr != null)
            {
            	mgr.cascade();
            }
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
                this.placesHash[placeVO.groupId] = placeVO;
                
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
                
                // Create a canvas for each view node.
                var canvas:MDICanvas = new MDICanvas();             
                // PodLayoutManager handles resize and should prevent the need for
                // scroll bars so turn them off so they aren't visible during resizes.
                canvas.horizontalScrollPolicy = "off";
                canvas.verticalScrollPolicy = "off";
                canvas.label = layout.name;
                canvas.percentWidth = 100;
                canvas.percentHeight = 100;                             
                viewStack.addChild(canvas);
                canvas.windowManager.snapDistance = 16;
                canvas.windowManager.tilePadding = 10;
                
                // Create a manager for each view.
                var manager:PodLayoutManager = new PodLayoutManager();
                manager.container = canvas;
                manager.id = layout.name;
                manager.addEventListener(LayoutChangeEvent.UPDATE, StateManager.setPodLayout);
                // Store the data. Used when view is first made visible.
                podDataDictionary[manager] = layout;
                podLayoutManagers.push(manager);
            }
            
            if (layouts.length > 0)
            {
                var index:Number = 0;
                onItemClickTabBar(new ItemClickEvent(ItemClickEvent.ITEM_CLICK, false, false, null, index));
                tabBar.selectedIndex = index; 
            }                          
        }

        protected function onClickSignIn(event:Event):void
        {
            login = new LiferayLogin();
            login.emailAddress = liferayServerConfig.defaultEmailAddress;
            login.password = liferayServerConfig.defaultPassword;
            PopUpManager.addPopUp(login, this, true);
            PopUpManager.centerPopUp(login);
            login.addEventListener("liferayLogin", onLogin);
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
         * Login with liferay when get liferayLogin event from LiferayLogin dialog
         *  
         * @param event login event
         * 
         */
        private function onLogin(event:LiferayLoginEvent):void
        {
	        userService.login(event.emailAddress, event.password);
        }        
	}
}