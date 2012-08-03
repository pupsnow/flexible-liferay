package org.integratedsemantics.flexibleliferay.vo
{
    [RemoteClass(alias="org.integratedsemantics.flexliferay.vo.PlaceVO")]    
    public class PlaceVO
    {
        public var isRegularSite:Boolean;
        public var isOrganization:Boolean;
        public var isUser:Boolean;
        public var publicLayoutsPageCount:int;
        public var privateLayoutsPageCount:int;
        public var groupId:uint;
        public var defaultPrivatePlid:uint;
        public var name:String;        
        public var displayName:String;
        public var friendlyUrl:String;        
    }
}