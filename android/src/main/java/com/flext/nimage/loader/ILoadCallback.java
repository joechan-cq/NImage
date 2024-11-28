package com.flext.nimage.loader;

import android.graphics.drawable.Drawable;

/**
 * @author : Joe Chan
 * @date : 2024/11/28 16:39
 */
public interface ILoadCallback {

    void onLoadSuccess(Drawable drawable);

    void onLoadFailed(String error);
}
