package com.flext.nimage.loader;

/**
 * @author : Joe Chan
 * @date : 2024/11/28 16:20
 */
public class ImageLoader {

    private static ILoaderProxy mProxy;

    public static ILoaderProxy getProxy() {
        return mProxy;
    }

    public static void setProxy(ILoaderProxy proxy) {
        mProxy = proxy;
    }
}
