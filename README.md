# Mung-Flutter

### 1. Mung-Flutter：是一个基于Flutter编写，使用豆瓣开源API开发的一个项目。

![image](https://github.com/mochixuan/Mung/blob/master/Ui/ui/ic_launcher.png?raw=true)

### 2. 功能概述

- **启动页**：添加了启动页主要是让最开始进入时不至于显示白屏。
- **数据保存** ：支持断网加载缓存数据。
- **主题换肤** ：现在只支持切换主题颜色，本项目没几张图片。
- **查看电影详情** ：支持查看电影详情包括评论。
- **一键搜索**： 支持标签和语句查找相关的电影。
- **查看剧照**: 支持缩放图片。
- **适配iphonx及以上**:适配了IphoneX及以上的头部和底部的安全区域问题。

### 3.1 动态演示(Android版)
![](https://user-gold-cdn.xitu.io/2019/5/22/16add3b749fe8761?w=240&h=400&f=gif&s=4173548)

### 3.2 运行结果图

![image](https://github.com/mochixuan/Mung/blob/master/Ui/ppt/icon_ppt1.png?raw=true)
![image](https://github.com/mochixuan/Mung/blob/master/Ui/ppt/icon_ppt2.png?raw=true)

### 4. 使用到的框架

- **flutter_swiper** ：Banner栏图片轮播的效果。
- **rxdart** ：和Rxjava、RxJs、RxSwift差不多，这里主要用它的BehaviorSubject配合Bloc模式实现状态管理。
- **shared_preferences** ：简单的数据保存，比较细致的数据存储如列表等还是建议使用数据库。
- **dio** ：实现网络请求，一个非常不错的三方网络包，功能非常多，如果刚入门或者项目比较急建议使用这个。
- **flutter_spinkit** : 加载时显示的加载组件，挺不错，建议看下。
- **photo_view**： 图片缩放组件，因为安卓里的photoview正好选了，使用了一个简单的功能，暂时没发现问题。
