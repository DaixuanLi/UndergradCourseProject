package com.java.lidaixuan.newsclient.search;

import android.content.Context;
import android.content.SearchRecentSuggestionsProvider;

import com.java.lidaixuan.newsclient.R;

public class SuggestionsProvider extends SearchRecentSuggestionsProvider {
    public final static String AUTHORITY = "com.java.lidaixuan.newsclient.search.SuggestionProvider";
    public final static int MODE = DATABASE_MODE_QUERIES;

    public SuggestionsProvider() {
        setupSuggestions(AUTHORITY, MODE);
    }
}
