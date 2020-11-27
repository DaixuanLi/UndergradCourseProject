/**
 * Hold, sort, remove or add item in a dynamic way.
 */

package com.java.lidaixuan.newsclient.ui.draggable;

import android.content.ClipDescription;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.DragEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import com.java.lidaixuan.newsclient.R;

import java.util.ArrayList;
import java.util.List;

public class DraggableTableLayout extends TableLayout implements DraggableItem.OnRemoveListener {
    private final int ROW_SIZE = 2;
    private boolean dragging = false;

    private ArrayList<String> mCategories = new ArrayList<>();
    private String name;
    public void setName(String name) {
        this.name = name;
    }

    private float nowX, nowY, startX, startY;
    private float unitWidth, unitHeight;
    private int latestI, latestJ, targetI, targetJ;
    private DraggableItem dragging_item = null;

    private ArrayList<DraggableItem> mItems = new ArrayList<>();

    private DraggableItem.OnRemoveListener onRemoveListener;
    private OnMoveListener onMoveListener;

    public void setOnMoveListener(OnMoveListener onMoveListener) {
        this.onMoveListener = onMoveListener;
    }

    public void setOnRemoveListener(DraggableItem.OnRemoveListener onRemoveListener) {
        this.onRemoveListener = onRemoveListener;
    }

    public interface OnMoveListener {
        void move(int from, int to);
    }

