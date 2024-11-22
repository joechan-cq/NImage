package com.flext.nimage;

import android.graphics.SurfaceTexture;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

/**
 * @author : chenqiao
 * @date : 2024/11/22 14:45
 */
class ImageTextureView {

    /**
     * 绑定的TextureId
     */
    private final long textureId;
    private final TextureRegistry.SurfaceTextureEntry entry;
    private final SurfaceTexture surfaceTexture;

    /**
     * 是否已经销毁
     */
    private boolean isDestroyed;

    public ImageTextureView(@NonNull TextureRegistry.SurfaceTextureEntry surfaceTextureEntry) {
        entry = surfaceTextureEntry;
        textureId = surfaceTextureEntry.id();
        surfaceTexture = surfaceTextureEntry.surfaceTexture();
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
        result.success(null);
    }
}
