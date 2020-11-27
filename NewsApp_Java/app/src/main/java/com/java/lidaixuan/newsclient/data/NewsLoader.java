package com.java.lidaixuan.newsclient.data;

import android.accounts.NetworkErrorException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.widget.Toast;

import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.database.NewsDataBase;
import com.java.lidaixuan.newsclient.database.NewsDatabaseHelper;
import com.java.lidaixuan.newsclient.network.ImagCrawler;
import com.java.lidaixuan.newsclient.network.NewsCrawler;
import com.java.lidaixuan.newsclient.ui.main.NewsListModel;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

/**
 * Temporary class used to demonstrate the effects of RecycleView.
 */
public class NewsLoader {
    private static int current = 0;
    private static NewsManager manager = null;
    public static NewsListModel loadNews(String category) throws IOException, NetworkErrorException { // category; num
        if(manager==null){
            manager = new NewsManager();
            manager.init();
        }
        if (category.equals("综合"))
            category = "";
        List<NewsData> ans = manager.loadMore(20,category);
        // Exception dealing
        /*
        if (nc.getException() != null) {
            if (nc.getException() instanceof IOException)
                throw (IOException)nc.getException();
            return new NewsListModel(new ArrayList<>());
        }
        return new NewsListModel(nc.getNl());*/
        return new NewsListModel(ans);
    }
    public static List<NewsData> loadMore(String category) throws IOException , NetworkErrorException { //
        if(manager==null){
            manager = new NewsManager();
            manager.init();
        }
        if (category.equals("综合"))
            category = "";
        /*
        String[] strlist = {"","","",""};
        NewsCrawler nc = new NewsCrawler(20,strlist);
        try{
            nc.start();
            nc.join();
        }catch(InterruptedException e){
            System.out.println("Thread Interrupted.");
        }
        current+=20;
        // Exception dealing
        if (nc.getException() != null) {
            if (nc.getException() instanceof IOException)
                throw (IOException)nc.getException();
            return new ArrayList<>();
        }*/
        return manager.loadNews(20,category);
    }
    public static List<NewsData> search(String[] keyWords, String category)throws IOException,NetworkErrorException{
        if(keyWords.length == 0){
            return new LinkedList<NewsData>();
        }
        if (category.equals("综合"))
            category = "";
        if(manager==null){
            manager = new NewsManager();
            manager.init();
        }
        return manager.search(keyWords, category);
    }
    //推荐相关
    public static List<NewsData> get_recommend(String user) throws IOException,NetworkErrorException{
        if(manager==null){
            manager = new NewsManager();
            manager.init();
        }
        return manager.get_recommend(user);
    }
    public static void read(NewsData a,String user) {
        if(manager==null){
            //manager = new NewsManager();
        }
        manager.read(a,user);
    }
    public static List<NewsData> get_read(String user){
        if(manager==null){
            manager = new NewsManager();
        }
        return manager.get_read(user);
    }
    public static List<NewsData> get_collection(String user){
        if(manager==null){
            manager = new NewsManager();
        }
        return manager.get_collection(user);
    }
    public static void delete_collect(NewsData a,String user){
        if(manager==null){
            manager = new NewsManager();
        }
        manager.deleteNews(a,user);
    }
    public static void add_collect(NewsData a,String user){
        if(manager==null){
            manager = new NewsManager();
        }
        manager.storeNews(a,user);
    }
    public static Bitmap getBitmap(String imgUrl) throws IOException, NetworkErrorException{
        try {
            //生成url
            URL url = new URL(imgUrl);
            //建立连接
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            //设置超时 5s
            connection.setConnectTimeout(5000);
            //设置请求方法
            connection.setRequestMethod("GET");
            //连接成功
            if (connection.getResponseCode()==200){
                //获取输入流
                InputStream in=connection.getInputStream();
                //将流转化为bitmap
                Bitmap bitmap= BitmapFactory.decodeStream(in);
                return bitmap;
            }
        } catch (IOException e) {
            e.printStackTrace();
            Log.d("NewsLoader", imgUrl);
            throw e;
        }
        throw new NetworkErrorException();
    }
    public static List<Bitmap> getBitmaps(String urls) {
        if (urls.length() <= 2) return Collections.emptyList();
        return getBitmaps(urls.substring(1, urls.length() - 1).split(","));
    }
    public static List<Bitmap> getBitmaps(String[] imgs) {
        ArrayList<Bitmap> ret = new ArrayList<>(imgs.length);
        ret.addAll(Collections.nCopies(imgs.length, null));
        Thread [] threads = new Thread[imgs.length];
        for (int i = 0; i < imgs.length; i++) {
            threads[i] = new Thread(getLoader(i, ret, imgs[i]));
            threads[i].start();
        }
        for (int i = 0; i < imgs.length; i++)
            try {
                threads[i].join();
            } catch (InterruptedException e) {}
        return ret;
    }
    private static Runnable getLoader(int i, ArrayList<Bitmap> ret, String url) {
        return ()->{
            try {
                ret.set(i, getBitmap(url));
            } catch (IOException | NetworkErrorException e) {
            }
        };
    }
    //
}
