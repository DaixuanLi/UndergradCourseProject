package com.java.lidaixuan.newsclient.ui.home;

import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.support.annotation.Nullable;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.arch.lifecycle.ViewModelProviders;
import com.java.lidaixuan.newsclient.R;
import com.java.lidaixuan.newsclient.data.login.LoginDataSource;
import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.data.model.LoggedInUser;
import com.java.lidaixuan.newsclient.ui.main.SectionsPagerAdapter;

public class HomeFragment extends Fragment {

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        HomeViewModel commHomeViewModel = ViewModelProviders.of(getActivity()).get(HomeViewModel.class);
        Bundle bundle = getArguments();
        String query = "";
        if (bundle != null) query = bundle.getString("query");
        View root = inflater.inflate(R.layout.fragment_home, container, false);
        //root.setId(R.id.nav_home);

        ViewPager viewPager = root.findViewById(R.id.view_pager);
        FragmentManager fm = getChildFragmentManager();
        SectionsPagerAdapter sectionsPagerAdapter = new SectionsPagerAdapter(getContext(), fm, query);
        viewPager.setAdapter(sectionsPagerAdapter);
        TabLayout tabs = root.findViewById(R.id.category_tabs);
        tabs.setupWithViewPager(viewPager);
        tabs.setTabMode(TabLayout.MODE_SCROLLABLE);
        sectionsPagerAdapter.notifyDataSetChanged();
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int i, float v, int i1) {}
            @Override
            public void onPageScrollStateChanged(int i) {}

            @Override
            public void onPageSelected(int i) {
                sectionsPagerAdapter.startLoading(i);
            }
        });

        commHomeViewModel.getText().observe(this, (@Nullable String s)->{
            LoggedInUser user = LoginRepository.getInstance(new LoginDataSource()).getLoggedInUser();
            sectionsPagerAdapter.setUserName(user != null ? user.getDisplayName() : "admin");
            sectionsPagerAdapter.notifyDataSetChanged();
            viewPager.setAdapter(sectionsPagerAdapter);
            //viewPager.setCurrentItem(0);
        });

        return root;
    }

    public void refreshCategories() {
    }
}