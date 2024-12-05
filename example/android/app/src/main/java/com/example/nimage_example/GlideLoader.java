package com.example.nimage_example;

import android.content.Context;
import android.graphics.drawable.Drawable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.flext.nimage.LoadRequest;
import com.flext.nimage.loader.ILoadCallback;
import com.flext.nimage.loader.ILoaderProxy;

import androidx.annotation.Nullable;

/**
 * @author : Joe Chan
 * @date : 2024/11/28 17:02
 */
public class GlideLoader implements ILoaderProxy<FutureTarget<Drawable>> {

    @Override
    public FutureTarget<Drawable> loadImage(Context appCtx, LoadRequest request,
                                            ILoadCallback target) {
        String uri = request.uri;
        int width = request.width;
        int height = request.height;
        RequestBuilder<Drawable> builder = Glide.with(appCtx).asDrawable()
                .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC).load(uri).addListener(new RequestListener<Drawable>() {
                    @Override
                    public boolean onLoadFailed(@Nullable GlideException e, Object model,
                                                Target<Drawable> t,
                                                boolean isFirstResource) {
                        if (e != null) {
                            target.onLoadFailed(e.getMessage());
                        } else {
                            target.onLoadFailed("load failed.");
                        }
                        return true;
                    }

                    @Override
                    public boolean onResourceReady(Drawable resource, Object model,
                                                   Target<Drawable> t,
                                                   DataSource dataSource,
                                                   boolean isFirstResource) {
                        target.onLoadSuccess(resource);
                        return true;
                    }
                });
        if (width > 0 && height > 0) {
            return builder.submit(width, height);
        } else {
            return builder.submit(Target.SIZE_ORIGINAL, FutureTarget.SIZE_ORIGINAL);
        }
    }

    @Override
    public void cancelLoad(FutureTarget<Drawable> task) {
        if (task != null) {
            if (!task.isDone()) {
                task.cancel(true);
            }
        }
    }
}
