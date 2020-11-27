package com.java.lidaixuan.newsclient.data;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import com.alibaba.fastjson.*;
import com.alibaba.fastjson.annotation.JSONField;

import java.util.Date;
import java.util.HashMap;

public class NewsData implements Parcelable {
    private static final int MAX_BRIEF_CHAR_NUM = 50;
    private String title;
    private String content;
    private String image;//图片内容URL
    private String releaseDate; //新闻放出的时间
    private HashMap<String,Double> keywordsMap = new HashMap<String, Double>();//关键词和相关值的Map
    private String video; //视频url
    public String newsID; //新闻的ID
    private String publisher;
    private String category;
    public String myjson;

    public NewsData(String jsonstr) {
        this(JSON.parseObject(jsonstr));
    }
    public NewsData(JSONObject obj){
        title = obj.getString("title");
        content = obj.getString("content");
        image = obj.getString("image");
        releaseDate = obj.getString("publishTime");
        JSONArray kwarray = JSON.parseArray(obj.getString("keywords"));
        for(int i = 0;i<kwarray.size();i++){
            JSONObject tmp = (JSONObject) kwarray.get(i);
            keywordsMap.put(tmp.getString("word"),Double.parseDouble(tmp.getString("score")));
        }
        video = obj.getString("vedio");
        newsID = obj.getString("newsID");
        publisher = obj.getString("publisher");
        category = obj.getString("category");
        myjson = JSON.toJSONString(obj);
    }

    public String getContent() {
        return content;
    }
    public String getTitle() {
        return title;
    }
    public String getReleaseDate() { return releaseDate; }
    public String getPublisher() { return publisher; }
    public String getImage() { return image; }
    public String getVideo() { return video; }
    public String getCategory() { return category; }
    public String getNewsID() { return newsID; }
    public HashMap<String, Double> getKeywords() { return keywordsMap; }

    public String getBrief() {
        return content.trim();
    }

    // Parcelable Interface
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(title);
        parcel.writeString(content);
        parcel.writeString(image);
        parcel.writeString(releaseDate);
        parcel.writeMap(keywordsMap);
        parcel.writeString(video);
        parcel.writeString(newsID);
        parcel.writeString(publisher);
        parcel.writeString(category);
        parcel.writeString(myjson);

    }

    public NewsData(Parcel parcel) {
        title = parcel.readString();
        content = parcel.readString();
        image = parcel.readString();
        releaseDate = parcel.readString();
        parcel.readMap(keywordsMap,Double.class.getClassLoader());
        video = parcel.readString();
        newsID = parcel.readString();
        publisher = parcel.readString();
        category = parcel.readString();
        myjson = parcel.readString();
    }

    public final static Parcelable.Creator<NewsData> CREATOR = new Parcelable.Creator<NewsData>() {
        public NewsData createFromParcel(Parcel in) {
            return new NewsData(in);
        }
        public NewsData[] newArray(int size) {
            return new NewsData[size];
        }
    };
}
