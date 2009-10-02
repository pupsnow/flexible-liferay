package org.integratedsemantics.flexliferay.vo;

import com.liferay.portal.model.User;

public class UserVO
{
    public long userId;
    public String screenName;
    public String fullName;
    public String emailAddress;

    public UserVO() {}

    public UserVO(User user)
    {
        this.userId = user.getUserId();
        this.screenName = user.getScreenName();
        this.fullName = user.getFullName();
        this.emailAddress = user.getEmailAddress();
    }
}