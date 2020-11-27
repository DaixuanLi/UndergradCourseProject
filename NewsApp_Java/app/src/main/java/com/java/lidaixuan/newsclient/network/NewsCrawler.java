package com.java.lidaixuan.newsclient.network;
import android.util.Log;

import com.java.lidaixuan.newsclient.R;
import  com.java.lidaixuan.newsclient.data.NewsData;
import java.net.*;
import java.io.*;
import com.alibaba.fastjson.*;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.Locale;


public class NewsCrawler extends Thread{
    private String hostname;
    private String[] paranames = {
            "startDate","endDate","words","categories"
    };
    private SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss",Locale.CHINA);
    private int size = 20;
    private String[] parameters = {"","","",""};
    public NewsCrawler(int size,String[] parameters){
        super();
        this.size = size;
        this.parameters = parameters;
        hostname = "https://api2.newsminer.net/svc/news/queryNewsList";
    }
    public NewsCrawler(String host,int size,String[] parameters){
        this.size = size;
        this.parameters = parameters;
        hostname = host;
    }
    private LinkedList<NewsData> nl = null;
    private Exception exception;
    @Override
    public void run(){
        try{
            StringBuilder httprequest = new StringBuilder(hostname + "?");
            if(parameters[1].equals("")){
                parameters[1] = sdf.format(new Date());
            }
            if (size !=-1){
                String tmp = "size="+size;
                httprequest.append(tmp);
            }
            for(int i = 0;i<4;i++){
                if(!parameters[i].equals("")){
                    String temp = "&"+paranames[i]+"="+parameters[i];
                    httprequest.append(temp);
                }
            }
            String finalreq = httprequest.toString();
            URL request = new URL(finalreq);

            BufferedReader in = new BufferedReader(new InputStreamReader(request.openStream(), "UTF-8"));
            StringBuilder jsonBuilder = new StringBuilder("");
            String inputline;
            while((inputline = in.readLine())!=null){
                jsonBuilder.append(inputline);
            }
            String jsonstr = jsonBuilder.toString();

            LinkedList<NewsData> newses = new LinkedList<NewsData>();
            try{
                JSONObject data = JSON.parseObject(jsonstr);
                JSONArray array = JSON.parseArray(
                        data.getString("data")
                );
                for(int i = 0;i<array.size();i++){
                    JSONObject obj = (JSONObject) array.get(i);
                    newses.add(new NewsData(obj));
                }
            }catch(JSONException e){
                System.out.println(e.getMessage());
            }
            nl = newses;
            exception = null;
        }catch(MalformedURLException e){
            System.out.println("url exception in thread!");
            Log.e(getClass().getName(), e.getLocalizedMessage());
            exception = e;
        }catch(IOException e){
            System.out.println("io exception in thread!");
            Log.e(getClass().getName(), e.getLocalizedMessage());
            exception = e;
        }
    }
    public LinkedList<NewsData> getNl(){
        return nl;
    }

    public Exception getException() {
        return exception;
    }
}
