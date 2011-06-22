package org.integratedsemantics.flexliferay;

import com.liferay.portal.model.Layout;
import com.liferay.portal.service.LayoutLocalServiceUtil;
import com.liferay.portal.util.WebKeys;

import flex.messaging.FlexContext;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.integratedsemantics.flexliferay.vo.LayoutVO;


public class LayoutService
{
    public LayoutVO[] getLayouts(long userId, long groupId, boolean privateLayouts) throws Exception
    {
		HttpServletRequest request = FlexContext.getHttpRequest();
		HttpSession session = request.getSession();

		session.setAttribute(WebKeys.USER_ID, userId);

		List<Layout> rootLayouts = LayoutLocalServiceUtil.getLayouts(groupId, privateLayouts);

        LayoutVO[] layouts = new LayoutVO[rootLayouts.size()];
        int i = 0;
        for (Layout layout : rootLayouts)
        {
            layouts[i++] = new LayoutVO(layout, request);
        }
        return layouts;
    }
}
