package com.java.lidaixuan.newsclient;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.VideoView;

import com.java.lidaixuan.newsclient.data.KeywordFilter;
import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.data.NewsData;
import com.java.lidaixuan.newsclient.data.NewsLoader;
import com.java.lidaixuan.newsclient.data.ShareManager;
import com.java.lidaixuan.newsclient.ui.TagButtonView;
import com.java.lidaixuan.newsclient.util.WarningTip;
import com.java.lidaixuan.newsclient.database.NewsDatabaseHelper;
import com.java.lidaixuan.newsclient.database.UserDataBaseHelper;

import java.util.ArrayList;
import java.util.List;

public class NewsDetailActivity extends AppCompatActivity {

    private NewsData data;
    private List<Bitmap> bitmaps;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news_detail);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        Intent intent = getIntent();
        data = intent.getParcelableExtra("data");
        ((TextView)findViewById(R.id.textNewsTitle)).setText(data.getTitle());
        ((TextView)findViewById(R.id.textInformation)).setText(data.getPublisher() + " " + data.getReleaseDate());
        ((TextView)findViewById(R.id.textBody)).setText(data.getContent());
        UserDataBaseHelper.setUpInstance(this);
        NewsDatabaseHelper.setUpInstance(this);
        List<NewsData> list = NewsLoader.get_collection(LoginRepository.getLoggedInUserID());
        for (NewsData d: list)
            if (d.getNewsID().equals(data.getNewsID()))
                tempFavorite = true;
        LinearLayout linearLayout = findViewById(R.id.layout_imgs_video);
        VideoView videoView = new VideoView(this);
        if (data.getVideo() != null && data.getVideo().length() > 0) {
            Log.v(getClass().getName(), data.getVideo());
            videoView.setVideoPath(data.getVideo());
            linearLayout.addView(videoView);
        }
        /*
        // failed in setting video
        videoView.setVideoPath("https://www.w3schools.com/html/movie.mp4");
        videoView.setMediaController(new MediaController(this));
        linearLayout.addView(videoView);
        videoView.start();
         */
        bitmaps = NewsLoader.getBitmaps(data.getImage());
        for (Bitmap bm: bitmaps) {
            ImageView imageView = new ImageView(this);
            imageView.setImageBitmap(bm);
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            imageView.setAdjustViewBounds(true);
            imageView.setPadding(0, 4, 0, 4);
            linearLayout.addView(imageView);
        }

        /*
        ((LinearLayout)findViewById(R.id.layout_detail))
                .addView(TagButtonView.factoryTagButtonView(
                this, new ArrayList<>(data.getKeywords().keySet()), (name)->{
                    KeywordFilter.getInstance().addKeyword(name);
                    WarningTip.showToastLong(this, "已添加至屏蔽词");
                        }, 5
        ));*/
        //Log.d(getClass().getName(), data.getImage());

        //((ImageView)findViewById(R.id.imagePoster)).setImageBitmap();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.

        getMenuInflater().inflate(R.menu.detail_menu, menu);

        updateMenuItemIcon(menu.findItem(R.id.action_add_favorite));
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) {
            finish();
            return true;
        }
        if (id == R.id.action_add_favorite) {
            changeFavoriteState(!isFavorite());
            updateMenuItemIcon(item);
        }
        else if (id == R.id.action_share) {
            //Log.d(getClass().getName(), "action_share triggered.");
            ShareManager.share(data.getTitle(), "", data.getContent(),
                    bitmaps.isEmpty() ? null : bitmaps.get(0), this);
        }
        return super.onOptionsItemSelected(item);
    }

    private void updateMenuItemIcon(MenuItem item) {
        item.setIcon(isFavorite() ?
                R.drawable.ic_star_black_24dp : R.drawable.ic_star_border_black_24dp);
    }

    private void changeFavoriteState(boolean newState) {
        // set state at data level
        tempFavorite = newState;
        // show tips
        String toastMsg;
        if (isFavorite()) {
            toastMsg = getString(R.string.msg_added_to_favorite);
            NewsLoader.add_collect(data, LoginRepository.getLoggedInUserID());
        } else {
            toastMsg = getString(R.string.msg_removed_from_favorite);
            NewsLoader.delete_collect(data, LoginRepository.getLoggedInUserID());
        }
        WarningTip.showToastLong(this, toastMsg);
    }

    private boolean tempFavorite = false;

    private boolean isFavorite() {
        return tempFavorite;
    }

}
