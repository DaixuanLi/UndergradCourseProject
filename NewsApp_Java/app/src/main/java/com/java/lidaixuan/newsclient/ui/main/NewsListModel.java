package com.java.lidaixuan.newsclient.ui.main;

import android.arch.lifecycle.ViewModel;

import com.java.lidaixuan.newsclient.data.NewsData;

import java.util.List;

public class NewsListModel extends ViewModel {

    public enum StatusCode {OK, ERROR};

    private List<NewsData> mList;
    private StatusCode mStatus;

    public NewsListModel(List<NewsData> l) {
        mStatus = StatusCode.OK;
        mList = l;
    }

    public List<NewsData> getNewsList() {
        return mList;
    }
    public StatusCode getStatusCode() {
        return mStatus;
    }
    public void setStatusCode(StatusCode code) {
        mStatus = code;
    }
}
