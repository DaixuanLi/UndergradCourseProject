package com.java.lidaixuan.newsclient.data.login;

import com.java.lidaixuan.newsclient.data.model.LoggedInUser;
import com.java.lidaixuan.newsclient.database.UserDataBase;
import com.java.lidaixuan.newsclient.util.CategoriesHelper;

import java.io.IOException;
import java.util.List;

/**
 * Class that handles authentication w/ login credentials and retrieves user information.
 */
public class LoginDataSource {

    public Result<LoggedInUser> login(String username, String password) {

        try {
            // TODO: handle loggedInUser authentication
            UserDataBase dataBase = new UserDataBase();
            String realPassword = dataBase.get_password_by_user(username);
            if (realPassword == null) {
                List<String> categories = CategoriesHelper.getAllCategories();
                dataBase.new_user(username, password, categories.toArray(new String[0]));
                realPassword = password;
            }
            if (realPassword.equals(password)) {
                LoggedInUser fakeUser =
                        new LoggedInUser(username, username);
                return new Result.Success<>(fakeUser);
            } else {
                return new Result.Unauthorized();
            }
        } catch (Exception e) {
            return new Result.Error(new IOException("Error logging in", e));
        }
    }

    public void logout() {
        // TODO: revoke authentication
    }
}
