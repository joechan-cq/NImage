package com.flext.nimage;

import android.content.Context;

import androidx.annotation.Nullable;
import androidx.collection.LongSparseArray;
import io.flutter.view.TextureRegistry;

/**
 * @author : Joe Chan
 * @date : 2024/11/22 14:37
 */
class TextureManager {
    private final TextureRegistry textureRegistry;

    private final LongSparseArray<ImageTextureView> cache;

    public TextureManager(TextureRegistry textureRegistry) {
        this.textureRegistry = textureRegistry;
        cache = new LongSparseArray<>();
    }

    public long createTexture(Context context) {
        TextureRegistry.SurfaceTextureEntry entry = textureRegistry.createSurfaceTexture();
        ImageTextureView imageView = new ImageTextureView(context, entry);
        long id = entry.id();
        cache.put(id, imageView);
        return id;
    }

    public void destroyTexture(long textureId) {
        ImageTextureView imageView = cache.get(textureId);
        if (imageView != null) {
            cache.remove(textureId);
            imageView.destroy();
        }
    }

    @Nullable
    public ImageTextureView getImageTextureView(long textureId) {
        return cache.get(textureId);
    }

}
