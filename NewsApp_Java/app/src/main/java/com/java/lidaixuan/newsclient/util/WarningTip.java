package com.java.lidaixuan.newsclient.util;

import android.content.Context;
import android.support.design.widget.Snackbar;
import android.view.View;
import android.widget.Toast;

import com.java.lidaixuan.newsclient.R;

public final class WarningTip {

    public static void showToastLong(Context context, String text) {
        Toast.makeText(context, text, Toast.LENGTH_LONG).show();
    }
    public static void showToastLong(Context context, int text) {
        Toast.makeText(context, text, Toast.LENGTH_LONG).show();
    }
    public static void showToastShort(Context context, String text) {
        Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
    }

    public static void showSnackbarShort(View view, String text) {
        Snackbar.make(view, text, Snackbar.LENGTH_SHORT)
                .setAction(R.string.action_hide, null).show();
    }
    public static void showSnackbarLong(View view, String text) {
        Snackbar.make(view, text, Snackbar.LENGTH_SHORT)
                .setAction(R.string.action_hide, null).show();
    }
    public static void showSnackbarLong(View view, int text) {
        Snackbar.make(view, text, Snackbar.LENGTH_SHORT)
                .setAction(R.string.action_hide, null).show();
    }
}
