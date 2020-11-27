package com.java.lidaixuan.newsclient.data;

import android.accounts.NetworkErrorException;
import android.widget.Toast;

import com.alibaba.fastjson.JSON;
import com.java.lidaixuan.newsclient.database.NewsDataBase;
import com.java.lidaixuan.newsclient.network.NetworkStatusChecker;
import com.java.lidaixuan.newsclient.network.NewsCrawler;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

public class CategoryNewsManager {
    String my_category = null;
    NewsDataBase db = null;
    LinkedList<NewsData> curnews = new LinkedList<NewsData>();
    long last_refresh_time = -1;
    long latest_refresh_time = -1;
    int tot_num = 0;//总的新闻数量 所有新闻按时间顺序从最近到最远排列
    int current_head = 0;//已经显示的新闻头位置
    int current_tail = 0;//已经显示的新闻尾位置
    private SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);

    CategoryNewsManager(String category) throws IOException,NetworkErrorException{
        my_category = category;
        db = new NewsDataBase();
        init();
    }
    private void init() throws IOException,NetworkErrorException{
        Date current = new Date();
        if(last_refresh_time == -1){
            last_refresh_time = current.getTime() - (long)360000000;
        }
        if(latest_refresh_time == -1){
            latest_refresh_time = current.getTime() - (long)360000000;
        }
        downloadmore();
        current_head = tot_num/2;
        current_tail = current_head;
    }
    public List<NewsData> request(int size,String a,String b,String c,String d) throws IOException,NetworkErrorException{
        if(NetworkStatusChecker.isNetworkAvailable()){
            String[] strlist = {a,b,c,d};
            NewsCrawler nc = new NewsCrawler(size,strlist);
            try{
                nc.start();
                nc.join();
            }catch(InterruptedException e){
                System.out.println("Thread Interrupted.");
            }
            List<NewsData> nl = nc.getNl();
            if (nc.getException() != null) {
                if (nc.getException() instanceof IOException)
                    throw (IOException)nc.getException();
                return nl;
            }
            return nl;
        }
        else{
            throw new NetworkErrorException();
        }

    }
    public void downloadmore() throws IOException,NetworkErrorException{
        List<NewsData> nl = request(100,sdf.format(new Date(last_refresh_time)),sdf.format(last_refresh_time+3600000),"",my_category);
        last_refresh_time+=3600000;
        for(int i = nl.size()-1;i>=0;i--){
            curnews.addFirst(nl.get(i));
        }
        tot_num+=nl.size();
        current_head+=nl.size();
        current_tail+=nl.size();
    }
    public void downloadmore_back() throws IOException,NetworkErrorException{
        List<NewsData> nl = request(100,sdf.format(new Date(latest_refresh_time-3600000)),sdf.format(new Date(latest_refresh_time)),"",my_category);
        latest_refresh_time -= 3600000;
        for(int i = nl.size()-1;i>=0;i--){
            curnews.addLast(nl.get(i));
        }
        tot_num+=nl.size();
    }
    public List<NewsData> getNews(int maxnum)throws IOException,NetworkErrorException{
        int tail = current_tail+maxnum<=tot_num?current_tail+maxnum:tot_num;
        if(tail == current_tail){
            downloadmore_back();
        }
        tail = current_tail+maxnum<=tot_num?current_tail+maxnum:tot_num;
        List<NewsData> ans = curnews.subList(current_tail,tail);
        current_tail = tail;
        return ans;
    }
    public List<NewsData> loadMore(int maxnum) throws IOException,NetworkErrorException{
        if(current_head-maxnum<0){
            downloadmore();
        }
        int head = current_head-maxnum>=0?current_head-maxnum:0;
        List<NewsData> ans = curnews.subList(head,current_head);
        current_head = head;
        return ans;
    }
    /*
    public void storeNow(){
        int len = Math.max(curnews.size(),200);
        String[] newsToStore = new String[len];
        for(int i = 0;i<len;i++){
            newsToStore[i] = curnews.get(i).myjson;
        }
        db.storeNews(newsToStore);
    }*/
}

