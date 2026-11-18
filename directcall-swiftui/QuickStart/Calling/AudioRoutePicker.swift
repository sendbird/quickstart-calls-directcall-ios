//
//  AudioRoutePicker.swift
//  QuickStart
//
//  Copyright © 2026 Sendbird Inc. All rights reserved.
//

import AVKit
import SendBirdCalls
import SwiftUI

/// The system picker for the audio output, such as the speaker or a Bluetooth headset.
///
/// It is transparent, so place it over an image that shows the current output.
struct AudioRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let picker = SendBirdCall.routePickerView(frame: .zero)
        if let routePickerView = picker as? AVRoutePickerView {
            routePickerView.tintColor = .clear
            routePickerView.activeTintColor = .clear
        }
        return picker
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}
