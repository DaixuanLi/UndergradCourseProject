package com.java.lidaixuan.newsclient.ui.main;

import android.os.Handler;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;


public abstract class OnLoadMoreListener extends RecyclerView.OnScrollListener {
    protected abstract void onLoading(int countItem);
    private boolean scrolling;
    private boolean loading;

    @Override
    public void onScrollStateChanged(RecyclerView view, int newState) {
        scrolling = newState == RecyclerView.SCROLL_STATE_DRAGGING || newState == RecyclerView.SCROLL_STATE_SETTLING;
        loading = scrolling && loading;
    }

    @Override
    public void onScrolled(RecyclerView view, int dx, int dy) {
        if (!(view.getLayoutManager() instanceof LinearLayoutManager)) return;
        LinearLayoutManager layoutManager = (LinearLayoutManager)view.getLayoutManager();
        int curIndex = layoutManager.findLastVisibleItemPosition();
        int totalNum = view.getAdapter().getItemCount();
        if (scrolling && !loading && curIndex == totalNum - 1) {
            onLoading(totalNum);
            loading = true;
        }
    }
}
