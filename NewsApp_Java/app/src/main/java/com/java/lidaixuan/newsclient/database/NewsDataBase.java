package com.java.lidaixuan.newsclient.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import java.util.HashMap;

public class NewsDataBase {
    Context context = null;
    NewsDatabaseHelper helper = null;
    int current_news_num = 0;
    public NewsDataBase(){
        helper = NewsDatabaseHelper.getInstance();
    }
    public String[] loadNews(){
        String[] ans;
        try{
            SQLiteDatabase db = helper.getReadableDatabase();
            Cursor cur = db.query("News",new String[]{"json"},null,null,null,null,null);
            current_news_num = cur.getCount();
            if(current_news_num == 0){
                return new String[]{};
            }
            cur.moveToFirst();
            String[] newses = new String[current_news_num];
            for(int i = 0;i<current_news_num-1;i++) {
                newses[i] = cur.getString(cur.getColumnIndex("json"));
                cur.moveToNext();
            }
            newses[current_news_num-1] = cur.getString(cur.getColumnIndex("json"));
            ans = newses;

        }catch(Exception e){
            Log.d("Warning!","error load news");
            current_news_num = 0;
            ans = new String[]{};
        }
        return ans;
    }
    public void storeANews(String news,String newsID){
        try{
            SQLiteDatabase rdb = helper.getReadableDatabase();
            Cursor cs = rdb.query("News",null,null,null,null,null,null);
            String[] a = cs.getColumnNames();
            Cursor cur = rdb.query("News",null,"news_ID=\'"+newsID+"\'",null,null,null,null);
            if(cur.getCount()>0){
                return;
            }
            SQLiteDatabase db = helper.getWritableDatabase();
            ContentValues map = new ContentValues();
            map.put("json",news);
            map.put("news_ID",newsID);
            db.insert("News",null,map);
        }catch(Exception e){
            Log.d("Warning!","error store news");
        }
    }
    public String[] loadNews(String category){
        String[] ans;
        try{
            SQLiteDatabase wdb = helper.getWritableDatabase();
            String CREATE_DATABASE = "CREATE TABLE IF NOT EXISTS " + category + " (" +
                    "ID INTEGER PRIMARY KEY AUTOINCREMENT,news_ID TEXT," +
                    "JSON TEXT)";
            wdb.execSQL(CREATE_DATABASE);
            SQLiteDatabase db = helper.getReadableDatabase();
            Cursor cur = db.query(category,new String[]{"json"},null,null,null,null,null);
            current_news_num = cur.getCount();
            if(current_news_num == 0){
                return new String[]{};
            }
            cur.moveToFirst();
            String[] newses = new String[current_news_num];
            for(int i = 0;i<current_news_num-1;i++) {
                newses[i] = cur.getString(cur.getColumnIndex("JSON"));
                cur.moveToNext();
            }
            newses[current_news_num-1] = cur.getString(cur.getColumnIndex("JSON"));
            ans = newses;

        }catch(Exception e){
            Log.d("Warning!","error load news");
            current_news_num = 0;
            ans = new String[]{};
        }
        return ans;
    }
    public void storeANews(String news,String newsID,String category){
        try{
            SQLiteDatabase db = helper.getWritableDatabase();
            String CREATE_DATABASE = "CREATE TABLE IF NOT EXISTS " + category + " (" +
                    "ID INTEGER PRIMARY KEY AUTOINCREMENT,news_ID TEXT," +
                    "JSON TEXT)";
            db.execSQL(CREATE_DATABASE);
            SQLiteDatabase rdb = helper.getReadableDatabase();
            Cursor cur = rdb.query(category,null,"news_ID=\'"+newsID+"\'",null,null,null,null);
            if(cur.getCount()>0){
                return;
            }
            ContentValues map = new ContentValues();
            map.put("json",news);
            map.put("news_ID",newsID);
            db.insert(category,null,map);
        }catch(Exception e){
            Log.d("Warning!","error store news");
        }
    }
    public void deleteANews(String news,String newsID,String category){
        try{
            SQLiteDatabase db = helper.getWritableDatabase();
            String CREATE_DATABASE = "CREATE TABLE IF NOT EXISTS " + category + " (" +
                    "ID INTEGER PRIMARY KEY AUTOINCREMENT,news_ID TEXT," +
                    "JSON TEXT)";
            db.execSQL(CREATE_DATABASE);
            db.delete(category,"news_ID=\'"+newsID+"\'",null);
        }catch(Exception e){
            Log.d("Warning!","error store news");
        }
    }
    /*
    public void storeNews(String[] news){
        current_news_num = 0;
        for(String item:news){
            storeANews(item,);
            current_news_num++;
        }
    }*/
/*
    public String[] loadNews(String category){
        String[] ans;
        try{
            SQLiteDatabase wdb = helper.getWritableDatabase();
            String CREATE_DATABASE = "CREATE TABLE IF NOT EXISTS " + category + " (" +
                      "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "JSON TEXT)";
            wdb.execSQL(CREATE_DATABASE);
            SQLiteDatabase db = helper.getReadableDatabase();
            Cursor cur = db.query(category,new String[]{"json"},null,null,null,null,null);
            current_news_num = cur.getCount();
            if(current_news_num == 0){
                return new String[]{};
            }
            cur.moveToFirst();
            String[] newses = new String[current_news_num];
            for(int i = 0;i<current_news_num-1;i++) {
                newses[i] = cur.getString(cur.getColumnIndex("json"));
                cur.moveToNext();
            }
            newses[current_news_num-1] = cur.getString(cur.getColumnIndex("json"));
            ans = newses;

        }catch(Exception e){
            Log.d("Warning!","error load news");
            current_news_num = 0;
            ans = new String[]{};
        }
        return ans;
    }
    private void storeANews(String news,String category){
        try{
            SQLiteDatabase db = helper.getWritableDatabase();
            ContentValues map = new ContentValues();
            map.put("json",news);
            db.insert(category,null,map);
        }catch(Exception e){
            Log.d("Warning!","error store news");
        }
    }
    public void storeNews(String[] news,String category){
        current_news_num = 0;
        for(String item:news){
            storeANews(item);
            current_news_num++;
        }
    }*/
    public void deleteALll(){
        try{
            SQLiteDatabase db = helper.getWritableDatabase();
            //String SQL = "DELETE FROM "+"News"+" where id in (SELECT id from News order by id limit "+delnum+");";
            helper.onUpgrade(db,1,2);
            db.delete("News",null,null);
        }catch (Exception e){
            Log.d("Warning!","failed to delete news");
        }
        SQLiteDatabase rdb = helper.getReadableDatabase();
        Cursor cs = rdb.query("News",null,null,null,null,null,null);
        String[] a = cs.getColumnNames();
    }
    public void deleteAll(String category){
        try{
            SQLiteDatabase db = helper.getWritableDatabase();
            String CREATE_DATABASE = "CREATE TABLE IF NOT EXISTS " + category + " (" +
                    "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "JSON TEXT)";
            db.execSQL(CREATE_DATABASE);
            db.delete(category,null,null);
        }catch (Exception e){
            Log.d("Warning!","failed to delete news");
        }
    }
}
