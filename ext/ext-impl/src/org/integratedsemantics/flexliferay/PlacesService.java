package org.integratedsemantics.flexliferay;

import com.liferay.portal.model.Company;
import com.liferay.portal.model.Group;
import com.liferay.portal.model.User;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portal.util.WebKeys;

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

		List<Group> myPlaces = user.getMyPlaces(100);

        PlaceVO[] places = new PlaceVO[myPlaces.size()];
        int i = 0;
        for (Group myPlace : myPlaces)
        {
            places[i++] = new PlaceVO(myPlace);
        }
        return places;
    }
}
