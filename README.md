# iOS Quickstart for Direct Call of Sendbird Calls
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/sendbird/quickstart-calls-ios/blob/develop/LICENSE.md)

[![Download:
AppStore](https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg)](https://apps.apple.com/gb/app/id1503477603)

## Introduction

Sendbird Calls SDK for iOS is used to initialize, configure, and build voice and video calling functionality into your iOS client app. In this repository, you will find the steps you need to take before implementing the Calls SDK into a project, and a sample app which contains the code for implementing voice and video call. 

> Note: You can only integrate one Sendbird application per app for your service regardless of the platforms. All users within your Sendbird application can communicate with each other across all platforms. This means that your iOS, Android, and web client app users can all make and receive calls with one another without any further setup. Note that all data is limited to the scope of a single application, and users in different Sendbird applications can't make and receive calls to each other.

### More about Sendbird Calls for iOS

Find out more about Sendbird Calls for iOS on [Calls for iOS doc](https://sendbird.com/docs/calls/v1/ios/getting-started/about-calls-sdk). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).

<br />

## Before getting started

This section shows you the prerequisites you need for testing Sendbird Calls for iOS sample app.

### Requirements

The minimum requirements for Calls SDK for iOS sample are: 

- Mac OS with developer mode enabled
- Xcode
- Homebrew
- At least one physical iOS device running iOS 9.0 and later 
- Swift 4.0 and later

### Environment setup

Installing the Calls SDK is simple if you’re familiar with using external libraries or SDKs in your projects. After creating your Sendbird application from your dashboard, you can choose to install the Calls SDK using **Swift Package Manager**, **CocoaPods** or **Carthage**.

##### - Swift Package Manager
Go to your Swift Package Manager's `File` tab and select `Swift Packages`. Then choose `Add package dependency`.

Add the `SendBirdCalls` framework into your Package Repository with the following URL: https://github.com/sendbird/sendbird-calls-ios.

To add the package, select an appropriate dependency rule and click `Add Package`.

##### - CocoaPods

Open a terminal window. Navigate to the project directory, and then open the `Podfile` by running the following command:

```bash
$ open Podfile
```

Make sure that the `Podfile` includes the following:

```bash
platform :ios, '9.0'
 
target 'Project' do
    use_frameworks!
    
    pod 'SendBirdCalls'
end
```

Install the `SendBirdCalls` framework via **CocoaPods**.

```bash
$ pod install
```

##### - Carthage

You can also use **Carthage** to integrate the `SendBirdCalls` framework into your Xcode project.

1. Install Carthage into your project by running `brew install carthage` in your project directory or choose any of other installation options.
2. Create a `Cartfile` in the same directory where your **.xcodeproj** or **.xcworkspace** is.
3. Add `github “sendbird/sendbird-calls-ios”` and github `“sendbird/sendbird-webrtc-ios”` dependencies to your `Cartfile`.
4. Run carthage update.
5. A `Cartfile.resolved` file and a Carthage directory will appear in the same directory where your .xcodeproj or .xcworkspace is.
6. Drag the built **.framework** binaries from **Carthage/Build/iOS** into your application’s Xcode project.
7. On your application targets’ **Build Phases** settings tab, click the **+** icon and choose **New Run Script Phase**. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell: `usr/local/bin/carthage copy-frameworks`
8. Add the paths to the frameworks you want to use under **Input Files**. For example:
```bash
$(SRCROOT)/Carthage/Build/iOS/SendBirdCalls.framework
```
```bash
$(SRCROOT)/Carthage/Build/iOS/WebRTC.framework
```
9. Add the paths to the copied frameworks to the **Output Files**. For example:
```bash
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SendBirdCalls.framework
```
```bash
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/WebRTC.framework
```
10. For more information, refer to the [Carthage’s guide](https://github.com/Carthage/Carthage#quick-start).

<br />

## Getting started

If you would like to try the sample app specifically fit to your usage, you can do so by following the steps below. 

### Create a Sendbird application

 1. Login or Sign-up for an account on [Sendbird Dashboard](https://dashboard.sendbird.com).
 2. Create or select a call-activated application on the dashboard.
 3. Keep your Sendbird application ID in a safe place for future reference. 

### Create test users

 1. On the Sendbird dashboard, navigate to the **Users** menu.
 2. Create at least two new users: one as a `caller`, and the other as a `callee`.
 3. Note the `user_id` of each user for future reference.

### Specify the Application ID

As shown below, the `SendBirdCall` instance must be initiated when a sample client app is launched. To initialize the sample with your Sendbird application, go to the Sendbird dashboard, create a Sendbird application, and then specify the `APP_ID` inside the sample app’s source code. 

In the source code, find the `application(_:didFinishLaunchingWithOptions:)` method from `AppDelegate.swift`. Replace `SAMPLE_APP_ID` with `APP_ID` of your Sendbird application created earlier.
 
```swift
SendBirdCall.configure("SAMPLE_APP_ID")
```
 
### Install and run the sample app

1. Verify that Xcode is open on your Mac system and the sample app project is open. 
2. Plug the primary iOS device into the Mac running Xcode
3. Unlock the iOS device
4. Run the application by pressing the `▶` **Run** button or typing `⌘+R`
5. Open the newly installed app on the iOS device
6. If two iOS devices are available, repeat these steps to install the sample app on each device.

<br />

## Making your first call

### Register push tokens

VoIP Push Notification enables receiving calls even when the app is in the background or in the terminated state. 
 
To make and receive calls, authenticate the user with Sendbird server with the `SendBirdCall.authenticate(with:)` method and register a VoIP push token to Sendbird server. 
 
You can register a VoIP push token (specific, the current user’s) by passing it as an argument to a parameter either in the `authenticate()` method during authentication, or in the `SendBirdCall.registerVoIPPush(token:)` method after completing the authentication. 
 
Furthermore, a valid VoIP Services certificate or Apple Push Notification Service certificate also needs to be registered on the [Sendbird Dashboard](https://dashboard.sendbird.com) which you can do so on **Add certificate** under **Application** > **Settings** > **Notifications**.

#### More about certificates

For more details about generating certificates, refer to [How to Generate a Certificate for VoIP Push Notification](https://github.com/sendbird/guidelines-ios/tree/master/How%20to%20generate%20iOS%20certificate).

#### More about native-implementation

To handle a native-implementation of receiving incoming calls, implement Apple’s [PushKit](https://developer.apple.com/documentation/pushkit) and [CallKit](https://developer.apple.com/documentation/callkit) frameworks. To implement the frameworks, register the push tokens associated with Sendbird Applications and handling of appropriate events. For more information, refer to Apple’s [Voice Over IP (VoIP) Best Practices
](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html)

### How to make a call

1. Log in to the sample app on the primary device with the user ID set as the `caller`.
2. Log in to the sample app on the secondary device using the ID of the user set as the `callee`. Alternatively, you can also use the Calls widget found on the Calls dashboard to log in as the `callee`.
3. On the primary device, specify the user ID of the `callee` and initiate a call.
4. If all steps are followed correctly, an incoming call notification will appear on the device of the `callee`.
5. Reverse the roles. Initiate a call from the other device.
6. If the two testing devices are near each other, use headphones to make a call to prevent audio feedback.

<br />

## Advanced

### Remote push notifications

Instead of PushKit and CallKit, you can also choose to receive remote push notifications for incoming calls.

For a sample app with remote push notifications, refer to the [feature/remote-push-notifications](https://github.com/sendbird/quickstart-calls-directcall-ios/tree/feature/remote-push-notifications) branch.

### Handle an incoming call without media permission

When using CallKit to process your call, there may be times where a user makes a call without allowing media permission for audio and/or video access. Without such permission, the call will proceed without audio and/or video, which may not deliver the intended user experience. On the other hand, some other calling apps implement different user flow and require a media permission before starting a call. 
 
Thus, you may face some issues regarding implementation because CallKit requires every VoIP Push Notifications to report a new incoming call instantaneously as specified on [Apple's Documentation](https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/2875784-pushregistry). When you face an issue related to this matter, refer to the following steps: 
 
First, make sure that PushKit usage is in sync with the device's media permission state. If media permission is not allowed, destroy the existing push token to stop receiving VoIP Push and to ignore any incoming calls. Be sure to test your implementation and refer to [Apple's guidelines](https://developer.apple.com/documentation/pushkit/responding_to_voip_notifications_from_pushkit) on VoIP Push Notifications and CallKit.

Second, to ignore an incoming call if the media permission is not allowed and to prevent any future calls from being delivered to the device, on your `AppDelegate's pushRegistry(_:didReceiveIncomingPushWith:for:completion:)`, add the following:

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

Third, if you would like to register VoIP Push Notification only if the media permission is allowed, on your AppDelegate's `application(_:didFinishLaunchingWithOptions:)`, add the following:

```swift
if AVAudioSession.sharedInstance().recordPermission == .granted {
    self.voipRegistration()
}
```

> Note: Destroying existing PKPushRegistry will prevent any future VoIP Push Notifications to be sent to the device. If you want to start receiving VoIP Push Notifications again, you must re-register PKPushRegistry by using `self.voipRegistry?.desiredPushTypes = [.voIP]`.

### Create a local video view before accepting an incoming call  

You can create a current user's local video view and customize its appearance before accepting an incoming call. Follow the steps below to customize the current user’s local video view:

1. Add a `UIView` to your storyboard.
2. Create a view with the frame you want by using the `SendBirdVideoView` object.
3. To add a subview, [embed](https://github.com/sendbird/quickstart-calls-ios/blob/develop/QuickStart/Extensions/UIKit/UIView%2BExtension.swift) the `SendBirdVideoView` to the `UIView` from **Step 1**.
4. Find an appropriate camera device by accessing the `availableVideoDevice` property of `DirectCall`.
5. Start capturing video contents from the camera by calling the `DirectCall.selectVideoDevice(_:completionHandler:)` method.

```swift
@IBOutlet weak var localVideoView: UIView?

// Create SendBirdVideoView
let localSBVideoView = SendBirdVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)

// Embed the SendBirdVideoView to UIView
self.localVideoView?.embed(localSBVideoView)

// Start rendering local video view
guard let frontCamera = (call.availableVideoDevice.first { $0.position == .front }) else { return }
call.selectVideoDevice(frontCamera) { (error) in
    // TODO: handle an error
}
```

### Allow only one call at a time

Currently Sendbird Calls only supports a one-to-one call and the call waiting feature isn’t available yet. Using the `SendBirdCall.getOngoingCallCount()` method, you can retrieve the number of the current user’s ongoing calls and end a call if the call count has reached its limit.

```swift
if SendBirdCall.getOngoingCallCount() > 1 {
    call.end()
}
```

If you’re using Apple’s CallKit framework, you should use `CXProviderConfiguration` instead to set the allowed number of the current user’s ongoing calls as shown below:

```swift
let configuration = CXProviderConfiguration(localizedName: "Application Name")
configuration.maximumCallsPerCallGroup = 1
configuration.maximumCallGroups = 1
...

let provider = CXProvider(configuration: configuration)
```

### Sound Effects
You can use different sound effects to enhance the user experience for events that take place while using Sendbird Calls. 

To add sound effects, use the `SendBirdCall.addDirectCallSound(_:forType:)` method for the following events: dialing, ringing, reconnecting, and reconnected. Remember to set sound effects before the mentioned events occur. To remove sound effects, use the `SendBirdCall.removeDirectCallSound(_:forType:)` method.

```swift
// Play on a caller’s side when making a call.
SendBirdCall.addDirectCallSound("dialing.mp3", forType: .dialing)

// Play on a callee’s side when receiving a call.
SendBirdCall.addDirectCallSound("ringing.mp3", forType: .ringing)

// Play when a connection is lost, but the SDK immediately attempts to reconnect.
SendBirdCall.addDirectCallSound("reconnecting.mp3", forType: .reconnecting)

// Play when the connection is re-established.
SendBirdCall.addDirectCallSound("reconnected.mp3", forType: .reconnected)
```

If you’re using Apple’s CallKit framework, you should use `CXProviderConfiguration.ringtoneSound` instead to add sound effects as ringtones like the following:

```swift
let configuration = CXProviderConfiguration()
...
configuration.ringtoneSound = "ringing.mp3"
```

For more information about sound effects, see the <link>SDK for iOS README for Sound effects.</link>


<br />

## Reference

For further detail on Sendbird Calls for iOS, refer to [Sendbird Calls SDK for iOS README](https://github.com/sendbird/sendbird-calls-ios/blob/master/README.md).
