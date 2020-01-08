# SendBird Calls—QuickStart Guide for iOS


## Introduction

The `SendBirdCalls` framework enables realtime VoIP communication between app users.  This repository contains a sample application intended to demonstrate a simple implementation of this framework. This readme document details how to get up and running using this sample application.

## Prerequisites
- Mac OS with developer mode enabled
- Xcode
 - **[Git Large File Storage](https://git-lfs.github.com/)** installed
- Homebrew
- At least one physical iOS device running iOS `10.0+`

## Environement Setup

### Step 1. Install Git LFS
 
To download `SendBirdWebRTC`, you first **MUST** install Git LFS by running the following command
```
$ brew install git-lfs
```
Please refer to [https://git-lfs.github.com](https://git-lfs.github.com)
 
### Step 2. Install SDK via CocoaPods
Open a terminal window, move to your project directory, and then open a `Podfile` by running the following command.
```
$ open Podfile
```
Check whether the `Podfile` includes the following:
```
platform :ios, '8.0'
 
target 'YourProject' do
  use_frameworks!
 
  pod 'SendBirdCalls'
end
```
And then install the `SendBirdCalls` framework via CocoaPods
```
$ pod install
```
> **Important**: Make sure to install Git LFS before installing the pod.
> **Important**: Check the size of `webRTC.framework` in `SendBirdWebRTC` folder. It MUST be over 800 MB. If it is less than 800MB please follow the steps in the [SDK’s troubleshooting section](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md#library-not-loaded-webrtcframework).


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
To connect this sample Android application to the SendBird application specified in the previous step, the **App ID** of the SendBird application must be specified inside the sample Android application’s source code.

Find the `application(_, didFinishLaunchingWithOptions:)`method of the `AppDelegate.swift` instance. Replace `YOUR_APP_ID` with the `App ID` of the SendBird application created previously.
 
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
In order to receive incoming calls, Apple’s [PushKit framework](https://developer.apple.com/documentation/pushkit) must be implemented. This is done by registering device tokens associate with your SendBird Applications. For more information refer to Apple’s [Voice Over IP (VoIP) Best Practices
](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html)

## Making calls

 1. Log in to the primary device’s sample application with the ID of the user designated as the `caller`.
 2. Log in to the secondary device’s sample application with ID of the user designated as the `callee`.  Alternatively, use the Calls widget found on the Calls dashboard to login as the `callee`.
 3. On the primary device, specify the user ID of the `callee` and initiate a call.
 4. If all steps have been followed correctly, an incoming call notification will appear on the `callee` user’s device.
 5. Reverse roles, and initiate a call from the other device.
 6. If the `caller` and `callee` devices are near each other, use headphones to prevent audio feedback.
 7. The SendBird Calls Android Sample has been successfully implemented.

## Reference

 - [SendBird Calls iOS SDK Readme](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md)
