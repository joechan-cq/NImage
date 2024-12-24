package com.flext.nimage;

import android.text.TextUtils;

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

    public String fit;

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
        request.fit = call.argument("fit");
        if (TextUtils.isEmpty(request.fit)) {
            request.fit = BoxFit.fill;
        }
        return request;
    }

    public boolean isFit_fill() {
        return BoxFit.fill.equalsIgnoreCase(fit);
    }

    public boolean isFit_none() {
        return BoxFit.none.equalsIgnoreCase(fit);
    }

    public boolean isFit_contain() {
        return BoxFit.contain.equalsIgnoreCase(fit);
    }

    public boolean isFit_cover() {
        return BoxFit.cover.equalsIgnoreCase(fit);
    }

    public boolean isFit_fitWidth() {
        return BoxFit.fitWidth.equalsIgnoreCase(fit);
    }

    public boolean isFit_fitHeight() {
        return BoxFit.fitHeight.equalsIgnoreCase(fit);
    }

    public boolean isFit_scaleDown() {
        return BoxFit.scaleDown.equalsIgnoreCase(fit);
    }
}
