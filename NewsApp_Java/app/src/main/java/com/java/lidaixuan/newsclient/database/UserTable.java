package com.java.lidaixuan.newsclient.database;

import android.provider.BaseColumns;

public final class UserTable {
    // To prevent someone from accidentally instantiating the contract class,
    // make the constructor private.
    private UserTable() {}

    /* Inner class that defines the table contents */
    public static class FeedEntry implements BaseColumns {
        public static final String TABLE_NAME = "Users";
        public static final String _ID = "id";
        public static final String COLUMN_USER_NAME = "username";
        public static final String COLUMN_PASSWORD = "password";
        public static final String COLUMN_CATEGORIES = "categories";// 以逗号分隔的category名称

    }
}

