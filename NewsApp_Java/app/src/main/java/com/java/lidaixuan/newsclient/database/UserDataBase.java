package com.java.lidaixuan.newsclient.database;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.service.autofill.UserData;
import android.content.Context;
import android.util.Log;

public class UserDataBase {
    UserDataBaseHelper dbhelper = null;
    Context context = null;
    public UserDataBase(Context context){
        this.context = context;
        dbhelper = UserDataBaseHelper.getInstance(context);
    }
    public UserDataBase(){
        dbhelper = UserDataBaseHelper.getInstance();
    }
    private void SyncDown(){
        String[][] data = SyncManager.SyncDown();
        for(String[] user:data){
            SQLiteDatabase rdb = dbhelper.getReadableDatabase();
            Cursor cur = rdb.query("Users",new String[]{"username","password"},"username=\'"+user+"\'",null,null,null,null);
            SQLiteDatabase db = dbhelper.getWritableDatabase();
            if(cur.getCount()>=1){
                db.delete("Users","username=\'"+user[0]+"\'",null);
            }
            new_user(user[0],user[1],user[2].split(","));
        }
    }
    private void SyncUp(String[][] userdata){
        SyncManager.SyncUp(userdata);
    }
    public String get_password_by_user(String user){
        SyncDown();
        String password = null;
        try{
            SQLiteDatabase db = dbhelper.getReadableDatabase();
            Cursor cur = db.query("Users",new String[]{"username","password"},"username=\'"+user+"\'",null,null,null,null);
            if(cur.getCount()<1){
                throw new Exception();
            }
            int text = cur.getCount();
            cur.moveToFirst();
            password = cur.getString(cur.getColumnIndex("password"));
        }catch(Exception e){
            password = null;
        }
        return password;
    }
    public String[] get_categories_by_user(String user){
        SyncDown();
        String[] ans = null;
        try{
            SQLiteDatabase db = dbhelper.getReadableDatabase();
            Cursor cur = db.query("Users",new String[]{"categories"},"username=\'"+user+"\'",null,null,null,null);
            if(cur.getCount()<1){
                throw new Exception();
            }
            int text = cur.getCount();
            cur.moveToFirst();
            String categories = cur.getString(cur.getColumnIndex("categories"));
            if(categories==null){
                throw new Exception();
            }
            ans = categories.split(",");
        }catch(Exception e){
            ans = null;
        }
        return ans;
    }
    public boolean set_categories(String user,String[] categories){
        boolean success = false;
        try{
            String password = get_password_by_user(user);
            SQLiteDatabase db = dbhelper.getWritableDatabase();
            db.delete("Users","username=\'"+user+"\'",null);
            new_user(user,password,categories);
        }catch(Exception e){
            Log.d("Warning!","Exception while updating categories");
        }
        return success;
    }
    public boolean set_password(String user,String password){
        boolean success = false;
        try{
            String[] categories = get_categories_by_user(user);
            SQLiteDatabase db = dbhelper.getWritableDatabase();
            db.delete("Users","username=\'"+user+"\'",null);
            new_user(user,password,categories);
            success = true;
        }catch(Exception e){
            Log.d("Warning!","Exception while updating password!");
        }
        return success;
    }
    public boolean new_user(String user,String password,String[] categories){
        boolean success = false;
        StringBuilder sb = new StringBuilder("");
        for(String content:categories){
            sb.append(content+",");
        }
        sb.delete(sb.length()-1,sb.length());
        String finalstr = sb.toString();
        try{
            SQLiteDatabase db = dbhelper.getWritableDatabase();
            String SQL = "INSERT INTO USERS (username,password,categories) VALUES (\'"+user+"\'"+
                    ",\'"+password+"\',\'" + finalstr+"\');";
            db.execSQL(SQL);
            success = true;
        }catch(Exception e){
            Log.d("Warning!","Exception while inserting user!");
        }
        SyncUp(new String[][]{{user,password,finalstr}});
        return success;
    }
}
