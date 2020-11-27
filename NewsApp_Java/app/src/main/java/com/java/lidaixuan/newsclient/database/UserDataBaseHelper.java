package com.java.lidaixuan.newsclient.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class UserDataBaseHelper extends SQLiteOpenHelper {
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "Users.db";
    private static UserDataBaseHelper instance = null;
    public static Context context = null;
    public static UserDataBaseHelper getInstance(Context context){
        if(instance == null){
            instance = new UserDataBaseHelper(context);
        }
        return instance;
    }
    public static UserDataBaseHelper getInstance(){
        return instance;
    }
    public UserDataBaseHelper(Context context){
        super(context,DATABASE_NAME,null,DATABASE_VERSION);
    }
    public static void setUpInstance(Context context){
        UserDataBaseHelper.context = context;
        instance = new UserDataBaseHelper(context);
    }
    private static final String SQL_CREATE_USERS =
            "CREATE TABLE " + UserTable.FeedEntry.TABLE_NAME + " (" +
                    UserTable.FeedEntry._ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                    UserTable.FeedEntry.COLUMN_USER_NAME + " TEXT," +
                    UserTable.FeedEntry.COLUMN_PASSWORD + " TEXT," +
                    "RECCOMEND TEXT," + //JSON 三个词
                    "COLLECTION TEXT,"+ //JSON 新闻集合的JSON
                    UserTable.FeedEntry.COLUMN_CATEGORIES + " TEXT)";

    private static final String SQL_DELETE_USERS =
            "DROP TABLE IF EXISTS " + UserTable.FeedEntry.TABLE_NAME;

    private static final String SQL_CREATE_ROOT_USER =
            "INSERT INTO USERS ("+UserTable.FeedEntry.COLUMN_USER_NAME+","+UserTable.FeedEntry.COLUMN_PASSWORD+","+UserTable.FeedEntry.COLUMN_CATEGORIES+",RECCOMEND,COLLECTION) VALUES (\'root\',\'123123\',null,null,null)";
    @Override
    public void onCreate(SQLiteDatabase db){
        db.execSQL(SQL_CREATE_USERS);
        db.execSQL(SQL_CREATE_ROOT_USER);
    }
    @Override
    public void onUpgrade(SQLiteDatabase db,int Oldversion,int NewVersion){
        db.execSQL(SQL_DELETE_USERS);
        onCreate(db);
    }


}
