package com.java.lidaixuan.newsclient.util;

import com.java.lidaixuan.newsclient.database.UserDataBase;

import java.util.ArrayList;
import java.util.Arrays;

public class CategoriesHelper {
    private final static String[] DEFAULT_CATEGORIES = new String[]
            {"综合", "推荐", "娱乐", "军事", "教育", "文化", "健康", "财经", "体育", "汽车", "科技", "社会"};
    public static ArrayList<String> getUserCategories(String user) {
        UserDataBase userDataBase = new UserDataBase();
        return toArrayList(userDataBase.get_categories_by_user(user), DEFAULT_CATEGORIES);
    }
    public static ArrayList<String> getAllCategories(String user) {
        return toArrayList(null, DEFAULT_CATEGORIES);
    }
    public static ArrayList<String> getAllCategories() {
        return toArrayList(null, DEFAULT_CATEGORIES);
    }

    private static ArrayList<String> toArrayList(String[] cats, String[] defaul) {
        if (cats == null) {
            cats = defaul;
        }
        return new ArrayList<>(Arrays.asList(cats));
    }
}
