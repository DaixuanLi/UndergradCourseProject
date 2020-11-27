package com.java.lidaixuan.newsclient.ui.favorite;

import android.arch.lifecycle.LiveData;
import android.arch.lifecycle.MutableLiveData;
import android.arch.lifecycle.ViewModel;

import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.util.ListMutableLiveData;

public class FavoriteViewModel extends ViewModel {

    private MutableLiveData<String> mText;
    private ListMutableLiveData<NewsData> mNews = new ListMutableLiveData<>();

    public FavoriteViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is favorite fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }

    public ListMutableLiveData<NewsData> getNewsList() {
        return mNews;
    }
}