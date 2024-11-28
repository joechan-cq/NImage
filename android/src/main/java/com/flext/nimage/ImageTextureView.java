package com.flext.nimage;

import android.graphics.SurfaceTexture;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;

import com.flext.nimage.loader.ILoadCallback;

import java.lang.ref.WeakReference;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

/**
 * @author : Joe Chan
 * @date : 2024/11/22 14:45
 */
class ImageTextureView implements Drawable.Callback, ILoadCallback {

    private static Handler mMainHandler;

    private final long textureId;
    private final TextureRegistry.SurfaceTextureEntry entry;
    private final SurfaceTexture surfaceTexture;

    private boolean isDestroyed;
    private MethodChannel.Result mResult;

    private WeakReference<Drawable> mDrawable;
    private int mDrawableWidth, mDrawableHeight;
    private LoadRequest mLoadRequest;

    public ImageTextureView(@NonNull TextureRegistry.SurfaceTextureEntry surfaceTextureEntry) {
        if (mMainHandler == null) {
            mMainHandler = new Handler(Looper.getMainLooper());
        }
        entry = surfaceTextureEntry;
        textureId = surfaceTextureEntry.id();
        surfaceTexture = surfaceTextureEntry.surfaceTexture();
    }

    public Drawable getDrawable() {
        if (mDrawable != null) {
            return mDrawable.get();
        }
        return null;
    }

    public void destroy() {
        try {
            surfaceTexture.release();
        } catch (Exception | Error e) {
            e.printStackTrace();
        }
        try {
            entry.release();
        } catch (Exception | Error e) {
            e.printStackTrace();
        }
        isDestroyed = true;
        cancelLoadTask();
    }

    public long getTextureId() {
        return textureId;
    }

    public boolean isDestroyed() {
        return isDestroyed;
    }

    private void cancelLoadTask() {
        //TODO 取消当前正在加载的任务
    }

    public void loadImage(LoadRequest loadRequest, MethodChannel.Result result) {
        //TODO
        mLoadRequest = loadRequest;
        mResult = result;
    }

    public void setVisible(boolean visible) {
        //TODO
    }

    private String uniqueKey() {
        assert (mLoadRequest != null);
        return mLoadRequest.hashCode() + "_" + hashCode();
    }

    //region Callback by ImageLoader
    @Override
    public void onLoadSuccess(Drawable drawable) {

    }

    @Override
    public void onLoadFailed(String error) {

    }
    //endregion

    //region Drawable.Callback
    @Override
    public void invalidateDrawable(@NonNull Drawable dr) {

    }

    @Override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        Drawable drawable = getDrawable();
        if (who == drawable && what != null) {
            final long delay = when - SystemClock.uptimeMillis();
            mMainHandler.postDelayed(what, delay);
        }
    }

    @Override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        Drawable drawable = getDrawable();
        if (who == drawable && what != null) {
            mMainHandler.removeCallbacks(what);
        }
    }
    //endregion
}
