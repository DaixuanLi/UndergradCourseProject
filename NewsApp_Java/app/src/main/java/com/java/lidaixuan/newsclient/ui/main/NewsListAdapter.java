package com.java.lidaixuan.newsclient.ui.main;

import android.accounts.NetworkErrorException;
import android.graphics.Bitmap;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.java.lidaixuan.newsclient.R;
import com.java.lidaixuan.newsclient.data.KeywordFilter;
import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.data.NewsLoader;
import com.java.lidaixuan.newsclient.database.UserDataBase;
import com.java.lidaixuan.newsclient.ui.TagButtonView;
import com.java.lidaixuan.newsclient.util.WarningTip;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Set;

public class NewsListAdapter extends RecyclerView.Adapter<NewsListAdapter.ViewHolder> {

    private boolean ready = false;
    private boolean enableLoading = true;

    public NewsListAdapter(List<NewsData> ns) {
        super();
        if (ns == null) {
            ns = Collections.emptyList();
        }
        this.mNews = ns;
        this.mRead = new ArrayList<>(ns.size());
    }


    public void setReady() {
        ready = true;
        notifyDataSetChanged();
    }
    public void reset() {
        ready = false;
        notifyDataSetChanged();
    }


    public void setEnableLoadMore(boolean enableLoading) {
        this.enableLoading = enableLoading;
    }

    public boolean getReady() {
        return ready;
    }

    public interface OnItemClickListener {
        void onItemClick(View view, int position);
    }

    private OnItemClickListener mClickListener;

    public void setOnItemClickListener(OnItemClickListener l) {
        mClickListener = l;
    }

    // View Holder
    static class ViewHolder extends RecyclerView.ViewHolder {
        public static String FOOTER = "footer";
        public static String ITEM = "item";
        public ViewHolder(View view, String type) {
            super(view);
        }
    }
    static class ItemViewHolder extends ViewHolder {

        private Collection<String> keywords;

        public ItemViewHolder(View view) { super(view, ITEM); }

        public void setTitle(String title) {
            TextView txtTitle = itemView.findViewById(R.id.text_title);
            txtTitle.setText(title);
        }
        public void setBrief(String abs) {
            TextView txtBrief = itemView.findViewById(R.id.text_abstract);
            txtBrief.setText(abs);
        }
        public void setSource(String abs) {
            TextView txtSource = itemView.findViewById(R.id.text_source);
            txtSource.setText(abs);
        }
        public void setImage(String urls) {
            ImageView imgv = itemView.findViewById(R.id.imageView);
            imgv.setImageBitmap(null);
            if (urls == null || urls.length() <= 2) {
                return;
            }
            String[] urlList = urls.substring(1, urls.length()-1).split(",");
            (new Thread(()->{
                try {
                    Bitmap bm = NewsLoader.getBitmap(urlList[0]);
                    itemView.post(()->{
                        ImageView imageView = itemView.findViewById(R.id.imageView);
                        imageView.setImageBitmap(bm);
                        imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                        imageView.setAdjustViewBounds(true);
                        int width = itemView.getMeasuredWidth();
                        //imageView.setLayoutParams(new LayoutParams);
                        imageView.setMaxWidth(width / 3);
                        imageView.setMaxHeight(width / 4);
                    });
                } catch (IOException | NetworkErrorException e) {
                    e.printStackTrace();
                }
            })).start();
        }
        public void setRead(boolean read) {
            TextView txtTitle = itemView.findViewById(R.id.text_title);
            if (read) txtTitle.setTextColor(txtTitle.getContext().getColor(R.color.read_grey));
            else txtTitle.setTextColor(txtTitle.getContext().getColor(R.color.text_black));
        }

        public void setKeywords(Collection<String> strings) {
            keywords = strings;
            Button ignore = itemView.findViewById(R.id.buttonIgnore);
            ignore.setOnClickListener((c)->{
                ((ViewGroup)itemView.findViewById(R.id.layout_brief)).addView(
                    TagButtonView.factoryTagButtonViewCheckable(
                        itemView.getContext(), new ArrayList<>(strings), (name)->{
                            KeywordFilter.getInstance().addKeyword(name);
                            WarningTip.showToastLong(ignore.getContext(), "已添加至屏蔽词");
                        }, 5
                    )
                );
            });
        }
    }
    static class LoadViewHolder extends ViewHolder {
        public LoadViewHolder(View view) { super(view, FOOTER); }
    }

    private List<NewsData> mNews;
    public void setNewsList(List<NewsData> l) {
        /*
        int _n = l.size() - mNews.size();
        if (_n > 0) mRead.addAll(Collections.nCopies(_n, false));
        else mRead = new*/
        mNews = l;
    }

    private List<Boolean> mRead;
    public void setNewsRead(List<Boolean> l) {
        mRead = l;
    }

    private final static int TYPE_CONTENT = 0;
    private final static int TYPE_FOOTER = 1;

    @Override
    public int getItemViewType(int position) {
        if (position==mNews.size()){
            return TYPE_FOOTER;
        }
        return TYPE_CONTENT;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        if (type == TYPE_CONTENT)
            return new ItemViewHolder(inflater.inflate(R.layout.news_brief, viewGroup, false));
        else
            return new LoadViewHolder(inflater.inflate(R.layout.news_bottom_loading, viewGroup, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder viewHolder, int i) {
        // news brief
        if (getItemViewType(i) == TYPE_CONTENT) {
            ItemViewHolder ivh = (ItemViewHolder)viewHolder;
            NewsData data = mNews.get(i);
            ivh.setTitle(data.getTitle());
            ivh.setBrief(data.getBrief());
            ivh.setSource(data.getPublisher() + " " + data.getReleaseDate());
            ivh.setRead(mRead != null && i < mRead.size() && mRead.get(i));
            ivh.setImage(data.getImage());
            ivh.setKeywords(data.getKeywords().keySet());
            //viewHolder.itemView.setImage(mNews.get(i).getImage());
            ivh.itemView.setOnClickListener((View v) -> {
                // click event
                if (mClickListener != null) {
                    mClickListener.onItemClick(viewHolder.itemView, viewHolder.getLayoutPosition());
                }
            });
        } else { // load
        }
    }

    @Override
    public int getItemCount() {
        if (mNews.size() == 0) return 0;
        return mNews.size() + (ready && enableLoading ? 1 : 0) ;
    }

}

