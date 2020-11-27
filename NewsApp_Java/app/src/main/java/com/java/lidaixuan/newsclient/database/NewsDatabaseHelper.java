package com.java.lidaixuan.newsclient.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.java.lidaixuan.newsclient.data.NewsData;

public class NewsDatabaseHelper extends SQLiteOpenHelper {
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "News.db";

    public static final String TABLE_NAME = "News";
    public static final String _ID = "id";
    public static final String COLUMN_JSON = "json";// 以逗号分隔的category名称


    private static NewsDatabaseHelper instance = null;
    private static Context context = null;
    public static NewsDatabaseHelper getInstance(Context context){
        if(instance == null){
            instance = new NewsDatabaseHelper(context);
        }
        return instance;
    }
    public static NewsDatabaseHelper getInstance(){
        return instance;
    }
    public NewsDatabaseHelper(Context context){
        super(context,DATABASE_NAME,null,DATABASE_VERSION);
    }
    public static void setUpInstance(Context context){
        NewsDatabaseHelper.context = context;
        instance = new NewsDatabaseHelper(context);
    }
    private static final String SQL_CREATE_USERS =
            "CREATE TABLE " + TABLE_NAME + " (" +
                    _ID + " INTEGER PRIMARY KEY AUTOINCREMENT," + "news_ID TEXT,"+
                    COLUMN_JSON + " TEXT)";

    private static final String SQL_DELETE_USERS =
            "DROP TABLE IF EXISTS " + TABLE_NAME;


    @Override
    public void onCreate(SQLiteDatabase db){
        db.execSQL(SQL_CREATE_USERS);
    }
    @Override
    public void onUpgrade(SQLiteDatabase db,int Oldversion,int NewVersion){
        db.execSQL(SQL_DELETE_USERS);
        onCreate(db);
    }


}
