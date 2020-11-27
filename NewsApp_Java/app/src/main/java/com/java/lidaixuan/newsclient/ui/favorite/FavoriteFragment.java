package com.java.lidaixuan.newsclient.ui.favorite;

import android.content.Intent;
import android.os.Bundle;
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
import com.java.lidaixuan.newsclient.ui.main.NewsListAdapter;
import com.java.lidaixuan.newsclient.ui.main.NewsListViewFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class FavoriteFragment extends Fragment {

    private FavoriteViewModel favoriteViewModel;
    private RecyclerView newsView;
    private NewsListAdapter newsAdapter;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        favoriteViewModel =
                ViewModelProviders.of(this).get(FavoriteViewModel.class);
        View root = inflater.inflate(R.layout.fragment_favorite, container, false);
        newsView = root.findViewById(R.id.favorite_news_list);
        newsAdapter = new NewsListAdapter(favoriteViewModel.getNewsList().getValue());
        newsAdapter.setNewsRead(new ArrayList<>()); // all false
        newsView.setAdapter(newsAdapter);
        // layout, animation and decoration
        newsView = NewsListViewFactory.factoryNewsListView(newsView);
        newsAdapter.setEnableLoadMore(false);
        favoriteViewModel.getNewsList().observe(this,
                NewsListViewFactory.factoryNewsListSetObserver(newsAdapter)
        );
        favoriteViewModel.getNewsList().setItemChangeListener(
                NewsListViewFactory.factoryNewsListChangeListener(newsAdapter)
        );
        newsAdapter.setOnItemClickListener((View v, int pos)->{
            // create new Activity
            Intent intent = new Intent(getContext(), NewsDetailActivity.class);
            NewsData data = favoriteViewModel.getNewsList().getValue().get(pos);
            intent.putExtra("data", data);
            getContext().startActivity(intent);
            // enter detail screen
        });
        // sync load data
        List <NewsData> data = NewsLoader.get_collection(LoginRepository.getLoggedInUserID());
        appendNews(data);
        return root;
    }

    @Override
    public void onResume() {
        //
        super.onResume();
        List<NewsData> list = NewsLoader.get_collection(LoginRepository.getLoggedInUserID());
        Collections.reverse(list);
        favoriteViewModel.getNewsList().setValue(list);
    }
    public void appendNews(List<NewsData> list) {
        Collections.reverse(list);
        favoriteViewModel.getNewsList().addAll(list);
    }
}