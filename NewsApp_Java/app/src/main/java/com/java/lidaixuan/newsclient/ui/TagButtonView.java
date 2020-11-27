package com.java.lidaixuan.newsclient.ui;

import android.content.Context;
import android.nfc.Tag;
import android.support.constraint.ConstraintLayout;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ToggleButton;

import com.java.lidaixuan.newsclient.R;

import java.util.List;

public class TagButtonView extends ConstraintLayout {

    public interface OnTagClickListener {
        void onClick(String tag);
    }

    private  OnTagClickListener onTagClickListener;
    public TagButtonView(Context context) {
        super(context);
        addView(createView(context));
    }

    public TagButtonView(Context context, AttributeSet attrs) {
        super(context, attrs);
        addView(createView(context));
    }

    public TagButtonView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        addView(createView(context));
    }

    private View createView(Context context) {
        View root = LayoutInflater.from(context).inflate(R.layout.keyword_list, this, false);
        return root;
    }

    public void setOnClickTagListener(OnTagClickListener listener) {
        onTagClickListener = listener;
    }

    public void setTags(List<String> list, boolean checkable) {
        LinearLayout layout = findViewById(R.id.layout_keywords);
        for (String name: list) {
            Button button = new Button(getContext());
            button.setText(name);
            //button.setBackground(getContext().getDrawable(R.drawable.round_rect_button));
            button.setOnClickListener((l)->{
                if (onTagClickListener!=null)
                    onTagClickListener.onClick(name);
            });
            layout.addView(button);
        }
    }

    public static TagButtonView factoryTagButtonView(Context context, List<String> list, OnTagClickListener listener, int num) {
        return factoryTagButtonView(context, list.subList(0, Math.min(num, list.size())), listener);
    }
    public static TagButtonView factoryTagButtonView(Context context, List<String> list, OnTagClickListener listener) {
        TagButtonView tagButtonView = new TagButtonView(context);
        tagButtonView.setTags(list, false);
        tagButtonView.setOnClickTagListener(listener);
        return tagButtonView;
    }
    public static TagButtonView factoryTagButtonViewCheckable(Context context, List<String> list, OnTagClickListener listener, int num) {
        return factoryTagButtonView(context, list.subList(0, Math.min(num, list.size())), listener);
    }

}
