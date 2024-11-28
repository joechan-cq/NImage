package com.flext.nimage.loader;

import android.content.Context;

import com.flext.nimage.LoadRequest;

/**
 * @author : Joe Chan
 * @date : 2024/11/28 16:24
 */
public interface ILoaderProxy<T> {

    /**
     * load Image
     *
     * @param appCtx  applicationContext.
     * @param request request params.
     * @param target  callback.
     * @return
     */
    T loadImage(Context appCtx, LoadRequest request, ILoadCallback target);

    /**
     * cancel the loading task.
     *
     * @param task task unique instance which returned by
     *             {@link #loadImage(Context, LoadRequest, ILoadCallback)}
     */
    void cancelLoad(T task);
}