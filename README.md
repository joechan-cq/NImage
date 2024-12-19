# NImage

使用外接纹理方案，让Native进行图片加载，并最终显示到Flutter页面上的插件。

**优点：** 

1. 对接Native上的图片加载框架，统一Flutter和Native的产生的文件缓存

2. 缓解Flutter图片加载产生的内存问题

3. 因为使用Native进行加载，只要Native端的图片加载能够支持的格式，都能在Flutter端显示

**缺点：**

1. 外接纹理方案，无法做截图

2. 依赖Flutter SDK对于外接纹理的渲染，部分Flutter版本存在渲染的兼容问题

## 原理



## 更新日志

**V0.1**

init

## 任务

- [ ] support gif、ani-webp

- [x] support background color

- [ ] support different boxfit

- [ ] support the manager of textures based on size

- [ ] improve the demo


