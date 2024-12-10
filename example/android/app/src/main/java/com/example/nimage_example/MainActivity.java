package com.example.nimage_example;

import android.os.Bundle;
import android.util.Log;

import com.bumptech.glide.Glide;
import com.bumptech.glide.GlideBuilder;
import com.flext.nimage.loader.ImageLoader;

import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        GlideBuilder glideBuilder = new GlideBuilder();
        glideBuilder.setLogLevel(Log.DEBUG);
        Glide.init(this, glideBuilder);
        ImageLoader.setProxy(new GlideLoader());
        super.onCreate(savedInstanceState);
    }
}