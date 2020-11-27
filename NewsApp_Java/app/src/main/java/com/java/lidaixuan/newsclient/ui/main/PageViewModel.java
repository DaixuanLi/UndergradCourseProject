package com.java.lidaixuan.newsclient.ui.main;

import android.arch.core.util.Function;
import android.arch.lifecycle.LiveData;
import android.arch.lifecycle.MutableLiveData;
import android.arch.lifecycle.Transformations;
import android.arch.lifecycle.ViewModel;

import com.java.lidaixuan.newsclient.util.ListMutableLiveData;
import com.java.lidaixuan.newsclient.data.NewsData;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class PageViewModel extends ViewModel {

    private boolean initialized;
    private MutableLiveData<Integer> mIndex = new MutableLiveData<>();
    private LiveData<String> mText = Transformations.map(mIndex, new Function<Integer, String>() {
        @Override
        public String apply(Integer input) {
            return "Hello world from section: " + input;
        }
    });
    private ListMutableLiveData<NewsData> mList = new ListMutableLiveData<>();
//    private MutableLiveData<List<NewsData>> mList = new MutableLiveData<>();
    private ListMutableLiveData<Boolean> mRead = new ListMutableLiveData<>();
//    private MutableLiveData<List<Boolean>> mRead = new MutableLiveData<>();

    public void setIndex(int index) {
        mIndex.setValue(index);
        init();
    }

    public LiveData<String> getText() {
        return mText;
    }

    public ListMutableLiveData<NewsData> getNewsList() {
        return mList;
    }

    public void setNewsList(List<NewsData> mList) {
        this.mList.setValue(mList);
    }

    public ListMutableLiveData<Boolean> getNewsRead() {
        return mRead;
    }

    public void setNewsRead(List<Boolean> mList) {
        this.mRead.setValue(mList);
    }
    public void setNewsReadAt(int pos, boolean val) {
        mRead.set(pos, val);
        /*
        List<Boolean> list = mRead.getValue();
        list.set(pos, val);
        mRead.setValue(list);
         */
    }
    public void setNewsReadAt(int pos) {
        setNewsReadAt(pos, true);
    }

    public PageViewModel() {
        super();
        initialized = false;
    }

    private void init() {
        if (initialized) return;
        initialized = true;
        setNewsList(new ArrayList<>());
        setNewsRead(new ArrayList<>());
    }

    void reset() {
        initialized = false;
        mList.clear();
        mRead.clear();
    }

    public int getIndex() {
        return mIndex.getValue();
    }
}