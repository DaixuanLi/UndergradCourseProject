package com.java.lidaixuan.newsclient.network;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class ImagCrawler extends Thread{
    String url = null;
    public Bitmap ans = null;
    public ImagCrawler(String url){
        this.url = url;
    }
    @Override
    public void run(){
        try {
            //生成url
            URL url = new URL(this.url);
            //建立连接
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            //设置超时 5s
            connection.setConnectTimeout(5000);
            //获取输入流
            InputStream in=connection.getInputStream();
            //将流转化为bitmap
            Bitmap bitmap= BitmapFactory.decodeStream(in);
            ans = bitmap;

        } catch (IOException e) {
            e.printStackTrace();
        } catch(Exception e){
            e.printStackTrace();
        }
    }

}
