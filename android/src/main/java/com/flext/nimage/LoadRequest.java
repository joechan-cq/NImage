package com.flext.nimage;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodCall;

/**
 * @author : Joe Chan
 * @date : 2024/11/22 14:21
 */
public class LoadRequest {
    public String uri;

    public int width;

    public int height;

    public LoadRequest() {
    }

    static LoadRequest fromCall(@NonNull MethodCall call) {
        LoadRequest request = new LoadRequest();
        request.uri = call.argument("uri");
        if (call.hasArgument("width")) {
            request.width = call.argument("width");
        }
        if (call.hasArgument("height")) {
            request.height = call.argument("height");
        }
        return request;
    }
}
