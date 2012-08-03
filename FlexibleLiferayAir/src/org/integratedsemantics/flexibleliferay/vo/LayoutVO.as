package org.integratedsemantics.flexibleliferay.vo
{
    import mx.collections.ArrayCollection;
    
    [RemoteClass(alias="org.integratedsemantics.flexliferay.vo.LayoutVO")]
    public class LayoutVO
    {
        public var plid:uint;
        public var name:String;
        public var isPrivate:Boolean;
        public var groupId:uint;
        public var typeSettings:String;
        public var friendlyUrl:String;
        public var portletIds:ArrayCollection;
		public var contextPaths:ArrayCollection;
    }
}