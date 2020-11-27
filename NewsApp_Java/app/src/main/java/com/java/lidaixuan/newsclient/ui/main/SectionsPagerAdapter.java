package com.java.lidaixuan.newsclient.ui.main;

import android.accounts.NetworkErrorException;
import android.content.Context;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.java.lidaixuan.newsclient.R;
import com.java.lidaixuan.newsclient.data.KeywordFilter;
import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.data.NewsData;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.java.lidaixuan.newsclient.data.NewsLoader;
import com.java.lidaixuan.newsclient.util.CategoriesHelper;
import com.java.lidaixuan.newsclient.util.WarningTip;

/**
 * A [FragmentPagerAdapter] that returns a fragment corresponding to
 * one of the sections/tabs/pages.
 */
public class SectionsPagerAdapter extends FragmentStatePagerAdapter {

    @StringRes
    private static final int[] TAB_TITLES = new int[]{R.string.tab_text_1, R.string.tab_text_2};
    private ArrayList<String> tabTitles;
    private final Context mContext;
    private Handler handler; // support async call
    private String query;

    private ArrayList<PlaceholderFragment> fragments;
    private String mUserName = "admin";

    public SectionsPagerAdapter(Context context, FragmentManager fm, String query) {
        super(fm);
        handler = new Handler();
        mContext = context;
        this.query = query;
        tabTitles = CategoriesHelper.getUserCategories(mUserName);
        fragments = new ArrayList<>(Collections.nCopies(tabTitles.size(), null));
        NewsReadMarker.setRead(NewsLoader.get_read(LoginRepository.getLoggedInUserID()));
    }

    @Override
    public Fragment getItem(int position) {
        // getItem is called to instantiate the fragment for the given page.
        // Return a PlaceholderFragment (defined as a static inner class below).
        //NewsListModel news = NewsLoader.loadNews(position);
        if (position < fragments.size() && fragments.get(position) != null) return fragments.get(position);
        PlaceholderFragment fragment = PlaceholderFragment.newInstance(position + 1);
        fragment.setLoadMoreListener(new OnLoadMoreListener() {
            @Override
            protected void onLoading(int totalNum) {
            // when empty, popup a warning
            getNewsLoadMoreWorker(fragment, position, ()->{}, ()->{}).start();
            }
        });
        fragment.setRefreshListener((callback)->{
            //getNewsLoaderWorker(fragment, position, fragment::clearNews, callback::run).start();
            getNewsLoaderWorker(fragment, position, ()->{}, callback::run).start();
        });
        fragments.set(position, fragment);
        if (position == 0)
            startLoading(fragment, position);
        return fragment;
    }

    @Override
    public int getItemPosition(Object object) {
        return POSITION_NONE;
    }

    public void startLoading(int i) {
        PlaceholderFragment fragment = fragments.get(i);
        if (fragment == null || fragment.getLoading() || fragment.getReady()) return; // if already loading and not complete, abort the operation
        fragment.setLoading();
        Thread loadNew = getNewsLoaderWorker(fragment, i, ()->{}, fragment::setReady);
        loadNew.start();
    }

    protected void startLoading(PlaceholderFragment fragment, int i) {
        if (fragment.getLoading()) return; // if already loading and not complete, abort the operation
        fragment.setLoading();
        Thread loadNew = getNewsLoaderWorker(fragment, i, ()->{}, fragment::setReady);
        loadNew.start();
    }

    private Thread getNewsLoaderWorker(PlaceholderFragment fragment, int pos, Runnable before, Runnable after) {
        return getNewsLoaderWorker(fragment, pos, before, after, false);
    }
    private Thread getNewsLoadMoreWorker(PlaceholderFragment fragment, int pos, Runnable before, Runnable after) {
        return getNewsLoaderWorker(fragment, pos, before, after, true);
    }
    private Thread getNewsLoaderWorker(PlaceholderFragment fragment, int pos, Runnable before, Runnable after, boolean more) {
        return new Thread(()->{
            Runnable network_error = () -> {
                if (fragment.getView() != null)
                    WarningTip.showSnackbarLong(fragment.getView(), R.string.msg_error_network);
                else WarningTip.showToastLong(fragment.getContext(), R.string.msg_error_network);
                fragment.setFail("");
            };
            try {


                String category = tabTitles.get(pos);
                List<NewsData> news_list;
                if (!query.equals(""))
                    news_list = NewsLoader.search(new String[]{query}, category);
                else if (category.equals("推荐"))
                    news_list = NewsLoader.get_recommend(LoginRepository.getLoggedInUserID());
                else
                    news_list = more ? NewsLoader.loadMore(category) :
                            NewsLoader.loadNews(category).getNewsList();

                /*for(NewsData dt:news_list){
                    Log.d("!",dt.getImage());
                }*/
                List<NewsData> filtered_news_list = KeywordFilter.getInstance().filter(news_list);
                // Locally stored news show be marked as 'read'
                List<Boolean> read_list = NewsReadMarker.getReadByData(filtered_news_list);
                handler.post(()->{
                    before.run();
                    if (more) fragment.appendNews(filtered_news_list, read_list);
                    else fragment.frontNews(filtered_news_list, read_list);
                    after.run();
                });
                if (filtered_news_list.size() == 0)
                    WarningTip.showSnackbarLong(fragment.getView(), "已经没有更新的新闻了");
            } catch (NetworkErrorException e) {
                handler.post(network_error);
            } catch (IOException e) {
                handler.post(network_error);
            }
        });
    }

    @Nullable
    @Override
    public CharSequence getPageTitle(int position) {
        return tabTitles.get(position);
    }

    @Override
    public int getCount() {
        return tabTitles.size();
    }

    public void setUserName(String name) {
        mUserName = name;
        tabTitles = CategoriesHelper.getUserCategories(mUserName);
        fragments.clear();
        fragments.addAll(Collections.nCopies(tabTitles.size(), null));
    }
}

