# OpenList App — iOS 原生客户端

OpenList / AList 的原生 iOS 客户端,使用 **SwiftUI + 苹果原生 Liquid Glass(iOS 26)** 构建,零 WebView。

本项目只保留两个端:

| 端 | 说明 |
| --- | --- |
| **iOS** | 本仓库 `ios-native/` — 原生 SwiftUI 应用,深度使用 `.glassEffect()` / `GlassEffectContainer` / `.buttonStyle(.glass)` 等原生液态玻璃 API |
| **Web** | 由 OpenList/AList 服务器自带网页端提供 — 浏览器直接访问服务器地址即可(前端项目:[OpenListTeam/OpenList-Frontend](https://github.com/OpenListTeam/OpenList-Frontend)) |

> Android、Windows、Linux、macOS 端代码已从本项目移除。

## 功能

- 登录 / 访客模式(跳过登录)
- 存储管理:列表、添加(驱动动态表单)、启用/停用、删除
- 文件浏览:目录下钻、图片缩略图、图片查看器(双指缩放)、视频播放(AVKit)、长按删除/下载
- 任务:未完成/已完成与进度
- 我的:用户信息、原生服务器设置、退出登录

## 本地构建

需要 **Xcode 26+(iOS 26 SDK)**:

```bash
cd ios-native
open OpenListApp.xcodeproj   # 选择 OpenListApp scheme,Cmd+R 运行
```

## CI 未签名 IPA

GitHub Actions 工作流 [`.github/workflows/ios-native-ipa.yml`](.github/workflows/ios-native-ipa.yml)
在推送到 `ios-native/**` 或手动触发(workflow_dispatch)时:

`xcodebuild archive`(关闭签名)→ 打包 `Payload/OpenListApp.app` → 生成 **`OpenListApp-iOS-unsigned-ipa`** 工件。

未签名 IPA 可通过 [TrollStore](https://github.com/opa334/TrollStore) 安装,
或用自己的证书通过 Xcode / iOS App Signer 重签后安装。

## 路线图

- 内嵌 OpenList Go 内核(OpenListMobile.xcframework),实现"本机服务"模式
- 文件上传、重命名、复制/移动
- 直链分享

## License

GPL-3.0(与上游 OpenListApp 一致)
