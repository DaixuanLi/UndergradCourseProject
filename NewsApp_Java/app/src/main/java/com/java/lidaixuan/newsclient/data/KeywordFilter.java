package com.java.lidaixuan.newsclient.data;

import java.util.ArrayList;
import java.util.List;

public class KeywordFilter {
    private static final KeywordFilter ourInstance = new KeywordFilter();

    public static KeywordFilter getInstance() {
        return ourInstance;
    }

    private ArrayList<String> keywords = new ArrayList<>();
    private KeywordFilter() {
    }

    public void addKeyword(String kw) {
        keywords.add(kw);
    }

    public ArrayList<NewsData> filter(List<NewsData> input) {
        ArrayList<NewsData> ret = new ArrayList<>();
        for (NewsData d: input) {
            if (!(new ArrayList<>(d.getKeywords().keySet())).removeAll(keywords))
                ret.add(d);
        }
        return ret;
    }
}
