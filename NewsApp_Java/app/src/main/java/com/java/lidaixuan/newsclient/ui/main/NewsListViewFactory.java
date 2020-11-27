package com.java.lidaixuan.newsclient.ui.main;

import android.arch.lifecycle.Observer;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.java.lidaixuan.newsclient.NewsDetailActivity;
import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.util.ListMutableLiveData;

import java.util.List;

public final class NewsListViewFactory {

    public static RecyclerView factoryNewsListView(RecyclerView newsView) {
        newsView.setLayoutManager(new LinearLayoutManager(newsView.getContext()));
        newsView.setItemAnimator(new DefaultItemAnimator());
        newsView.addItemDecoration(new DividerItemDecoration(newsView.getContext(), DividerItemDecoration.VERTICAL));
        return newsView;
    }

    public static Observer<List<NewsData>> factoryNewsListSetObserver(NewsListAdapter newsAdapter) {
        return (@Nullable List<NewsData> newsList) ->{
            // Status code
            newsAdapter.setNewsList(newsList);
            newsAdapter.notifyDataSetChanged();
        };
    }

    public static Observer<List<Boolean>> factoryNewsReadSetObserver(NewsListAdapter newsAdapter) {
        return (@Nullable List<Boolean> list) ->{
            // Status code
            newsAdapter.setNewsRead(list);
            newsAdapter.notifyDataSetChanged();
        };
    }

    public static ListMutableLiveData.OnItemChangeListener factoryNewsListChangeListener(NewsListAdapter newsAdapter) {
        return new ListMutableLiveData.OnItemChangeListener() {
            @Override
            public void onAddItemAt(int pos) {
                newsAdapter.notifyItemInserted(pos);
            }

            @Override
            public void onRangeAddItem(int st, int end) { newsAdapter.notifyItemRangeInserted(st, end - st); }

            @Override
            public void onChangeItemAt(int pos) {
                newsAdapter.notifyItemChanged(pos);
            }

            @Override
            public void onRemoveItemAt(int pos) {
                newsAdapter.notifyItemRemoved(pos);
            }

            @Override
            public void onRangeRemoveItem(int st, int end) { newsAdapter.notifyItemRangeRemoved(st, end - st); }
        };
    }

    public static ListMutableLiveData.OnItemChangeListener factoryNewsReadChangeListener(NewsListAdapter newsAdapter) {
        return new ListMutableLiveData.OnItemChangeListener() {
            @Override
            public void onAddItemAt(int pos) { }

            @Override
            public void onRangeAddItem(int st, int end) { }

            @Override
            public void onChangeItemAt(int pos) {
                newsAdapter.notifyItemChanged(pos);
            }

            @Override
            public void onRemoveItemAt(int pos) { }

            @Override
            public void onRangeRemoveItem(int st, int end) { }
        };
    }

    /*
    public static NewsListAdapter.OnItemClickListener factoryOpenNewsDetail(Context context) {
        return (View v, int pos)->{
            // create new Activity
            Intent intent = new Intent(context, NewsDetailActivity.class);
            intent.putExtra("data", pageViewModel.getNewsList().getValue().get(pos));
            context.startActivity(intent);
            pageViewModel.setNewsReadAt(pos);
            // enter detail screen
        }
    }

     */
}
