package com.flext.nimage;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RectF;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.Animatable;
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
    private Matrix mMatrix;
    private Matrix mDrawMatrix = null;

    private final RectF mTempSrc = new RectF();
    private final RectF mTempDst = new RectF();

    private final Paint mPaint;

    private boolean isDestroyed;
    private MethodChannel.Result mLoadResult;

    private WeakReference<Drawable> mDrawable;
    private LoadRequest mLoadRequest;
    private Object mTask;
    private boolean forceConfigMatrix;
    private int mSurfaceW, mSurfaceH;

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
        } catch (Exception | Error ignore) {
        }
        try {
            entry.release();
        } catch (Exception | Error ignore) {
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
        forceConfigMatrix = true;
        mMatrix = new Matrix();
        mLoadRequest = loadRequest;
        mSurfaceW = loadRequest.width;
        mSurfaceH = loadRequest.height;
        mLoadResult = result;
        mTask = ImageLoader.getProxy().loadImage(mContext, mLoadRequest, this);
    }

    public void setVisible(boolean visible) {
        Drawable drawable = getDrawable();
//        Log.i("ImageTextureView", drawable.hashCode() + " setVisible: " + visible + " [url:" + mLoadRequest.uri + "]");
        if (visible) {
            if (drawable != null) {
                forceConfigMatrix = true;
                boolean changed = drawable.setVisible(true, true);
                if (drawable instanceof Animatable) {
                    //if drawable is animatable, start animation when visible
                    ((Animatable) drawable).start();
                }
                if (!changed) {
                    invalidateDrawable(drawable);
                }
            }
        } else {
            if (drawable != null) {
                drawable.setVisible(false, false);
                if (drawable instanceof Animatable) {
                    //if drawable is animatable, stop animation when invisible
                    ((Animatable) drawable).stop();
                }
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
        if (isDestroyed) {
            if (mLoadResult != null) {
                mLoadResult.success(null);
                mLoadResult = null;
            }
            return;
        }
        if (mLoadResult != null) {
            Drawable drawable = getDrawable();
            result.setCallback(this);
            if (result != drawable) {
                mDrawable = new WeakReference<>(result);
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
        if (isDestroyed) {
            if (mLoadResult != null) {
                mLoadResult.success(null);
                mLoadResult = null;
            }
            return;
        }
        if (mLoadResult != null) {
            mLoadResult.error("-1", error, null);
            mLoadResult = null;
        }
    }
    //endregion

    /**
     * {@link android.widget.ImageView#configureBounds}
     */
    private void configureBounds(Drawable drawable) {
        forceConfigMatrix = false;
        if (drawable == null) {
            return;
        }

        final int dwidth = drawable.getIntrinsicWidth();
        final int dheight = drawable.getIntrinsicHeight();

        final int vwidth = mSurfaceW;
        final int vheight = mSurfaceH;

        final boolean fits = (dwidth < 0 || vwidth == dwidth)
                && (dheight < 0 || vheight == dheight);

        if (fits) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = null;
        } else if (mLoadRequest.isFit_none()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = mMatrix;
            mDrawMatrix.setTranslate(Math.round((vwidth - dwidth) * 0.5f),
                    Math.round((vheight - dheight) * 0.5f));
        } else if (mLoadRequest.isFit_fitWidth()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = mMatrix;
            float scale;
            float dx = 0, dy = 0;
            scale = (float) vwidth / (float) dwidth;
            dy = (vheight - dheight * scale) * 0.5f;
            mDrawMatrix.setScale(scale, scale);
            mDrawMatrix.postTranslate(Math.round(dx), Math.round(dy));
        } else if (mLoadRequest.isFit_fitHeight()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = mMatrix;
            float scale;
            float dx, dy = 0;
            scale = (float) vheight / (float) dheight;
            dx = (vwidth - dwidth * scale) * 0.5f;
            mDrawMatrix.setScale(scale, scale);
            mDrawMatrix.postTranslate(Math.round(dx), Math.round(dy));
        } else if (mLoadRequest.isFit_contain()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mTempSrc.set(0, 0, dwidth, dheight);
            mTempDst.set(0, 0, vwidth, vheight);

            mDrawMatrix = mMatrix;

            mDrawMatrix.setRectToRect(mTempSrc, mTempDst, Matrix.ScaleToFit.CENTER);
        } else if (mLoadRequest.isFit_scaleDown()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = mMatrix;
            float scale;
            float dx;
            float dy;

            if (dwidth <= vwidth && dheight <= vheight) {
                scale = 1.0f;
            } else {
                scale = Math.min((float) vwidth / (float) dwidth,
                        (float) vheight / (float) dheight);
            }

            dx = Math.round((vwidth - dwidth * scale) * 0.5f);
            dy = Math.round((vheight - dheight * scale) * 0.5f);

            mDrawMatrix.setScale(scale, scale);
            mDrawMatrix.postTranslate(dx, dy);
        } else if (mLoadRequest.isFit_cover()) {
            drawable.setBounds(0, 0, dwidth, dheight);
            mDrawMatrix = mMatrix;

            float scale;
            float dx = 0, dy = 0;

            if (dwidth * vheight > vwidth * dheight) {
                scale = (float) vheight / (float) dheight;
                dx = (vwidth - dwidth * scale) * 0.5f;
            } else {
                scale = (float) vwidth / (float) dwidth;
                dy = (vheight - dheight * scale) * 0.5f;
            }

            mDrawMatrix.setScale(scale, scale);
            mDrawMatrix.postTranslate(Math.round(dx), Math.round(dy));
        } else {
            //fill or default.
            drawable.setBounds(0, 0, vwidth, vheight);
            mDrawMatrix = null;
        }
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
                if (drawable.getIntrinsicWidth() == 0 || drawable.getIntrinsicHeight() == 0) {
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
            // update cached drawable dimensions if they've changed
            final int w = dr.getIntrinsicWidth();
            final int h = dr.getIntrinsicHeight();
            if (w != drawable.getIntrinsicWidth() || h != drawable.getIntrinsicHeight() || forceConfigMatrix) {
                // updates the matrix, which is dependent on the bounds
                configureBounds(drawable);
            }
            mSurfaceTexture.setDefaultBufferSize(mSurfaceW, mSurfaceH);
            onDraw();
        }
    }

    @Override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        Drawable drawable = getDrawable();
        if (who == drawable) {
            final long delay = when - SystemClock.uptimeMillis();
            mMainHandler.postDelayed(what, delay);
        }
    }

    @Override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        Drawable drawable = getDrawable();
        if (who == drawable) {
            mMainHandler.removeCallbacks(what);
        }
    }
    //endregion
}
