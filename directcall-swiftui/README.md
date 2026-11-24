# iOS Quickstart for Direct Call of Sendbird Calls (SwiftUI)
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
![UI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE.md)

## Introduction

This sample app shows how to build 1:1 voice and video calls with [Sendbird Calls SDK for iOS](https://github.com/sendbird/sendbird-calls-ios) in a SwiftUI app. It uses CallKit and PushKit, so the app receives calls in the background and on the lock screen, and calls show in the Phone app's Recents.

> Note: You can only integrate one Sendbird application per app for your service regardless of the platforms. All users within your Sendbird application can communicate with each other across all platforms. This means that your iOS, Android, and web client app users can all make and receive calls with one another without any further setup. Note that all data is limited to the scope of a single application, and users in different Sendbird applications can't make and receive calls to each other.

Find out more about Sendbird Calls for iOS on [Calls for iOS doc](https://sendbird.com/docs/calls/v1/ios/getting-started/about-calls-sdk). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).

<br />

## Requirements

- Xcode 16 or later. The project uses folder-synchronized groups, which earlier versions of Xcode can't open.
- At least one physical iOS device running iOS 17.0 or later. Two devices are needed to make a call between them. The iOS Simulator has no camera and can't receive VoIP pushes.
- A Sendbird application with Calls enabled

The app installs [`SendBirdCalls`](https://github.com/sendbird/sendbird-calls-ios) with Swift Package Manager. Xcode resolves the package when you open the project.

<br />

## Getting started

### Create a Sendbird application

1. Log in or sign up for an account on [Sendbird Dashboard](https://dashboard.sendbird.com).
2. Create or select a call-activated application on the dashboard.
3. Keep your Sendbird application ID in a safe place for future reference.

### Create test users

1. On the Sendbird dashboard, navigate to the **Users** menu.
2. Create at least two new users: one as a `caller`, and the other as a `callee`.
3. Note the `user_id` of each user for future reference.

### Register a VoIP push certificate

VoIP pushes deliver incoming calls even when the app is in the background or not running. Register a valid VoIP Services certificate or Apple Push Notification service certificate on the [Sendbird Dashboard](https://dashboard.sendbird.com) under **Application** > **Settings** > **Notifications** > **Add certificate**. For details, see [How to Generate a Certificate for VoIP Push Notification](https://github.com/sendbird/guidelines-ios/tree/master/How%20to%20generate%20iOS%20certificate).

### Install and run the sample app

1. Open `QuickStart.xcodeproj` in this folder with Xcode.
2. In **Signing & Capabilities** of the `QuickStart` and `QuickStartIntent` targets, select your team. If you change the bundle identifier, use the one that your VoIP certificate is for.
3. Connect an iOS device, and run the `QuickStart` scheme.
4. If you have two devices, install the app on both.

### Sign in

The app asks for the Sendbird application ID and a user ID when it starts. Choose one of the following:

- **Sign in with QR code**: Scan a user-specific QR code generated in Calls studio on the Sendbird Dashboard.
- **Sign in manually**: Enter the application ID, the user ID, and an access token if your application requires one.
- **Open a URL**: Open `sendbird://<base64 encoded JSON>` on the device. The JSON has the same fields as the QR code: `app_id`, `user_id`, and `access_token`.

To always use your own application ID, call `SendBirdCall.configure(appId:)` in `application(_:didFinishLaunchingWithOptions:)` of `AppDelegate.swift`.

<br />

## Making your first call

1. Sign in on the primary device as the `caller`.
2. Sign in on the secondary device as the `callee`. You can also use the Calls widget on the Sendbird Dashboard as the `callee`.
3. On the primary device, enter the user ID of the `callee`, and tap the voice or video call button.
4. The incoming call shows on the `callee`'s device in the system call screen of CallKit, even when the device is locked.
5. Reverse the roles, and make a call from the other device.
6. If the two devices are near each other, use headphones to prevent audio feedback.

<br />

## Where to find each feature

| Feature | File | Sendbird Calls API |
|---|---|---|
| Set up incoming calls at launch | [`App/AppDelegate.swift`](QuickStart/App/AppDelegate.swift) | `SendBirdCall.addDelegate(_:identifier:)` |
| Sign in and out | [`Auth/AuthService.swift`](QuickStart/Auth/AuthService.swift) | `SendBirdCall.configure(appId:)`, `authenticate(with:completionHandler:)`, `registerVoIPPush(token:unique:completionHandler:)`, `unregisterVoIPPush(token:completionHandler:)`, `deauthenticate(completionHandler:)` |
| Receive VoIP pushes | [`Calling/PushKitHandler.swift`](QuickStart/Calling/PushKitHandler.swift) | `SendBirdCall.pushRegistry(_:didReceiveIncomingPushWith:for:completionHandler:)` |
| Report incoming calls to CallKit | [`Calling/CallEventHandler.swift`](QuickStart/Calling/CallEventHandler.swift) | `SendBirdCallDelegate.didStartRinging(_:)` |
| Answer, end, and mute on the CallKit screen | [`Calling/CallKitManager.swift`](QuickStart/Calling/CallKitManager.swift) | `DirectCall.accept(with:)`, `end()`, `SendBirdCall.audioSessionDidActivate(_:)` |
| Make a call | [`Calling/Dialer.swift`](QuickStart/Calling/Dialer.swift) | `SendBirdCall.dial(with:completionHandler:)` |
| Call state and controls | [`Calling/CallSession.swift`](QuickStart/Calling/CallSession.swift) | `DirectCallDelegate`, `muteMicrophone()`, `startVideo()`, `selectVideoDevice(_:completionHandler:)` |
| Show video in SwiftUI | [`Calling/VideoView.swift`](QuickStart/Calling/VideoView.swift) | `SendBirdVideoView`, `updateLocalVideoView(_:)`, `updateRemoteVideoView(_:)` |
| Choose the audio output | [`Calling/AudioRoutePicker.swift`](QuickStart/Calling/AudioRoutePicker.swift) | `SendBirdCall.routePickerView(frame:)` |
| Call history | [`History/CallHistoryStore.swift`](QuickStart/History/CallHistoryStore.swift) | `SendBirdCall.createDirectCallLogListQuery(with:)` |
| Call back from the Phone app's Recents | [`QuickStartIntent/IntentHandler.swift`](QuickStartIntent/IntentHandler.swift), [`Calling/StartCallRequest.swift`](QuickStart/Calling/StartCallRequest.swift) | `INStartCallIntent` |
| Sound effects | [`App/SoundEffects.swift`](QuickStart/App/SoundEffects.swift) | `SendBirdCall.addDirectCallSound(_:forType:)` |

<br />

## Using Sendbird Calls with SwiftUI

- **Set up calls in the app delegate, not in a view.** A VoIP push can launch the app in the background before any SwiftUI view exists, and iOS terminates an app that doesn't report the push to CallKit right away. The app connects `AppDelegate` with `@UIApplicationDelegateAdaptor`.
- **Keep the active call outside the views.** Calls can start outside SwiftUI, for example when the user answers on the lock screen. `CallRouter` keeps the active call, and `RootView` presents the call screen from it.
- **Create each `SendBirdVideoView` once.** `VideoView` creates the video view in `makeUIView(context:)` and never in `updateUIView(_:context:)`. To hide a video, change its opacity instead of removing the view.
- **Receive URLs and user activities in SwiftUI.** With the SwiftUI app life cycle, `sendbird://` URLs and Recents calls arrive at `.onOpenURL` and `.onContinueUserActivity`, not at the app delegate.
- **Set the call's delegate when the call screen appears.** SwiftUI can create a view's initial state more than once, so `CallSession` sets itself as the `DirectCall` delegate in `start()`.
- **Write `@SwiftUI.State` in files that also import SendBirdCalls.** SendBirdCalls has types named `State`, such as `Room.State` and `Participant.State`. Some versions of Xcode, such as Xcode 26, report `State` as ambiguous in a file that imports both modules. See `CallView.swift`.

<br />

## Advanced

For remote push notifications instead of PushKit, handling calls without media permission, and other topics, see [Advanced in the UIKit sample](../directcall-uikit/README.md#advanced).

<br />

## Reference

For further detail on Sendbird Calls for iOS, refer to [Sendbird Calls SDK for iOS README](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md).
