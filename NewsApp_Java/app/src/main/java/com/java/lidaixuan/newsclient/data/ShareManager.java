package com.java.lidaixuan.newsclient.data;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.FileProvider;

import com.java.lidaixuan.newsclient.BuildConfig;

import java.io.File;
import java.io.FileOutputStream;

import cn.sharesdk.onekeyshare.OnekeyShare;

public class ShareManager {
    public static int imgnum = 0;
    public static String[] PERMISSIONS_STORAGE = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };
    public static final int REQUEST_EXTERNAL_STORAGE = 1;
    public static void share(String title,String url,String content, Bitmap imag,Context context){
        url = "https://news.sina.com.cn";
        OnekeyShare oks = new OnekeyShare();
        // title标题，微信、QQ和QQ空间等平台使用
        oks.setTitle(title);
        // titleUrl QQ和QQ空间跳转链接
        oks.setTitleUrl(url);
        // text是分享文本，所有平台都需要这个字段
        oks.setText(content);
        // imagePath是图片的本地路径，确保SDcard下面存在此张图片
        String dir = Environment.getExternalStorageDirectory().getAbsolutePath()+"/Pictures/"+Integer.toString(imgnum)+".png";
        //获取内部存储状态
        String state = Environment.getExternalStorageState();
        if (state.equals(Environment.MEDIA_MOUNTED )&& imag!=null) {
            try {
                File file = new File(dir);
                if(file.exists()){
                    file.delete();
                }
                if(!file.exists()){
                    file.getParentFile().mkdirs();
                    file.createNewFile();
                }
                FileOutputStream out = new FileOutputStream(file);
                imag.compress(Bitmap.CompressFormat.PNG, 100, out);
                out.flush();
                out.close();
                oks.setImagePath(dir);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }
        imgnum++;
        // url在微信、Facebook等平台中使用
        oks.setUrl(url);
        // 启动分享GUI
        oks.show(context);
    }
    public static void sharenaive(String content, Bitmap imag,Context context){
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT,content);
        sendIntent.setType("text/plain");
        String dir = Environment.getExternalStorageDirectory().getAbsolutePath()+"/Pictures/"+Integer.toString(imgnum)+".png";
        //获取内部存储状态
        String state = Environment.getExternalStorageState();
        if (state.equals(Environment.MEDIA_MOUNTED)) {
            try {
                File file = new File(dir);
                if(file.exists()){
                    file.delete();
                }
                if(!file.exists()){
                    file.getParentFile().mkdirs();
                    file.createNewFile();
                }
                FileOutputStream out = new FileOutputStream(file);
                imag.compress(Bitmap.CompressFormat.PNG, 100, out);
                out.flush();
                out.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            try{
                File file = new File(dir);
                Uri uri = Uri.fromFile(file);
                if (Build.VERSION.SDK_INT>=24){
                    //这里的BuildConfig，需要是程序包下BuildConfig。
                    sendIntent.putExtra(Intent.EXTRA_STREAM, FileProvider.getUriForFile(context.getApplicationContext(), BuildConfig.APPLICATION_ID+".provider",file));
                    sendIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                    sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                }else{
                    sendIntent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
                }
                //sendIntent.setType("image/png");
            }catch (Exception e) {
                e.printStackTrace();
            }
        }
        imgnum++;
        context.startActivity(Intent.createChooser(sendIntent, "Share to..."));
    }
}
