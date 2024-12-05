package com.example.nimage_example;

import android.os.Bundle;

import com.flext.nimage.loader.ImageLoader;

import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        ImageLoader.setProxy(new GlideLoader());
        super.onCreate(savedInstanceState);
    }
}
