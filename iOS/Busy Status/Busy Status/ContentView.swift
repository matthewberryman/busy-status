//
//  ContentView.swift
//  Busy Status
//
//  Created by Matthew Berryman on 21/12/2023.
//

import SwiftUI
import SwiftData
import Intents

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var boards: [Board]
    
    @ObservedObject private var pollingManager = PollingManager<String>(pollingInterval: 2.0)
    
    @State private var isFocusAuthorized = false
    @State private var isNotificationAuthorized = false
    
    @State private var ble: BLEController = BLEController()
    
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if (ble.isAllowed()) {
                Text("Please leave open. Use the app by changing your focus status.")
            } else {
                Text("Bluetooth permission is currently disabled for the application. Enable Bluetooth from the application settings.")
            }
            if (!isNotificationAuthorized) {
                Text("You need to enable notifications for the application to work. Please enable in settings.")
            }
            if (!isFocusAuthorized) {
                Text("You need to grant permissions to check focus for the application to work. Please enable in settings.")
            }
        }
        .padding()
        .onAppear {
            INFocusStatusCenter.default.requestAuthorization { status in
                print(status)
                switch status {
                    case INFocusStatusAuthorizationStatus.authorized:
                        isFocusAuthorized = true
                        break
                    default:
                        isFocusAuthorized = false
                }
                
            }
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print(error)
                    isNotificationAuthorized = false
                }
                isNotificationAuthorized = granted
            }
            pollingManager.startPolling {
                self.pollingAction()
            }
        }
    }

    
    func pollingAction() {
        // Perform your polling logic here
        print("Polling...")
        if (!ble.isConnected && ble.isAllowed()) {
            ble.scanForSensor()
        } else {
            if (isFocusAuthorized && isNotificationAuthorized) {
                ble.sendCommand(status: !INFocusStatusCenter.default.focusStatus.isFocused!)
            }
        }
        
        
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Board.self, inMemory: true)
}
