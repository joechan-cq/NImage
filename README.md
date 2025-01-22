# NImage

使用外接纹理方案，让Native进行图片加载，并最终显示到Flutter页面上的插件。

**优点：** 

1. 对接Native上的图片加载框架，统一Flutter和Native的产生的文件缓存

2. 缓解Flutter图片加载产生的内存问题

3. 因为使用Native进行加载，只要Native端的图片加载能够支持的格式，都能在Flutter端显示

**缺点：**

1. 外接纹理方案，无法做截图

2. 依赖Flutter SDK对于外接纹理的渲染，部分Flutter版本存在渲染的兼容问题

## 如何使用

```dart
                NImage(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  backgroundColor: Colors.red,
                  placeHolder: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Error',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
```

![Single](snapshots/single.gif))![List](snapshots/list.gif)

## 原理

#### 对接Native图片加载

在Android和iOS上，分别以`Drawable`和`UIImage`作为Native图片加载框架需要加载后返回给`NImage`的图像的载体

#### BoxFit

采用Native进行Fit效果处理的方案，Native收到图片加载请求，根据其中的`fit`参数直接对图像进行处理，然后绘制到Surface上。

不考虑Flutter层使用`FittedBox`进行处理的原因是，不想在Flutter层缓存可能超出显示区域的纹理，例如`cover`效果，如果Flutter层处理，那么纹理就必需是完整的缩放后的大小，然后`FittedBox`才能进行显示处理，但这样缓存的纹理的大小就会超过实际显示的大小。

另一方面，Native层的图片加载框架如果本身支持不同fit的内存或文件缓存，也能有效利用起来。

## 更新日志

**V0.1-alpha**

init

## 任务

- [x] support gif、ani-webp

- [x] support background color

- [x] support different boxfit

- [x] support the manager of textures based on size

- [x] seperate `SDWebImageLoader` from `ios`

- [ ] improve the demo

- [ ] memory test

- [ ] migrate to swift package manager
