# FlexibleDashboard+Liferay #
Now calling this FlexibleDashboard+Liferay instead of FlexibleLiferay. This change is to focus on the use of this for managing user/group dashboard configs and group collaboration with BI dashboards, etc. In previous version called FlexibleLiferay, it was only a flex based portal container app just displaying regular liferay portlets (which it still can do).

In the 8/2/2012 release, FlexibleDashboard+Liferay now is able to manage pure Flex/Flash pods without html wrappers in addition to regular Liferay portlets. The server side code in version requires Liferay 6.1 (not Liferay 6.0).



<a href='http://integratedsemantics.org/wp-content/uploads/2012/08/flexibledashboardliferay-100.png' title='FlexibleDashboard+Liferay'><img src='http://integratedsemantics.org/wp-content/uploads/2012/08/flexibledashboardliferay-40.png' alt='FlexibleDashboard+Liferay' /></a>

  1. Can display regular Liferay portlets (JSR-168, JSR-286, HTML/Ajax etc.)
  1. All of Liferay backend, standards it supports can be leveraged
  1. Can display pure flex FlexibleDashboard flex pods (swfs) having to display within a portlet
  1. Leverage Liferay app catalog to also manage Flex portlets
  1. Leverage Liferay security / authentication (ldap, sso, etc.) to also manage Flex portlets
  1. Flex portlets can take advantage of AIR specific features (native desktop file drag / drop, native clipboard, local files, offline db)
  1. Use Flex and ActionScript to develop new UI, java / groovy / grails for backend
  1. Could integrate a Liferay portal as part of an enterprise flex application

### Implementation ###
  1. Uses BlazeDS/AMF to remote to some Java Apis added via a Liferay 6.1 web plugin
  1. Built on top of the flexible-dashboard google code project (esria dashboard pod drag drop in tile mode, with flexmdi tiling/cascade)
  1. Now flex 4 based
  1. Note: need to use with Liferay 6.1, not 6.0 or 5.x


### Implemented ###
  1. Sign in (Login dialog), Sign out
  1. My Places menu
  1. Display of tabs for pages in selected place/site
  1. Display of a HTML pod with Liferay widget for each portlet in selected page
  1. Flexpods placeholder portlets with pod.xml config to indicate a pure flex pod should be displayed


**Also see:**

[integratedsemantics.org](http://www.integratedsemantics.org) blog

[integratedsemantics.com](http://www.integratedsemantics.com)

[FlexibleDashboard Google Code site](http://code.google.com/p/flexible-dashboard/)

[FlexibleShare which extends FlexibleDashboard with FlexSpaces pods for doc mgt (Alfresco) and added Flex pods for collaboration (Alfresco Share backend), Google Code site](http://code.google.com/p/flexibleshare/)

**For regular Flex based portlets** (Flex/Flash wrapped in html) that can be used in normal Liferay, see:

[FlexSpaces for Alfresco Google Code](http://code.google.com/p/flexspaces/)

[CMIS Spaces, based on FlexSpaces, supporting not just Alfresco, but with general support for ECM servers that support CMIS](http://code.google.com/p/cmisspaces/)