# SendBird Calls—QuickStart Guide for iOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/sendbird/quickstart-calls-ios/blob/develop/LICENSE.md)

[![Download:
AppStore](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/gb/app/id1503477603)

## Introduction

The Calls SDK for iOS is used to initialize, configure, and build voice and video calling functionality into an iOS application. This repository contains a sample application intended to demonstrate a simple implementation of this framework, as well as the preliminary steps of implementing the Calls SDK into a project. 

## Prerequisites
- Mac OS with developer mode enabled
- Xcode
- **[Git Large File Storage](https://git-lfs.github.com/)** installed
- Homebrew
- At least one physical iOS device running iOS `10.0+`

## Environement Setup

### Step 1. Install Git LFS
 
To download `SendBirdWebRTC`, Git LFS **MUST** be installed by running the following command
```
$ brew install git-lfs
```
Please refer to [https://git-lfs.github.com](https://git-lfs.github.com)
 
### Step 2. Install SDK via CocoaPods
Open a terminal window, navigate to the project directory, and then open the `Podfile` by running the following command.
```
$ open Podfile
```
Make sure that the `Podfile` includes the following:
```
platform :ios, '9.0'
 
target 'Project' do
  use_frameworks!
 
  pod 'SendBirdCalls'
end
```
And then install the `SendBirdCalls` framework via CocoaPods
```
$ pod install
```
> **Important**: Make sure to install Git LFS before installing the pod. Check the size of `WebRTC.framework` in `SendBirdWebRTC` folder. It MUST be over 800 MB. If the loaded SendBirdWebRTC framework is smaller than that, check the Git Large File Storage settings and download again. Refer to [SDK’s troubleshooting section](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md#library-not-loaded-webrtcframework).


## Creating a SendBird application

 1. Login or Sign-up for an account at [dashboard](https://dashboard.sendbird.com).
 2. Create or select an application on the SendBird Dashboard.
 3. Note the `Application ID` for future reference.
 4. [Contact sales](https://sendbird.com/contact-sales) to get the `Calls` menu enabled in the dashboard. (Self-serve coming soon.)

## Creating test users

 1. In the SendBird dashboard, navigate to the `Users` menu.
 2. Create at least two new users, one that will be the `caller`, and one that will be the `callee`.
 3. Note the `User ID` of each user for future reference.


## Specifying the App ID
As shown below, the `SendBirdCall` instance must be initiated when a client app is launched. Initialization is done by setting the `APP_ID` of the SendBird application in the dashboard. This **App ID** of the SendBird application must be specified inside the sample application’s source code.

Find the `application(_:didFinishLaunchingWithOptions:)` method from `AppDelegate.swift`. Replace `YOUR_APP_ID` with the `App ID` of the SendBird application created previously.
 
```Swift
SendBirdCall.configure("YOUR_APP_ID")
```
 
## Installing and running the sample application

 1. Verify that Xcode open on the development Mac and the sample application project is open
 2. Plug the primary iOS device into the Mac running Xcode
 3. Unlock the iOS device 
 4. Run the application by pressing the **`▶`** Run button or typing `⌘+R`
 5. Open the newly installed app on the iOS device
 6. If two iOS devices are available, repeat these steps to install the sample application on both the primary device and the secondary device.

## Registering push tokens
In order to make and receive calls, authenticate the user with SendBird server with the `SendBirdCall.authenticate(with:)` method and **register a VoIP push token** to SendBird. Register a VoIP push token during authentication by either providing it as a parameter in the `authenticate()` method, or after authentication has completed using the `SendBirdCall.registerVoIPPush(token:)` method. VoIP Push Notification will also enable receiving calls even when the app is in the background or terminated state. A valid VoIP Services certificate or Apple Push Notification Service certificate also needs to be registered on the `SendBird Dashboard` : `Application` → `Settings` → `Notifications` → `Add certificate`.

For more details about generating certificates, see this guide: [How to Generate a Certificate for VoIP Push Notification](https://github.com/sendbird/how-to-generate-ios-certificate)

To handle a native-implementation of receiving incoming calls, implement Apple’s [PushKit framework](https://developer.apple.com/documentation/pushkit) and CallKit. This is done by registering the push tokens associated with the SendBird Applications and handling appropriate events. For more information refer to Apple’s [Voice Over IP (VoIP) Best Practices
](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html)

## Making calls

 1. Log in to the primary device’s sample application with the ID of the user designated as the `caller`.
 2. Log in to the secondary device’s sample application with ID of the user designated as the `callee`.  Alternatively, use the Calls widget found on the Calls dashboard to login as the `callee`.
 3. On the primary device, specify the user ID of the `callee` and initiate a call.
 4. If all steps have been followed correctly, an incoming call notification will appear on the `callee` user’s device.
 5. Reverse roles, and initiate a call from the other device.
 6. If the `caller` and `callee` devices are near each other, use headphones to prevent audio feedback.

# Advanced

## Handling Incoming Calls without Media Permission
When using CallKit to process your calls, there may be instances where the user has not granted media(audio/video) permissions. Without the necessary permissions, the call will proceed without audio and/or video, which can be critical to the user experience. Some other third-party apps implement different user flow to prevent the call from starting without according media permissions. However, due to CallKit requiring new incoming calls to be reported to CallKit immediately, there are some issues in implementing such change. Here is our solution:

We need to make sure that our PushKit usage is in sync with the device's media permission state. If media permissions are not granted, we should destroy existing push token to stop receiving VoIP Push and ignore any incoming calls. 

> Note, however, Apple's requires every VoIP Push Notifications to report a new incoming call to CallKit as writte in [Apple's Documentation](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry). Be sure to test your implementation and refer to Apple's [guidelines](https://developer.apple.com/documentation/pushkit/responding_to_voip_notifications_from_pushkit) on VoIP Push Notifications and CallKit. 

In your AppDelegate's `pushRegistry(_:didReceiveIncomingPushWith:for:completion:)`, add the following: 
```swift
guard AVAudioSession.sharedInstance().recordPermission == .granted else { // Here, we check if the audio permission is granted
  // If it is not granted, we will destroy current push registration to stop receiving push notifications
  self.voipRegistry?.desiredPushTypes = nil
  
  // We will ignore current call and not present a new CallKit view. This will not cause crashes as we have destroyed current PushKit usage.
  completion()
  return
}

// Media permissions are granted, we will process the incoming call. 
SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
  ...
```
This will ignore incoming call if the media permissions are not granted, and prevent any future calls from being delivered to the device. 


In your AppDelegate's `application(_:didFinishLaunchingWithOptions:)`, you may also want to register VoIP Push Notification only if the media permissions are granted.
```swift
if AVAudioSession.sharedInstance().recordPermission == .granted {
  self.voipRegistration()
}
```

Note, however, destroying existing PKPushRegistry will prevent any future VoIP Push Notifications to be sent to the device. If you want to start receiving VoIP Push Notifications again, you must re-register PKPushRegistry by doing `self.voipRegistry?.desiredPushTypes = [.voIP]`.

## Reference

 - [SendBird Calls iOS SDK Readme](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md)
