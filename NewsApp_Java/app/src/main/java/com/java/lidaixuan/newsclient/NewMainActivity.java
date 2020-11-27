package com.java.lidaixuan.newsclient;

import android.app.Activity;
import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.provider.SearchRecentSuggestions;
import android.support.v7.app.ActionBar;
import android.util.Log;
import android.view.MenuItem;

import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import android.support.design.widget.NavigationView;
import android.support.v4.widget.DrawerLayout;

import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SearchView;
import android.widget.TextView;

import com.java.lidaixuan.newsclient.data.login.LoginDataSource;
import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.data.model.LoggedInUser;
import com.java.lidaixuan.newsclient.network.NetworkStatusChecker;
import com.java.lidaixuan.newsclient.search.SuggestionsProvider;
//import com.java.lidaixuan.newsclient.search.SuggestionsSimpleCursorAdapter;
import com.java.lidaixuan.newsclient.ui.login.LoginActivity;

import com.java.lidaixuan.newsclient.database.NewsDatabaseHelper;
import com.java.lidaixuan.newsclient.database.UserDataBaseHelper;

public class NewMainActivity extends AppCompatActivity {

    private static final int LOGIN_REQUEST = 865;
    private static final int CATEGORY_REQUEST = 996;
    private AppBarConfiguration mAppBarConfiguration;

    private String query;

    public boolean isSearch() {
        return Intent.ACTION_SEARCH.equals(getIntent().getAction());
    }
//    private SuggestionsDatabase database;

    private void onCreateMainInit(Bundle savedInstanceState) {
        //
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.getHeaderView(0).setOnTouchListener((a, b)->{
            Intent intent = new Intent(this, LoginActivity.class);
            startActivityForResult(intent, LOGIN_REQUEST);
            return navigationView.performClick();
        });
        // Passing each menu ID as a set of Ids because each
        // menu should be considered as top level destinations.
        mAppBarConfiguration = new AppBarConfiguration.Builder(
                R.id.nav_home, R.id.nav_favorite, R.id.nav_history,
                R.id.nav_tools)
                .setDrawerLayout(drawer)
                .build();
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        NavigationUI.setupActionBarWithNavController(this, navController, mAppBarConfiguration);
        NavigationUI.setupWithNavController(navigationView, navController);
        displayUser();
    }

    private void displayUser() {
        View navigationHeadView = ((NavigationView)findViewById(R.id.nav_view)).getHeaderView(0);
        TextView textName = navigationHeadView.findViewById(R.id.textName);
        TextView textDescription = navigationHeadView.findViewById(R.id.textDescription);
        LoginRepository loginRepository = LoginRepository.getInstance(new LoginDataSource());
        LoggedInUser loggedInUser = loginRepository.getLoggedInUser();
        if (loggedInUser != null) {
            textName.setText(loggedInUser.getDisplayName());
            textDescription.setText(R.string.click_to_user_screen);
        } else {
            textName.setText(R.string.anonymous);
            textDescription.setText(R.string.click_to_login);
        }
    }

    private void onCreateSearchView(Bundle savedInstanceState) {
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        query = getIntent().getStringExtra(SearchManager.QUERY);
        ab.setTitle(getString(R.string.search_result) + ": " + query);

        // pass query parameter to fragment
        Bundle bundle = new Bundle();
        bundle.putString("query", query);
        switchToHomeFragmentWithArgs(bundle);

    }

    private void switchToHomeFragmentWithArgs(Bundle bundle) {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        navController.setGraph(R.navigation.mobile_navigation, bundle);
        //navController.navigate(R.id.nav_home, bundle);
    }

    private void refreshHomeFragment() {
        NavigationView navigationView = findViewById(R.id.nav_view);
        View homeView = ((ViewGroup)navigationView.getChildAt(0)).getChildAt(1);
        homeView.post(()->
                homeView.performClick()
        );
        //onCreateMainInit(null);
        //HomeViewModel model = ViewModelProviders.of(this).get(HomeViewModel.class);
        //model.getText().setValue("");
        //navigationView.performClick();
        /*
        (new Handler()).post(()-> {
            //NavHostFragment fragment = ((NavHostFragment)findViewById(R.id.nav_host_fragment));
            //((ViewGroup)findViewById(R.id.view_pager)).removeViewAt();
            getSupportFragmentManager()//.getFragments().get(0).getChildFragmentManager()
                    .beginTransaction().replace(R.id.view_pager, new HomeFragment())
                    .commit();
        });

         */
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_main);
        Intent intent = getIntent();

        UserDataBaseHelper.setUpInstance(this);
        NewsDatabaseHelper.setUpInstance(this);
        NetworkStatusChecker.setContext(this);
        if (Intent.ACTION_MAIN.equals(intent.getAction()))
            onCreateMainInit(savedInstanceState);
        else if (Intent.ACTION_SEARCH.equals(intent.getAction()))
            onCreateSearchView(savedInstanceState);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        if (!Intent.ACTION_MAIN.equals(getIntent().getAction())) {
            return true;
        }
        getMenuInflater().inflate(R.menu.main_menu, menu);

        // configuring search view
        SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
        // Assumes current activity is the searchable activity
        SearchView searchView = (SearchView)menu.findItem(R.id.app_bar_search).getActionView();
        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        Context context = this;
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String s) {
                //WarningTip.showToastShort(context, "Text submitted. ");
                // set search key word
                // update the view
                SearchRecentSuggestions suggestions = new SearchRecentSuggestions(context, SuggestionsProvider.AUTHORITY, SuggestionsProvider.MODE);
                suggestions.saveRecentQuery(s, null);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String s) {
                return false;
            }
        });

        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        navController.addOnDestinationChangedListener((controller, destination, arguments)->{
            if (destination.getId() == R.id.nav_home) {
                menu.setGroupVisible(0, true);
            } else {
                menu.setGroupVisible(0, false);
            }
        });
        return true;
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home && Intent.ACTION_SEARCH.equals(getIntent().getAction())) {
            finish();
            return true;
        }
        else if (id == R.id.action_categories) {
            Intent intent = new Intent(this, CategoriesManagement.class);
            startActivityForResult(intent, CATEGORY_REQUEST);
        }
        else if (id == R.id.app_bar_search) {
            Log.d("NewMainActivity", "app_bar_search triggered.");
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        // TODO: accelerate loading stage of the main activity: save info and async loading
        super.onSaveInstanceState(outState);
    }

    @Override
    public boolean onSupportNavigateUp() {
        NavController navController = Navigation.findNavController(this, R.id.nav_host_fragment);
        return NavigationUI.navigateUp(navController, mAppBarConfiguration)
                || super.onSupportNavigateUp();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        //
        if (requestCode == LOGIN_REQUEST) {
            if (resultCode == Activity.RESULT_OK) {
                displayUser();
                refreshHomeFragment();
            }
        } else if (requestCode == CATEGORY_REQUEST) {
            refreshHomeFragment();
        }
    }
}
