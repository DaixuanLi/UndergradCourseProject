package com.java.lidaixuan.newsclient.ui.history;

import android.arch.lifecycle.LiveData;
import android.arch.lifecycle.MutableLiveData;
import android.arch.lifecycle.ViewModel;
import android.widget.NumberPicker;

import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.util.ListMutableLiveData;

public class HistoryViewModel extends ViewModel {

    private MutableLiveData<String> mText;
    private ListMutableLiveData<NewsData> mNews = new ListMutableLiveData<>();

    public HistoryViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is history fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }

    public ListMutableLiveData<NewsData> getNewsList() {
        return mNews;
    }
}