package org.integratedsemantics.flexliferay.vo;

import com.liferay.portal.model.Group;
import com.liferay.portal.model.Organization;
import com.liferay.portal.service.OrganizationLocalServiceUtil;

public class PlaceVO
{
    //public boolean isCommunity;
    public boolean isRegularSite;
    public boolean isOrganization;
    public boolean isUser;
    public int publicLayoutsPageCount;
    public int privateLayoutsPageCount;
    public long groupId;
	public long defaultPrivatePlid;
	public String name;
	public String displayName;
	public String friendlyUrl;

    public PlaceVO() {}

    public PlaceVO(Group group)
    {
        // this.isCommunity = group.isCommunity();
    	// isCommunity deprecated, renamed isRegularSite in liferay 6.1
        this.isRegularSite = group.isRegularSite();
        
        this.isOrganization = group.isOrganization();
        this.isUser = group.isUser();
		this.publicLayoutsPageCount = group.getPublicLayoutsPageCount();
		this.privateLayoutsPageCount = group.getPrivateLayoutsPageCount();
		this.groupId = group.getGroupId();
		this.defaultPrivatePlid = group.getDefaultPrivatePlid();
		this.name = group.getName();
		this.friendlyUrl = group.getFriendlyURL();

		if (isOrganization == true)
		{
			try
			{
				Organization organization = OrganizationLocalServiceUtil.getOrganization(group.getClassPK());
				displayName = organization.getName();
			}
			catch (Exception e)
			{
				displayName = "Error";
			}
		}
		else if (isUser == true)
		{
			displayName = "My Community";
		}
		else
		{
			displayName = group.getName();
		}
    }
}