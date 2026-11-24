//
//  Theme.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import SwiftUI

/// Colors and styles shared with the UIKit sample (`directcall-uikit`), so that both samples look the same.
enum Theme {
    // The storyboards of the UIKit sample define some colors in the Generic RGB color space ("calibratedRGB"),
    // which UIKit renders differently from the same numbers in sRGB. The values below are what the UIKit sample shows.

    /// #7B53EF in the Display P3 color space, the same as the UIKit sample's storyboards.
    static let purple = Color(.displayP3, red: 123 / 255, green: 83 / 255, blue: 239 / 255)
    /// #F6F8FC. The title of filled buttons.
    static let filledButtonTitle = Color(red: 246 / 255, green: 248 / 255, blue: 252 / 255)
    /// #F0F0F0 in Generic RGB, shown as #F3F3F3.
    static let fieldBackground = Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255)
    /// #2C2C2C in Generic RGB, shown as #3A3A3A.
    static let callBackground = Color(red: 58 / 255, green: 58 / 255, blue: 58 / 255)
    /// #A8A8A8 in Generic RGB, shown as #B7B7B7. Shows behind the local video until it starts.
    static let localVideoBackground = Color(red: 183 / 255, green: 183 / 255, blue: 183 / 255)
    static let divider = Color.black.opacity(0.12)
    static let secondaryText = Color.black.opacity(0.38)
    static let tertiaryText = Color.black.opacity(0.5)
}

/// A purple button that fills the width, like "Sign in with QR code".
struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Theme.filledButtonTitle)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Theme.purple, in: RoundedRectangle(cornerRadius: 4))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// A white button with a purple border that fills the width, like "Sign in with ID".
struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Theme.purple)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(.white, in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.purple, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// A gray text field that shows a purple border while editing.
struct InputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 17))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFocused)
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Theme.fieldBackground, in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.purple, lineWidth: isFocused ? 1 : 0))
    }
}

extension View {
    /// Shows an alert titled "Error" with a "Done" button while `message` is set.
    func errorAlert(_ message: Binding<String?>) -> some View {
        alert("Error", isPresented: Binding(get: { message.wrappedValue != nil }, set: { if !$0 { message.wrappedValue = nil } })) {
            Button("Done", role: .cancel) { }
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
