package com.java.lidaixuan.newsclient.util;

import android.arch.lifecycle.MutableLiveData;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class ListMutableLiveData<E> extends MutableLiveData<List<E>> implements List<E> {


    public interface OnItemChangeListener {
        void onAddItemAt(int pos);
        void onRangeAddItem(int st, int end);
        void onChangeItemAt(int pos);
        void onRemoveItemAt(int pos);
        void onRangeRemoveItem(int st, int end);
    }

    private OnItemChangeListener onItemChangeListener;
    public void setItemChangeListener(OnItemChangeListener onItemChangeListener) {
        this.onItemChangeListener = onItemChangeListener;
    }


    public ListMutableLiveData() {
        super();
        this.setValue(new ArrayList<>());
    }

    @Override
    public int size() {
        return getValue().size();
    }

    @Override
    public boolean isEmpty() {
        return getValue().isEmpty();
    }

    @Override
    public boolean contains(@Nullable Object o) {
        return getValue().contains(o);
    }

    @NonNull
    @Override
    public Iterator<E> iterator() {
        return getValue().iterator();
    }

    @Nullable
    @Override
    public Object[] toArray() {
        return getValue().toArray();
    }

    @Override
    public <T> T[] toArray(@Nullable T[] ts) {
        return getValue().toArray(ts);
    }

    @Override
    public boolean add(E e) {
        getValue().add(e);
        onItemChangeListener.onAddItemAt(getValue().size() - 1);
        return true;
    }

    @Override
    public void add(int i, E e) {
        getValue().add(i, e);
        onItemChangeListener.onAddItemAt(i);
    }

    @Override
    public boolean containsAll(@NonNull Collection<?> collection) {
        return getValue().containsAll(collection);
    }

    @Override
    public boolean addAll(@NonNull Collection<? extends E> collection) {
        return addAll(getValue().size(), collection);
    }

    @Override
    public boolean addAll(int i, @NonNull Collection<? extends E> collection) {
        boolean ret = getValue().addAll(i, collection);
        if (ret) onItemChangeListener.onRangeAddItem(i, i + collection.size());
        return false;
    }

    @Override
    public void clear() {
        int m = getValue().size();
        getValue().clear();
        //onItemChangeListener.onRangeRemoveItem(0, m);
        this.setValue(getValue());
    }

    @Override
    public boolean remove(@Nullable Object o) {
        int ind = getValue().indexOf(o);
        if (ind >= 0) onItemChangeListener.onRemoveItemAt(ind);
        return ind >= 0;
    }

    @Override
    public E remove(int i) {
        E ret = getValue().remove(i);
        onItemChangeListener.onRemoveItemAt(i);
        return ret;
    }

    @Override
    public boolean removeAll(@NonNull Collection<?> collection) {
        boolean ret = getValue().removeAll(collection);
        if (ret) this.postValue(getValue());
        return ret;
    }

    @Override
    public boolean retainAll(@NonNull Collection<?> collection) {
        boolean ret = getValue().retainAll(collection);
        if (ret) this.postValue(getValue());
        return ret;
    }

    @Override
    public E get(int i) {
        return getValue().get(i);
    }

    @Override
    public E set(int i, E e) {
        E ret = getValue().set(i, e);
        onItemChangeListener.onChangeItemAt(i);
        return ret;
    }

    @Override
    public int indexOf(@Nullable Object o) {
        return getValue().indexOf(o);
    }

    @Override
    public int lastIndexOf(@Nullable Object o) {
        return getValue().lastIndexOf(o);
    }

    @NonNull
    @Override
    public ListIterator<E> listIterator() {
        return getValue().listIterator();
    }

    @NonNull
    @Override
    public ListIterator<E> listIterator(int i) {
        return getValue().listIterator(i);
    }

    @NonNull
    @Override
    public List<E> subList(int i, int i1) {
        return getValue().subList(i, i1);
    }
}
