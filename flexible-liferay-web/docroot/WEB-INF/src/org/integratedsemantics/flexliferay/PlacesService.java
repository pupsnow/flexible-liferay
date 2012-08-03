package org.integratedsemantics.flexliferay;

import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.User;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.security.permission.PermissionCheckerFactoryUtil;
import com.liferay.portal.security.permission.PermissionThreadLocal;
import com.liferay.portal.service.UserLocalServiceUtil;

import flex.messaging.FlexContext;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.integratedsemantics.flexliferay.vo.PlaceVO;


public class PlacesService
{
    public PlaceVO[] getMyPlaces(long userId) throws Exception
    {
		HttpServletRequest request = FlexContext.getHttpRequest();
		HttpSession session = request.getSession();

		session.setAttribute(WebKeys.USER_ID, userId);

		User user = UserLocalServiceUtil.getUserById(userId);

		// needed to add permission checker init for liferay 6.1
		PermissionChecker permissionChecker = PermissionCheckerFactoryUtil.create(user, true);
		PermissionThreadLocal.setPermissionChecker(permissionChecker);				
		
		//List<Group> myPlaces = user.getMyPlaces(100);
		// for 6.1 use getMySites
		List<Group> myPlaces = user.getMySites(false, 100);

        PlaceVO[] places = new PlaceVO[myPlaces.size()];
        int i = 0;
        for (Group myPlace : myPlaces)
        {
            places[i++] = new PlaceVO(myPlace);
        }
        return places;
    }
}
