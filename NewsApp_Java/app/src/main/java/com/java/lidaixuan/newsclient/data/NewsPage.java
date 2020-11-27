package com.java.lidaixuan.newsclient.data;
import com.alibaba.fastjson.*;
import com.alibaba.fastjson.annotation.*;
import com.java.lidaixuan.newsclient.data.NewsData;
import java.util.List;
import java.util.LinkedList;
import java.io.*;

public class NewsPage {
    private int pageSize;

    private int total;

    private JSONArray newsData;

    private int currentPage;

}
