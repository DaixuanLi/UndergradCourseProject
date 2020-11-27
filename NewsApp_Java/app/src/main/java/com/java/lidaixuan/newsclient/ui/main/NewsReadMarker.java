package com.java.lidaixuan.newsclient.ui.main;

import com.java.lidaixuan.newsclient.data.NewsData;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;
import java.util.TreeSet;

class NewsReadMarker {
    private static TreeSet<String> newsID = new TreeSet<>();
    public static final void setRead(String id) {
        newsID.add(id);
    }
    public static final void setRead(Iterable<NewsData> data) {
        for (NewsData d: data) newsID.add(d.getNewsID());
    }

    public static final ArrayList<Boolean> getRead(List<String> strs) {
        ArrayList<Boolean> ret = new ArrayList<>(strs.size());
        for (String s : strs) ret.add(newsID.contains(s));
        return ret;
    }

    public static final ArrayList<Boolean> getReadByData(List<NewsData> data) {
        return getRead(fromDataToID(data));
    }

    public static final ArrayList<String> fromDataToID(List<NewsData> data) {
        ArrayList<String> ret = new ArrayList<>(data.size());
        for (NewsData s: data) ret.add(s.getNewsID());
        return ret;
    }
}
