package com.java.lidaixuan.newsclient.ui.main;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.arch.lifecycle.ViewModelProviders;

import com.java.lidaixuan.newsclient.NewsDetailActivity;
import com.java.lidaixuan.newsclient.R;
import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.data.NewsLoader;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * A placeholder fragment containing a simple view.
 */
public class PlaceholderFragment extends Fragment {

    private static final String ARG_SECTION_NUMBER = "section_number";
    private static final String ARG_NEWS_DATA = "news_data";

    private PageViewModel pageViewModel;
    private OnLoadMoreListener mLoadMoreListener;
    private boolean loading;

    public boolean getLoading() {
        return loading;
    }

    public interface OnRefreshListener {
        void onRefresh(Runnable callback);
    }
    private OnRefreshListener mRefreshListener;
    public void setRefreshListener(OnRefreshListener mRefreshListener) {
        this.mRefreshListener = mRefreshListener;
    }

    private NewsListAdapter newsAdapter;

    private SwipeRefreshLayout swipeRefreshLayout;
    private RecyclerView newsView;

    private static ArrayList<PlaceholderFragment> fragments = new ArrayList<>();

    public static PlaceholderFragment newInstance(int index) {
        PlaceholderFragment fragment = /*null;
        if (fragments.size() >= index) fragment = fragments.get(index-1);
        else {
            fragment = */new PlaceholderFragment();
        Bundle bundle = new Bundle();
        bundle.putInt(ARG_SECTION_NUMBER, index);
        fragment.setArguments(bundle);
           // fragments.add(index-1, fragment);
        //}
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        pageViewModel = ViewModelProviders.of(this).get(PageViewModel.class);
        int index = 1;
        if (getArguments() != null) {
            index = getArguments().getInt(ARG_SECTION_NUMBER);
            //news_list = getArguments().getParcelable(ARG_NEWSLIST_MODEL);
        }
        // set the index of categories, and initialize altogether.
        pageViewModel.setIndex(index);
    }

    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_main, container, false);
        newsView = root.findViewById(R.id.view_news_list);
        newsAdapter = new NewsListAdapter(pageViewModel.getNewsList().getValue());
        newsAdapter.setNewsRead(pageViewModel.getNewsRead().getValue());
        newsView.setAdapter(newsAdapter);
        // layout, animation and decoration
        newsView = NewsListViewFactory.factoryNewsListView(newsView);
        // Refresh by scroll down
        initRefresh(root);
        // Load more by scroll up
        newsView.addOnScrollListener(mLoadMoreListener);
        newsAdapter.setEnableLoadMore(true);
        // on data change, notify the adapter to refresh
        pageViewModel.getNewsList().observe(this,
                NewsListViewFactory.factoryNewsListSetObserver(newsAdapter)
        );
        pageViewModel.getNewsList().setItemChangeListener(
                NewsListViewFactory.factoryNewsListChangeListener(newsAdapter)
        );
        pageViewModel.getNewsRead().observe(this,
                NewsListViewFactory.factoryNewsReadSetObserver(newsAdapter)
        );
        pageViewModel.getNewsRead().setItemChangeListener(
                NewsListViewFactory.factoryNewsReadChangeListener(newsAdapter)
        );
        newsAdapter.setOnItemClickListener((View v, int pos)->{
            // create new Activity
            Intent intent = new Intent(getContext(), NewsDetailActivity.class);
            NewsData data = pageViewModel.getNewsList().getValue().get(pos);
            intent.putExtra("data", data);
            // enter detail screen
            getContext().startActivity(intent);
            pageViewModel.setNewsReadAt(pos);
            NewsReadMarker.setRead(data.getNewsID());
            NewsLoader.read(data, LoginRepository.getLoggedInUserID());
        });
        return root;
    }

    @Override
    public void onSaveInstanceState(Bundle bundle) {
    }

    public void initRefresh(View root) {
        swipeRefreshLayout = root.findViewById(R.id.refresh_layout);
        swipeRefreshLayout.setColorSchemeColors(
                getContext().getColor(android.R.color.holo_blue_light),
                getContext().getColor(android.R.color.holo_green_dark),
                getContext().getColor(android.R.color.holo_orange_dark)
        );
        Handler handler = new Handler();
        swipeRefreshLayout.setOnRefreshListener(()->{
            if (mRefreshListener != null)
                mRefreshListener.onRefresh(()->{
                    handler.post(()->swipeRefreshLayout.setRefreshing(false));
                });
        });
    }

    /**
     * News loading complete
     */
    public void setReady() {
        if (swipeRefreshLayout != null) {
            swipeRefreshLayout.setRefreshing(false);
        }
        if (newsAdapter != null) {
            newsAdapter.setReady();
        }
        loading = false;
    }

    /**
     * Nothing to show due to network fail, etc.
     * @param message
     */
    public void setFail(String message) {
        if (swipeRefreshLayout != null)
            swipeRefreshLayout.setRefreshing(false);
    }

    public boolean getReady() {
        return newsAdapter.getReady();
    }

    public void setLoading() {
        (new Handler()).postAtFrontOfQueue(()-> swipeRefreshLayout.setRefreshing(true));
        loading = true;
    }

    public void setLoadMoreListener(OnLoadMoreListener mLoadMoreListener) {
        this.mLoadMoreListener = mLoadMoreListener;
    }

    public void reset() {
        loading = false;
        newsAdapter.reset();
        swipeRefreshLayout.setRefreshing(false);
        pageViewModel.reset();
    }

    public PageViewModel getPageViewModel() {
        return pageViewModel;
    }

    /**
     * This function should be called in an async way.
     * If it is called directly by onScroll, an error will occur at 'notifyDataSetChanged()'.
     * @param list
     */
    public void appendNews(List<NewsData> list) {
        appendNews(list, Collections.nCopies(list.size(), false));
        //pageViewModel.getNewsList().addAll(list);
    }
    public void appendNews(List<NewsData> list, List<Boolean> read) {
        pageViewModel.getNewsList().addAll(list);
        pageViewModel.getNewsRead().addAll(read);
    }

    public void frontNews(List<NewsData> list, List<Boolean> read) {
        pageViewModel.getNewsList().addAll(0, list);
        pageViewModel.getNewsRead().addAll(0, read);
        newsView.scrollToPosition(0);
    }
    public void clearNews() {
        pageViewModel.getNewsRead().clear();
        pageViewModel.getNewsList().clear();
    }
}