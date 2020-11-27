package com.java.lidaixuan.newsclient.ui.tools;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.app.AppCompatDelegate;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.support.annotation.Nullable;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.arch.lifecycle.Observer;
import android.arch.lifecycle.ViewModelProviders;

import com.java.lidaixuan.newsclient.R;

public class ToolsFragment extends Fragment {

    private ToolsViewModel toolsViewModel;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        toolsViewModel =
                ViewModelProviders.of(this).get(ToolsViewModel.class);
        View root = inflater.inflate(R.layout.fragment_tools, container, false);
        Button button = root.findViewById(R.id.buttonNight);
        boolean isNightMode = AppCompatDelegate.getDefaultNightMode() == AppCompatDelegate.MODE_NIGHT_YES;
        button.setText(!isNightMode ? R.string.switch_to_night : R.string.switch_to_day);
        button.setOnClickListener((a)->{
            //
            AppCompatActivity appCompatActivity = (AppCompatActivity)getActivity();
            AppCompatDelegate.setDefaultNightMode(!isNightMode ?
                            AppCompatDelegate.MODE_NIGHT_YES : AppCompatDelegate.MODE_NIGHT_NO);
            //NightModeHelper.reverseNightMode();
            appCompatActivity.getWindow().setWindowAnimations(R.style.WindowAnimationFadeInOut);
            //appCompatActivity.overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            appCompatActivity.recreate();
        });
        return root;
    }
}