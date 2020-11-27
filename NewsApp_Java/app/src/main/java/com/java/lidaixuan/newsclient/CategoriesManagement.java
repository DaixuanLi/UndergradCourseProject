package com.java.lidaixuan.newsclient;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import com.java.lidaixuan.newsclient.data.login.LoginRepository;
import com.java.lidaixuan.newsclient.database.UserDataBase;
import com.java.lidaixuan.newsclient.ui.draggable.DraggableTableLayout;
import com.java.lidaixuan.newsclient.util.CategoriesHelper;

import java.util.ArrayList;
import java.util.List;

public class CategoriesManagement extends AppCompatActivity {

    private String categories_test[] = new String[]{"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};
    private String ADMIN = "admin";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_categories_management);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        // TODO: Load Categories and their order from local storage

        DraggableTableLayout tableAdded = findViewById(R.id.viewAddedTable);
        DraggableTableLayout tableRemoved = findViewById(R.id.viewRemovedTable);
        tableAdded.setName("Added");
        tableRemoved.setName("Removed");
        tableAdded.setOnRemoveListener((name) -> {
            tableRemoved.addItem(name);
            dataChange(tableAdded.getCategory());
        });
        tableRemoved.setOnRemoveListener((name) -> {
            tableAdded.addItem(name);
            dataChange(tableAdded.getCategory());
        });
        tableAdded.setOnMoveListener((from, to)->{
            //
            dataChange(tableAdded.getCategory());
        });
        //UserDataBaseHelper.setUpInstance(this);
        //NewsDatabaseHelper.setUpInstance(this);
        UserDataBase userDataBase = new UserDataBase();
        ArrayList<String> added = CategoriesHelper.getUserCategories(LoginRepository.getLoggedInUserID());
        ArrayList<String> removed = CategoriesHelper.getAllCategories();
        removed.removeAll(added);
        tableAdded.setCategories(added);
        tableRemoved.setCategories(removed);
    }

    /**
     * Save data.
     * @param categories New set of categoreis.
     */
    private void dataChange(List<String> categories) {
        UserDataBase userDataBase = new UserDataBase();
        // TODO: change "username" into a real one instead of a demo
        userDataBase.set_categories(LoginRepository.getLoggedInUserID(), categories.toArray(new String[categories.size()]));
    }

}
