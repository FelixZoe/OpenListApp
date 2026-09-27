# OpenList — 原生 SwiftUI 客户端(苹果原生液态玻璃)

这是 OpenList/AList 的 **原生 iOS 客户端**,使用 SwiftUI + **iOS 26 苹果原生 Liquid Glass(液态玻璃)API** 构建,不依赖 Flutter/Web。

## 原生液态玻璃的使用点

- `GlassEffectContainer` + `.glassEffect(.regular, in:)`:登录页玻璃卡片字段与按钮
- `.buttonStyle(.glassProminent)` / `.buttonStyle(.glass)`:主/次按钮原生玻璃质感
- `.tabBarMinimizeBehavior(.onScrollDown)`:滚动时底部标签栏最小化为玻璃圆点
- 工具栏、底部标签栏、弹层、分段控件均由 iOS 26 SDK 自动渲染为原生 Liquid Glass
- 图片查看器的悬浮操作按钮使用 `.buttonStyle(.glass)`

## 功能

- 登录(任意 OpenList/AList 服务器)/ 跳过登录
- 存储管理:列表、添加(驱动动态表单)、启用/停用、删除
- 文件浏览:目录下钻导航、图片缩略图、图片查看器(缩放)、视频播放(AVKit)、长按删除/下载
- 任务:未完成/已完成列表与进度
- 我的:用户信息、服务器版本、退出登录

## 本地构建

需要 **Xcode 26+(iOS 26 SDK)**:

```bash
cd ios-native
open OpenListApp.xcodeproj   # 选择 OpenListApp scheme,直接 Cmd+R 运行
```

## CI 未签名 IPA

GitHub Actions 工作流 `.github/workflows/ios-native-ipa.yml` 在推送或手动触发时:
`xcodebuild archive`(关闭签名)→ 打包 `Payload/OpenListApp.app` → 生成 `OpenListApp-unsigned.ipa` 工件。

未签名 IPA 可通过 [TrollStore](https://github.com/opa334/TrollStore) 安装,
或用自己的证书通过 Xcode/iOS App Signer 重签后安装。

## 路线图

- 内嵌 OpenList Go 内核(OpenListMobile.xcframework),实现"本机服务"模式
- 文件上传、重命名、复制/移动
- WebDAV / 直链分享
