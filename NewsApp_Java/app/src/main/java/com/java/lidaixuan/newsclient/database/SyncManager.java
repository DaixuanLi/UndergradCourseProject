package com.java.lidaixuan.newsclient.database;
import android.content.Context;
import android.widget.Toast;

import com.alibaba.fastjson.*;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

class ResponseHandler extends Thread{
    public Response response = null;
    public String ans = null;
    String url = "http://159.89.130.141:8000/sync/";
    @Override
    public void run(){
        OkHttpClient client = new OkHttpClient();
        FormBody formBody = new FormBody.Builder()
                .add("syncdown", "")
                .build();
        final Request request = new Request.Builder()
                .url(url)
                .post(formBody)
                .build();
        Call call = client.newCall(request);
        try{
            response = call.execute();
            ans = response.body().string();

        }catch (Exception e){
            e.printStackTrace();
        }

    }
}

class CollectionResponseHandler extends Thread{
    public Response response = null;
    public String ans = null;
    public String user = "root";
    String url = "http://159.89.130.141:8000/sync/";
    @Override
    public void run(){
        OkHttpClient client = new OkHttpClient();
        FormBody formBody = new FormBody.Builder()
                .add("syncdowncollection", "")
                .add("user",user)
                .build();
        final Request request = new Request.Builder()
                .url(url)
                .post(formBody)
                .build();
        Call call = client.newCall(request);
        try{
            response = call.execute();
            ans = response.body().string();

        }catch (Exception e){
            e.printStackTrace();
        }

    }
}

class CollectionUpHandler extends Thread{
    public String upstring = null;
    public String ans = null;
    public String user = "root";
    String url = "http://159.89.130.141:8000/sync/";
    @Override
    public void run(){
        OkHttpClient client = new OkHttpClient();
        FormBody formBody = new FormBody.Builder()
                .add("syncupcollection", upstring)
                .add("user",user)
                .build();
        final Request request = new Request.Builder()
                .url(url)
                .post(formBody)
                .build();
        Call call = client.newCall(request);
        try{
           call.execute();

        }catch (Exception e){
            e.printStackTrace();
        }

    }
}

public class SyncManager {
    public static String url = "http://159.89.130.141:8000/sync/";
    public static void SyncUp(String[][] userdata)  {//前一位是用户索引，后一位是依次username,password和category索引
        (new Thread( ()->{
            //
            try{
                JSONArray ans = new JSONArray();
                for(int i = 0;i<userdata.length;i++){
                    StringBuilder tmp = new StringBuilder("{");
                    tmp.append("\"username\":\""+userdata[i][0]+"\",");
                    tmp.append("\"password\":\""+userdata[i][1]+"\",");
                    tmp.append("\"categories\":\""+userdata[i][2]+"\"}");
                    ans.add(JSON.parseObject(tmp.toString()));
                }
                String postdata = ans.toJSONString();
                OkHttpClient client = new OkHttpClient();
                FormBody formBody = new FormBody.Builder()
                        .add("syncup", postdata)
                        .build();
                final Request request = new Request.Builder()
                        .url(url)
                        .post(formBody)
                        .build();
                Call call = client.newCall(request);
                call.execute();
            }catch (Exception e){
                e.printStackTrace();
            }
        } )).start();


    }
    public static String[][] SyncDown(){
        ResponseHandler rh = new ResponseHandler();
        try{
            rh.start();
            rh.join();
        }catch (Exception e){
            e.printStackTrace();
        }
        String ans = rh.ans;
        JSONArray a = JSON.parseArray(ans);
        int len = a == null ? 0 : a.size();
        String[][] temptable = new String[len][3];
        for(int i = 0;i<len;i++){
            JSONObject c = (JSONObject) a.get(i);
            temptable[i][0] = c.getString("username");
            temptable[i][1] = c.getString("password");
            temptable[i][2] = c.getString("categories");
        }
        return temptable;
    }
    public static String SyncDownCollection(String user){
        CollectionResponseHandler rh = new CollectionResponseHandler();
        rh.user = user;
        try{
            rh.start();
            rh.join();
        }catch (Exception e){
            e.printStackTrace();
        }
        return rh.ans;
    }
    public static void SyncUpCollection(String user,String collections){
        (new Thread( ()->{
            //
            try{
                OkHttpClient client = new OkHttpClient();
                FormBody formBody = new FormBody.Builder()
                        .add("syncupcollection", collections)
                        .add("user",user)
                        .build();
                final Request request = new Request.Builder()
                        .url(url)
                        .post(formBody)
                        .build();
                Call call = client.newCall(request);
                call.execute();
            }catch (Exception e){
                e.printStackTrace();
            }
        } )).start();
    }
}