    // constructors
    public DraggableTableLayout(Context context) {
        super(context);
        initDivider(this, SHOW_DIVIDER_BEGINNING | SHOW_DIVIDER_MIDDLE);
    }
    public DraggableTableLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        initDivider(this, SHOW_DIVIDER_BEGINNING | SHOW_DIVIDER_MIDDLE);
    }

    /**
     * Add divider onto a layout.
     * @param layout
     * @param param
     */
    private void initDivider(LinearLayout layout, int param) {
        layout.setDividerDrawable(getContext().getDrawable(R.drawable.shape_divider));
        layout.setDividerPadding(4);
        layout.setShowDividers(param);
    }

    private DraggableItem createDraggableItem(Context context, String n) {
        DraggableItem item = new DraggableItem(context, n, this.name);
        item.setOnRemoveListener(this);
        return item;
    }

    private TableRow createRow(Context context) {
        TableRow ret = new TableRow(context);
        ret.setLayoutParams(new LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT));
        initDivider(ret, SHOW_DIVIDER_MIDDLE);
        return ret;
    }

    /**
     * Accept given categories and create items in a table. OnDragListener is added to each.
     * @param mCategories
     */
    public void setCategories(ArrayList<String> mCategories) {
        this.mCategories = mCategories;
        int rows = (mCategories.size() + ROW_SIZE - 1) / ROW_SIZE;
        Context context = this.getContext();
        for (int i = 0; i < ROW_SIZE; i++)
            setColumnStretchable(i, true);
        for (int i = 0; i < rows; i++) {
            TableRow r = createRow(context);
            addView(r);
            for (int j = i * ROW_SIZE; j < (i+1)*ROW_SIZE && j < mCategories.size(); j++) {
                DraggableItem item = createDraggableItem(context, mCategories.get(j));
                r.addView(item);
                mItems.add(item);
            }
        }
        setOnDragListener((View v, DragEvent e)->{
            DraggableItem item;
            int i, j;
            switch(e.getAction()) {
                case DragEvent.ACTION_DRAG_STARTED:
                    if (!e.getClipDescription().hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN))
                        return false;
                    try {
                        List<String> info = (List<String>) e.getLocalState();
                        if (info == null || !info.get(1).equals(this.name))
                            return false;
                    } catch (Exception exception) {
                        return false;
                    }
                    item = mItems.get(0);
                    unitHeight = item.getMeasuredHeight();
                    unitWidth = item.getMeasuredWidth();
                    startX = e.getX(); startY = e.getY();
                    latestI = getI(startY);
                    latestJ = getJ(startX);
                    if (latestI < 0 || latestI * ROW_SIZE + latestJ >= mItems.size())
                        return false;
                    return true;
                case DragEvent.ACTION_DRAG_ENTERED:
                case DragEvent.ACTION_DRAG_EXITED:
                    return true;
                case DragEvent.ACTION_DRAG_LOCATION:
                    // redraw
                    i = getI(e.getY());
                    j = getJ(e.getX());
                    Log.v(getClass().getSimpleName(), i + " " + j);
                    int id = i * ROW_SIZE + j;
                    if (id >= 0 && id < mCategories.size()) {
                        addItemAt(i, j, true, removeItemAt(latestI, latestJ));
                        targetI = latestI = i;
                        targetJ = latestJ = j;
                    }
                    return true;
                case DragEvent.ACTION_DROP:
                    /*
                    targetI = getI(e.getY());
                    targetJ = getJ(e.getX());
                    Log.v(getClass().getSimpleName(), targetI + " " + targetJ);
                    int id = targetI * ROW_SIZE + targetJ;
                    if (id >= mCategories.size() || id < 0) {
                        targetI = latestI; targetJ = latestJ;
                    }
                    */
                    return true;
                case DragEvent.ACTION_DRAG_ENDED:
                    // change view
                    addItemAt(targetI, targetJ, false, removeItemAt(latestI, latestJ));
                    // change data
                    latestI = getI(startY);
                    latestJ = getJ(startX);
                    moveCategory(latestI * ROW_SIZE + latestJ, targetI * ROW_SIZE + targetJ);
                    debugShowCategories();
                    DraggableItem draggedItem = getItemAt(targetI, targetJ);
                    draggedItem.setDragging(false);
                    return true;
            }
            return false;
        });
    }

    private void moveCategory(int i, int j) {
        mCategories.add(j, mCategories.remove(i));
        if (onMoveListener != null)
            onMoveListener.move(i, j);
    }

    public List<String> getCategory () {
        return mCategories;
    }

    private DraggableItem getItemAt(int i, int j) {
        TableRow row = (TableRow)getChildAt(i);
        return (DraggableItem)row.getChildAt(j);
    }

    /**
     * Compute row index of the item that the mouse is over by a given y coordination.
     * @param y
     * @return row index.
     */
    private int getI(double y) { return (int)Math.floor((y / unitHeight)); }
    /**
     * Compute column index of the item that the mouse is over by a given x coordination.
     * @param x
     * @return column index.
     */
    private int getJ(double x) { return (int)Math.floor((x / unitWidth)); }
    /**
     * Add a item to a given position, and place items behind one position after.
     * @param i row id
     * @param j column id
     * @param virtual add a real item or a 'virtual' item - a placeholder.
     * @param toAdd if not virtual, which view to add.
     */
    private void addItemAt(int i, int j, boolean virtual, View toAdd) {
        // ensure enough rows
        while (getChildCount() == 0 ||
                ((ViewGroup)getChildAt(getChildCount()-1)).getChildCount() == ROW_SIZE)
            addView(createRow(getContext()));
        Log.d(getClass().getName(), "add: "+ getChildAt(i).getClass().getName());
        ViewGroup rowI = (ViewGroup)getChildAt(i);
        ViewGroup rowI1;
        View newItem = toAdd;//virtual ? toAdd : mItems.get(i*ROW_SIZE + j);
        rowI.addView(newItem, j);
        // add the last of line i to the head of line i+1
        for (; i+1 < getChildCount(); i++) {
            rowI = (ViewGroup)getChildAt(i);
            rowI1 = (ViewGroup)getChildAt(i+1);
            View ch = rowI.getChildAt(rowI.getChildCount()-1);
            // remove BEFORE add!
            rowI.removeViewAt(rowI.getChildCount()-1);
            rowI1.addView(ch, 0);
        }
    }

    /**
     * Remove a item at a given position, and place items behind one position before.
     * @param i row id
     * @param j column id
     */
    private View removeItemAt(int i, int j) {
        Log.d(getClass().getName(), "remove: i=" + i);
        Log.d(getClass().getName(), "remove: class=" + getChildAt(i).getClass().getName());
        ViewGroup rowI = (ViewGroup)getChildAt(i);
        ViewGroup rowI1;
        View ret = rowI.getChildAt(j);
        rowI.removeViewAt(j);
        // append the first of line i+1 to the end of line i
        for (; i+1 < getChildCount(); i++) {
            rowI = (ViewGroup)getChildAt(i);
            rowI1 = (ViewGroup)getChildAt(i+1);
            View ch = rowI1.getChildAt(0);
            rowI1.removeViewAt(0);
            rowI.addView(ch);
        }
        // remove trailing rows
        while (getChildCount() > 0 &&
                ((ViewGroup)getChildAt(getChildCount()-1)).getChildCount() == 0)
            removeViewAt(getChildCount() - 1);
        return ret;
    }


    /*
    @Override
    protected void onDraw(Canvas canvas) {
        Paint paint = new Paint();
        canvas.drawRect(0, 0, 10, 10, paint);
        super.onDraw(canvas);
        //Log.d(getClass().getSimpleName(), mItem.getMeasuredHeight() + " " + mItem.getMeasuredWidth());
        if (!dragging) return;
        canvas.translate(nowX - startX, nowY - startY);
        dragging_item.draw(canvas);
    }
    */

    private void debugShowCategories() {
        StringBuffer buf = new StringBuffer();
        for (String a: mCategories) {
            buf.append(a).append(" ");
        }
        Log.d(getClass().getName(), buf.toString());
    }


    public void addItem(String name) {
        int index = mCategories.size();
        mCategories.add(name);
        DraggableItem item = createDraggableItem(getContext(), name);
        mItems.add(item);
        addItemAt(index / ROW_SIZE, index % ROW_SIZE, false, item);
    }

    @Override
    public void remove(String name) {
        Log.i(DraggableItem.class.getName(), "remove " + name);
        int id = mCategories.indexOf(name);
        //if (id < 0) throw new Exception("");
        if (id < 0) {
            throw new RuntimeException("Item name is not found in mCategories. ");
        }
        mCategories.remove(id);
        mItems.removeIf((DraggableItem item)->{
            return item.getName().equals(name);
        });
        removeItemAt(id / ROW_SIZE, id % ROW_SIZE);
        if (onRemoveListener != null)
            onRemoveListener.remove(name);
    }
}
