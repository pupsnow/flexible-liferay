package org.integratedsemantics.flexliferay;

import com.liferay.portal.model.Company;
import com.liferay.portal.model.CompanyConstants;
import com.liferay.portal.model.User;
import com.liferay.portal.security.auth.AuthException;
import com.liferay.portal.security.auth.Authenticator;
import com.liferay.portal.service.persistence.UserUtil;
import com.liferay.portal.service.UserLocalServiceUtil;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portal.util.WebKeys;

import flex.messaging.FlexContext;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.integratedsemantics.flexliferay.vo.UserVO;


public class UserService
{
    public UserVO[] getAllUsers() throws Exception
    {
        List<User> users = UserLocalServiceUtil.getUsers(0, 100);
        UserVO[] ret = new UserVO[users.size()];
        int i = 0;
        for (User user : users)
        {
            ret[i++] = new UserVO(user);
		}
        return ret;
    }

    public UserVO login(String userEmail, String password) throws Exception
    {
		HttpServletRequest request = FlexContext.getHttpRequest();

		int authResult = Authenticator.FAILURE;

		Company company = PortalUtil.getCompany(request);

		Map<String, String[]> headerMap = new HashMap<String, String[]>();
		Map<String, String[]> parameterMap = request.getParameterMap();

		authResult = UserLocalServiceUtil.authenticateByEmailAddress(company.getCompanyId(),
			userEmail, password, headerMap, parameterMap);

		if (authResult == Authenticator.SUCCESS)
		{
			User user = UserLocalServiceUtil.getUserByEmailAddress(company.getCompanyId(), userEmail);
			UserVO userVO = new UserVO(user);
			return userVO;
		}
		else
		{
			throw new AuthException();
		}
	}
}
