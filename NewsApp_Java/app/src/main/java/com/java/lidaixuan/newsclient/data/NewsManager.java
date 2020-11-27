package com.java.lidaixuan.newsclient.data;

import android.accounts.NetworkErrorException;
import android.widget.Toast;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.java.lidaixuan.newsclient.database.NewsDataBase;
import com.java.lidaixuan.newsclient.database.NewsDatabaseHelper;
import com.java.lidaixuan.newsclient.database.SyncManager;
import com.java.lidaixuan.newsclient.network.NetworkStatusChecker;
import com.java.lidaixuan.newsclient.network.NewsCrawler;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
//根据与关键词的相关度来进行排序
class NewsComparator implements Comparator<NewsData>{
    String keyword = null;
    NewsComparator(String keyword){
        super();
        this.keyword = keyword;
    }
    @Override
    public int compare(NewsData a,NewsData b){
        Double c = a.getKeywords().get(keyword);
        Double d = b.getKeywords().get(keyword);
        if(c == null){
            c=0.0;
        }
        if(d == null){
            d=0.0;
        }
        return c.compareTo(d);
    }
}

class MyKeyWord{
    double score;
    String data;
    MyKeyWord(String data,double score){
        this.data = data;
        this.score = score;
    }
    void add(double offset){
        score += offset;
    }
}

class keyComparator implements Comparator<MyKeyWord>{
    @Override
    public int compare(MyKeyWord a,MyKeyWord b){
        return Double.compare(b.score,a.score);
    }
}

