package com.flext.nimage;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.Surface;

import com.flext.nimage.loader.ILoadCallback;
import com.flext.nimage.loader.ImageLoader;

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

    private final long mTextureId;
    private final TextureRegistry.SurfaceTextureEntry entry;
    private final SurfaceTexture mSurfaceTexture;
    private final Context mContext;

    private final Surface mSurface;

    private Matrix mDrawMatrix = null;

    private final Paint mPaint;

    private boolean isDestroyed;
    private MethodChannel.Result mLoadResult;

    private WeakReference<Drawable> mDrawable;
    private int mDrawableWidth, mDrawableHeight;
    private LoadRequest mLoadRequest;
    private Object mTask;
    private boolean forceConfigMatrix;

    public ImageTextureView(Context ctx,
                            @NonNull TextureRegistry.SurfaceTextureEntry surfaceTextureEntry) {
        if (mMainHandler == null) {
            mMainHandler = new Handler(Looper.getMainLooper());
        }
        mContext = ctx;
        entry = surfaceTextureEntry;
        mTextureId = surfaceTextureEntry.id();
        mSurfaceTexture = surfaceTextureEntry.surfaceTexture();

        mSurface = new Surface(mSurfaceTexture);
        mPaint = new Paint();
    }

    public Drawable getDrawable() {
        if (mDrawable != null) {
            return mDrawable.get();
        }
        return null;
    }

    public void destroy() {
        try {
            mSurfaceTexture.release();
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
        return mTextureId;
    }

    public boolean isDestroyed() {
        return isDestroyed;
    }

    private void cancelLoadTask() {
        //cancel the task
        if (mTask != null) {
            ImageLoader.getProxy().cancelLoad(mTask);
            mTask = null;
        }
    }

    public void loadImage(LoadRequest loadRequest, MethodChannel.Result result) {
        assert (ImageLoader.getProxy() != null);
        cancelLoadTask();
        mLoadRequest = loadRequest;
        mLoadResult = result;
        mTask = ImageLoader.getProxy().loadImage(mContext, mLoadRequest, this);
    }

    public void setVisible(boolean visible) {
        if (visible) {
            Drawable drawable = getDrawable();
            if (drawable != null) {
                forceConfigMatrix = true;
                boolean changed = drawable.setVisible(true, true);
                if (!changed) {
                    invalidateDrawable(drawable);
                }
            }
        } else {
            Drawable drawable = getDrawable();
            if (drawable != null) {
                drawable.setVisible(false, false);
            }
        }
    }

    private String uniqueKey() {
        assert (mLoadRequest != null);
        return mLoadRequest.hashCode() + "_" + hashCode();
    }

    //region Callback by ImageLoader
    @Override
    public void onLoadSuccess(Drawable result) {
        if (mLoadResult != null) {
            Drawable drawable = getDrawable();
            result.setCallback(this);
            if (result != drawable) {
                mDrawable = new WeakReference<>(result);
                boolean changed = result.setVisible(true, true);
                //如果changed为true，那么setVisible内部会自行调用invalidateDrawable，不需要手动调
                if (!changed) {
                    invalidateDrawable(result);
                }
            } else {
                result.setVisible(true, false);
            }
            NImageInfo imageInfo = new NImageInfo();
            imageInfo.uri = mLoadRequest.uri;
            imageInfo.imageWidth = result.getIntrinsicWidth();
            imageInfo.imageHeight = result.getIntrinsicHeight();
            mLoadResult.success(imageInfo.toMap());
            mLoadResult = null;
        }
    }

    @Override
    public void onLoadFailed(String error) {
        if (mLoadResult != null) {
            mLoadResult.error("-1", error, null);
            mLoadResult = null;
        }
    }
    //endregion

    private void configureBounds(Drawable drawable) {
        forceConfigMatrix = false;
        if (mDrawable == null) {
            return;
        }

        final int dwidth = mDrawableWidth;
        final int dheight = mDrawableHeight;

        final int vwidth = mDrawableWidth;
        final int vheight = mDrawableHeight;

        drawable.setBounds(0, 0, vwidth, vheight);
    }

    private void onDraw() {
        if (isDestroyed) {
            return;
        }
        Drawable drawable = getDrawable();
        if (drawable == null) {
            return; // couldn't resolve the URI
        }

        if (mSurface == null || !mSurface.isValid()) {
            return;
        }
        Canvas canvas = null;
        try {
            canvas = mSurface.lockCanvas(null);
            if (canvas != null) {
                if (mDrawableWidth == 0 || mDrawableHeight == 0) {
                    return;
                }
                mPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
                canvas.drawPaint(mPaint);
                mPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC));
                if (mDrawMatrix == null) {
                    drawable.draw(canvas);
                } else {
                    final int saveCount = canvas.getSaveCount();
                    canvas.save();
                    if (mDrawMatrix != null) {
                        canvas.concat(mDrawMatrix);
                    }
                    drawable.draw(canvas);
                    canvas.restoreToCount(saveCount);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (canvas != null) {
                try {
                    mSurface.unlockCanvasAndPost(canvas);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    //region Drawable.Callback
    @Override
    public void invalidateDrawable(@NonNull Drawable dr) {
        Drawable drawable = getDrawable();
        if (dr == drawable) {
            if (dr != null) {
                // update cached drawable dimensions if they've changed
                final int w = dr.getIntrinsicWidth();
                final int h = dr.getIntrinsicHeight();
                if (w != mDrawableWidth || h != mDrawableHeight || forceConfigMatrix) {
                    mDrawableWidth = w;
                    mDrawableHeight = h;
                    // updates the matrix, which is dependent on the bounds
                    configureBounds(drawable);
                }
            }
            mSurfaceTexture.setDefaultBufferSize(mDrawableWidth, mDrawableHeight);
            onDraw();
        }
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
