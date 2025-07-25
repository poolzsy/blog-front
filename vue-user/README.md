# 博客项目优化指南

## 项目构建优化

本项目已经进行了以下性能优化：

1. **图片资源压缩**
   - 使用 image-minimizer-webpack-plugin 压缩图片资源
   - 对大于10KB的图片进行压缩处理
   - 对小于10KB的图片转换为base64内联

2. **ElementUI库按需加载**
   - 从完整引入改为按需引入组件
   - 减少了初始加载的JS文件大小

3. **图片懒加载**
   - 使用vue-lazyload实现图片懒加载
   - 减少首屏加载资源，提高页面加载速度

4. **Gzip压缩**
   - 开启了Gzip压缩功能
   - 可进一步减小传输文件大小

5. **代码分割优化**
   - 优化了代码分割策略
   - 关闭了prefetch和preload，减少首屏带宽占用

## Build Setup

```bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

# build with bundle analyzer report
npm run analyz
```

## 解决的问题

- profile.63cbb3af.jpg (1.84 MiB) 图片过大问题
- chunk-elementUI.12892738.js (653 KiB) 库文件过大问题
- chunk-libs.eacf49e7.js (538 KiB) 第三方库文件过大问题

