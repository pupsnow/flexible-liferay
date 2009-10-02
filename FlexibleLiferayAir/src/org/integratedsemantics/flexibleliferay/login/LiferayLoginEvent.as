package org.integratedsemantics.flexibleliferay.login
{
	import flash.events.Event;

	public class LiferayLoginEvent extends Event
	{
        /** Event name */
        public static const LOGIN:String = "liferayLogin";

		public var emailAddress:String;
		public var password:String;
		
		public function LiferayLoginEvent(type:String, email:String, password:String)
		{
			super(type, bubbles, cancelable);
			this.emailAddress = email;
			this.password = password;
		}
		
	}
}