public class NewsManager {
    String user = "admin";
    NewsDataBase db = null;
    LinkedList<NewsData> curnews = new LinkedList<NewsData>();
    long last_refresh_time = -1;
    long latest_refresh_time = -1;
    int tot_num = 0;//总的新闻数量 所有新闻按时间顺序从最近到最远排列
    int current_head = 0;//已经显示的新闻头位置
    int current_tail = 0;//已经显示的新闻尾位置
    private SimpleDateFormat sdf= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);
    // 分类管理相关
    LinkedList<String> categories = new LinkedList<String>();
    HashMap<String,CategoryNewsManager> category_managers = new HashMap<String,CategoryNewsManager>();
    HashMap<String,LinkedList<NewsData>> search_table = new HashMap<String,LinkedList<NewsData>>();
    NewsManager(String user) throws IOException,NetworkErrorException{
        String[] cates = new String[]{"娱乐","军事","教育","文化","健康","财经","体育","汽车","科技","社会"};
        for(String name:cates){
            categories.addLast(name);
        }
        this.user = user;
        db = new NewsDataBase();
        init();
    }
    //收藏
    static int count = 0;
    public void storeNews(NewsData a,String user){
        if(user != this.user || count > 5){
            syncUpCollection(this.user);
            count = -1;
            if(user != this.user){
                syncDownCollection(user);
            }
        }
        this.user = user;
        db.storeANews(a.myjson,a.newsID,user+"collection");
        count++;
    }
    public void raw_storeNews(NewsData a,String user){
        db.storeANews(a.myjson,a.newsID,user+"collection");
    }
    public void deleteNews(NewsData a,String user){
        if(user != this.user|| count > 5){
            syncUpCollection(this.user);
            if(user != this.user){
                syncDownCollection(user);
            }
            count = -1;
        }
        this.user = user;
        db.deleteANews(a.myjson,a.newsID,user+"collection");
        count++;
    }
    public List<NewsData> get_collection(String user){
        if(user != this.user|| count > 5){
            syncUpCollection(this.user);
            if(user != this.user){
                syncDownCollection(user);
            }
            count = 0;
        }
        this.user = user;
        String[] a = db.loadNews(user + "collection");
        LinkedList<NewsData> b = new LinkedList<NewsData>();
        for(String news:a){
            b.add(new NewsData(JSON.parseObject(news)));
        }
        return b;
    }
    private void syncUpCollection(String user){
        String[] newses = db.loadNews(user + "collection");
        StringBuilder finalstr = new StringBuilder("[");
        for(String news:newses){
            finalstr.append(news+",");
        }
        if(finalstr.length()>1){
            finalstr.delete(finalstr.length()-1,finalstr.length());
        }
        finalstr.append("]");
        String uploadStr = finalstr.toString();
        SyncManager.SyncUpCollection(user,uploadStr);
    }
    private void syncDownCollection(String user){
        String raw = SyncManager.SyncDownCollection(user);
        JSONArray tmp = JSON.parseArray(raw);
        if(tmp.size()>=1){
            db.deleteAll(user+"collection");
        }
        for(Object item:tmp){
            JSONObject cur = (JSONObject) item;
            raw_storeNews(new NewsData(cur),user);
        }
    }
    //推荐相关
    HashMap<String,LinkedList<MyKeyWord>> recommend_table = new HashMap<String,LinkedList<MyKeyWord>>();
    HashMap<String,HashMap<String,MyKeyWord>> keyobj_table = new HashMap<String,HashMap<String,MyKeyWord>>();
    public void read(NewsData in,String user){
        if(!recommend_table.containsKey(user)){
            recommend_table.put(user,new LinkedList<MyKeyWord>());
        }
        if(!keyobj_table.containsKey(user)){
            keyobj_table.put(user,new HashMap<String,MyKeyWord>());
        }
        LinkedList<MyKeyWord> my_rectable = recommend_table.get(user);
        HashMap<String,MyKeyWord> my_kobj_table = keyobj_table.get(user);
        for(String keyword:in.getKeywords().keySet()){
            if(!my_kobj_table.containsKey(keyword)){
                my_kobj_table.put(keyword,new MyKeyWord(keyword,0));
                my_rectable.add(my_kobj_table.get(keyword));
            }
            my_kobj_table.get(keyword).add(in.getKeywords().get(keyword));
        }
        db.storeANews(in.myjson,in.newsID,user);
    }
    public List<NewsData> get_read(String user){
        String[] ans = db.loadNews(user);
        LinkedList<NewsData> b = new LinkedList<NewsData>();
        for(String news:ans){
            b.add(new NewsData(JSON.parseObject(news)));
        }
        return b;
    }
    public List<NewsData> get_recommend(String user) throws NetworkErrorException{
        if(!recommend_table.containsKey(user)){
            recommend_table.put(user,new LinkedList<MyKeyWord>());
        }
        if(!keyobj_table.containsKey(user)){
            keyobj_table.put(user,new HashMap<String,MyKeyWord>());
        }
        LinkedList<MyKeyWord> my_rectable = recommend_table.get(user);
        my_rectable.sort(new keyComparator());
        int len = Math.min(3,my_rectable.size());
        List<NewsData> ans = new LinkedList<NewsData>();
        for(int i = 0;i<len;i++){
            if(NetworkStatusChecker.isNetworkAvailable()){
                String[] strlist = {"","",my_rectable.get(i).data,""};
                strlist[1] = sdf.format(new Date());
                NewsCrawler nc = new NewsCrawler(20,strlist);
                try{
                    nc.start();
                    nc.join();
                }catch(InterruptedException e){
                    System.out.println("Thread Interrupted.");
                }
                List<NewsData> nl = nc.getNl();
                ans.addAll(nl);
            }
            else{
                throw new NetworkErrorException();
            }
        }
        Collections.shuffle(ans);
        return ans;
    }
    public void InsertIntoTable(List<NewsData> newses){
        for(NewsData news:newses){
            HashMap<String,Double> keywordTable = news.getKeywords();
            for(String keyword:keywordTable.keySet()){
                if(search_table.containsKey(keyword)){
                    search_table.get(keyword).add(news);
                }
                else{
                    search_table.put(keyword,new LinkedList<NewsData>());
                    search_table.get(keyword).add(news);
                }
            }
        }
    }
    private void sortTable(String keyword){
        if(search_table.containsKey(keyword)){
            search_table.get(keyword).sort(new NewsComparator(keyword));
        }
    }
    //查找接口
    public List<NewsData> search(String keyword, String category)throws NetworkErrorException{
        List<NewsData> ans = new LinkedList<NewsData>();
        if(NetworkStatusChecker.isNetworkAvailable()){
            String[] strlist = {"","",keyword,category};
            strlist[1] = sdf.format(new Date());
            NewsCrawler nc = new NewsCrawler(20,strlist);
            try{
                nc.start();
                nc.join();
            }catch(InterruptedException e){
                System.out.println("Thread Interrupted.");
            }
            List<NewsData> nl = nc.getNl();
            ans = nl;
        }
        else{
            throw new NetworkErrorException();
        }
        return ans;
    }
    public List<NewsData> search(String[] keywords, String category)throws NetworkErrorException{
        List<NewsData> ans = new LinkedList<NewsData>();
        for(String keyword:keywords){
            List<NewsData> tmp = search(keyword, category);
            if(tmp != null) {
                ans.addAll(tmp);
            }
        }
        Collections.shuffle(ans);
        return ans;
    }
    NewsManager(){//throws IOException,NetworkErrorException{
        String[] cates = new String[]{"娱乐","军事","教育","文化","健康","财经","体育","汽车","科技","社会"};
        for(String name:cates){
            categories.addLast(name);
        }
        db = new NewsDataBase();
        Date current = new Date();
        if(last_refresh_time == -1){
            last_refresh_time = current.getTime() - (long)360000000;
        }
        if(latest_refresh_time == -1){
            latest_refresh_time = current.getTime() - (long)360000000;
        }
        //init();
    }
    protected void init()throws IOException,NetworkErrorException{
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
        Date current = new Date();
        List<NewsData> nl = request(100,sdf.format(new Date(last_refresh_time)),sdf.format(last_refresh_time+36000000),"","");
        last_refresh_time+=36000000;
        for(int i = nl.size()-1;i>=0;i--){
            curnews.addFirst(nl.get(i));
        }
        InsertIntoTable(nl);
        tot_num+=nl.size();
        current_head+=nl.size();
        current_tail+=nl.size();

    }
    public void downloadmore_back() throws IOException,NetworkErrorException{
        List<NewsData> nl = request(100,sdf.format(new Date(latest_refresh_time-36000000)),sdf.format(new Date(latest_refresh_time)),"","");
        InsertIntoTable(nl);
        latest_refresh_time -= 36000000;
        for(int i = nl.size()-1;i>=0;i--){
            curnews.addLast(nl.get(i));
        }
        tot_num+=nl.size();
    }
    public List<NewsData> getNews(int maxnum,String category) throws IOException,NetworkErrorException {
        List<NewsData> ans = null;
        if(categories.contains(category)){
            if(!category_managers.containsKey(category)){
                category_managers.put(category,new CategoryNewsManager(category));
            }
            ans = category_managers.get(category).getNews(maxnum);
        }else{
            downloadmore();
            int tail = current_tail+maxnum<=tot_num?current_tail+maxnum:tot_num;
            ans = curnews.subList(current_tail,tail);
            current_tail = tail;
        }
        return ans;
    }
    public List<NewsData> loadNews(int maxnum,String category) throws IOException,NetworkErrorException{
        List<NewsData> ans = null;
        if(categories.contains(category)){
            if(!category_managers.containsKey(category)){
                category_managers.put(category,new CategoryNewsManager(category));
            }
            ans = category_managers.get(category).getNews(maxnum);
        }else{
            if(current_tail+maxnum>tot_num){
                downloadmore_back();
            }
            int tail = current_tail+maxnum<=tot_num?current_tail+maxnum:tot_num;
            ans = curnews.subList(current_tail,tail);
            current_tail = tail;
        }
        return ans;
    }
    public List<NewsData> loadMore(int maxnum,String category) throws IOException,NetworkErrorException{
        List<NewsData> ans = null;
        if(categories.contains(category)){
            if(!category_managers.containsKey(category)){
                category_managers.put(category,new CategoryNewsManager(category));
            }
            ans = category_managers.get(category).loadMore(maxnum);
        }else{
            if(current_head-maxnum<0){
                downloadmore();
            }
            int head = current_head-maxnum>=0?current_head-maxnum:0;
            ans = curnews.subList(head,current_head);
            current_head = head;
        }
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
