package com.java.lidaixuan.newsclient.ui.draggable;

import android.content.ClipData;
import android.content.ClipDescription;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.support.constraint.ConstraintLayout;
import android.text.Layout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.java.lidaixuan.newsclient.R;

import java.util.Arrays;

public class DraggableItem extends ConstraintLayout {



    public interface OnRemoveListener {
        void remove(String name);
    }
    private OnRemoveListener onRemoveListener = null;
    public void setOnRemoveListener(OnRemoveListener onRemoveListener) {
        this.onRemoveListener = onRemoveListener;
    }

    private String name;

    public String getName() { return name; }

    private boolean dragging = false;
    private Paint highlightPaintFill, highlightPaintStoke;
    public boolean isDragging() {
        return dragging;
    }

    public void setDragging(boolean dragging) {
        this.dragging = dragging;
    }


    public DraggableItem(Context context, String name, String parent) {
        super(context);
        View root = LayoutInflater.from(context).inflate(R.layout.draggable_item, this, false);
        addView(root);
        this.name = name;
        setOnClickListener((e)->{
            if (onRemoveListener != null)
                onRemoveListener.remove(name);
        });
        findViewById(R.id.imgDrag).setOnLongClickListener((e)->{
            ClipData data = new ClipData(null,
                    new String[]{ClipDescription.MIMETYPE_TEXT_PLAIN},
                    new ClipData.Item(name));
            startDragAndDrop(data, new View.DragShadowBuilder(this),
                    Arrays.asList(name, parent), 0);
            dragging = true;
            return true;
        });
        TextView txt = findViewById(R.id.textItemName);
        txt.setText(name);
        // enable drawing
        setWillNotDraw(false);
        highlightPaintFill = new Paint(Paint.ANTI_ALIAS_FLAG);
        highlightPaintFill.setColor(getContext().getColor(R.color.blue_highlight));
        highlightPaintFill.setAlpha(0x7f);
        highlightPaintFill.setStyle(Paint.Style.FILL);
        highlightPaintStoke = new Paint(highlightPaintFill);
        highlightPaintStoke.setStyle(Paint.Style.STROKE);
        highlightPaintStoke.setAlpha(0);
        highlightPaintStoke.setStrokeWidth(3);
        postInvalidate();
    }

    @Override
    public void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        if (dragging) {
            int w = getMeasuredWidth(), h = getMeasuredHeight();
            Log.v(getClass().getName(), "onDraw! name=" + name);
            // fill
            canvas.drawRect(0, 0, w, h, highlightPaintFill);
            // stoke
            canvas.drawRect(0, 0, w, h, highlightPaintStoke);
        }
    }
}
