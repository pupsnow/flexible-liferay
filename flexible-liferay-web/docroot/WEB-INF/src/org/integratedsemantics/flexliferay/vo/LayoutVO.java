package org.integratedsemantics.flexliferay.vo;

import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.UnicodeProperties;
import com.liferay.portal.model.Layout;
import com.liferay.portal.model.Portlet;
import com.liferay.portal.model.PortletApp;
import com.liferay.portal.service.PortletLocalServiceUtil;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;


public class LayoutVO
{
    public long plid;
    public String name;
    public boolean isPrivate;
    public long groupId;
    public String typeSettings;
    public String friendlyUrl;
    public List<String> portletIds = new ArrayList<String>();
    public List<String> contextPaths = new ArrayList<String>();


    public LayoutVO() {}

    public LayoutVO(Layout layout, HttpServletRequest request) throws Exception
    {
        this.plid = layout.getPlid();
        this.name = layout.getName("en_US");
        this.isPrivate = layout.isPrivateLayout();
        this.groupId = layout.getGroup().getGroupId();
		this.typeSettings = layout.getTypeSettings();
		this.friendlyUrl = layout.getFriendlyURL();

        UnicodeProperties props = layout.getTypeSettingsProperties();

        for (int i = 1; i < 3; i++)
        {
	        String column = props.getProperty("column-" + i);
			if (column != null)
			{
				String[] columnPortletIds = StringUtil.split(column);

				for (int j = 0; j < columnPortletIds.length; j++)
				{
					String portletId = columnPortletIds[j];
					Portlet portlet = PortletLocalServiceUtil.getPortletById(
						layout.getCompanyId(), portletId);

					if (portlet != null)
					{
						portletIds.add(portletId);
						
						PortletApp portletApp = portlet.getPortletApp();
						String contextPath = portletApp.getContextPath();
						contextPaths.add(contextPath);
					}				
				}
			}
		}
	}

}