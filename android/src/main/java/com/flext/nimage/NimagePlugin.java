package com.flext.nimage;

import android.content.Context;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * NImagePlugin
 */
public class NImagePlugin implements FlutterPlugin, MethodCallHandler {

    private Context context;
    private MethodChannel channel;
    private TextureManager textureManager;
    private static final String MTH_CREATE_TEXTURE = "mth_createTexture";
    private static final String MTH_LOAD_IMAGE = "mth_loadImage";
    private static final String MTH_DESTROY_TEXTURE = "mth_destroyTexture";
    private static final String MTH_SET_VISIBLE = "mth_setVisible";
    private static final String MTH_SET_INVISIBLE = "mth_setInvisible";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        textureManager = new TextureManager(flutterPluginBinding.getTextureRegistry());
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "nimage");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equalsIgnoreCase(MTH_CREATE_TEXTURE)) {
            //准备Texture
            long textureId = textureManager.createTexture(context);
            result.success(textureId);
        } else if (call.method.equalsIgnoreCase(MTH_LOAD_IMAGE)) {
            //加载图片
            long textureId = ((Number) call.argument("textureId")).longValue();
            LoadRequest loadRequest = LoadRequest.fromCall(call);
            ImageTextureView imageView = textureManager.getImageTextureView(textureId);
            if (imageView != null) {
                imageView.loadImage(loadRequest, result);
            } else {
                result.error("NO_TEXTURE", "can't find texture with id:" + textureId, null);
            }
        } else if (call.method.equalsIgnoreCase(MTH_SET_VISIBLE)) {
            long textureId = ((Number) call.arguments).longValue();
            ImageTextureView imageView = textureManager.getImageTextureView(textureId);
            if (imageView != null) {
                imageView.setVisible(true);
            }
            result.success(null);
        } else if (call.method.equalsIgnoreCase(MTH_SET_INVISIBLE)) {
            long textureId = ((Number) call.arguments).longValue();
            ImageTextureView imageView = textureManager.getImageTextureView(textureId);
            if (imageView != null) {
                imageView.setVisible(false);
            }
            result.success(null);
        } else if (call.method.equalsIgnoreCase(MTH_DESTROY_TEXTURE)) {
            long textureId = ((Number) call.arguments).longValue();
            textureManager.destroyTexture(textureId);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
