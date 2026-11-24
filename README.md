# iOS Quickstart for Direct Call of Sendbird Calls
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)

## Introduction

This repository contains iOS sample apps that show how to build 1:1 voice and video calls with [Sendbird Calls SDK for iOS](https://github.com/sendbird/sendbird-calls-ios).

| Folder | Description |
|---|---|
| [`directcall-swiftui/`](directcall-swiftui) | **Main sample.** Sample app built with SwiftUI, CallKit and PushKit. Requires iOS 17.0 or later and Xcode 16 or later. |
| [`directcall-uikit/`](directcall-uikit) | Sample app built with UIKit and storyboards. Requires iOS 15.0 or later. |

Each folder is an independent Xcode project. Open the project in the folder you want to try and follow the README in that folder. If you are starting a new app, start with [`directcall-swiftui/`](directcall-swiftui).

Both apps use the same bundle identifier, `com.sendbird.calls.quickstart`, so that they can use the same VoIP push certificate. Install only one of them on a device at a time, and delete the installed one before you install the other. If you install the UIKit sample over the SwiftUI sample, iOS keeps the window scene of the SwiftUI sample, and the UIKit sample shows a black screen.

### More about Sendbird Calls for iOS

Find out more about Sendbird Calls for iOS on [Calls for iOS doc](https://sendbird.com/docs/calls/v1/ios/getting-started/about-calls-sdk). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).
