package com.flext.nimage;

import java.util.HashMap;
import java.util.Map;

/**
 * @author : Joe Chan
 * @date : 2024/12/5 16:30
 */
public class NImageInfo {

    public String uri;

    public int imageWidth;

    /// 图片高度，单位px
    public int imageHeight;

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        if (uri != null) {
            map.put("uri", uri);
        }
        map.put("imageWidth", imageWidth);
        map.put("imageHeight", imageHeight);
        return map;
    }
}
