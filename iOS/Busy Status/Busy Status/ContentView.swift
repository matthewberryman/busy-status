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
    @ObservedObject private var pollingManager = PollingManager<String>(pollingInterval: 2.0)
    
    @State private var isFocusAuthorized = false
    @State private var isNotificationAuthorized = false
    
    @ObservedObject private var ble: BLEController = BLEController()
    
    var body: some View {
        NavigationView {
            VStack {
                if (!ble.isAllowed()){
                    Text("Bluetooth permission is currently disabled for the application. Enable Bluetooth from the application settings.")
                }
                if (!isNotificationAuthorized) {
                    Text("You need to enable notifications for the application to work. Please enable in settings.")
                }
                if (!isFocusAuthorized) {
                    Text("You need to grant permissions to check focus for the application to work. Please enable in settings.")
                }
                Button {
                    if (ble.isAllowed()) {
                        if (!ble.isConnected) {
                            ble.scanForSensor()
                        } else {
                            ble.disconnect()
                        }
                    }
                } label: {
                    Image(systemName: "antenna.radiowaves.left.and.right.circle").font(.system(size: 24))
                }.buttonStyle(.borderedProminent)
        
                List(ble.peripherals, id: \.self) {peripheral in
                    Button {
                        ble.connect(peripheral: peripheral)
                    } label: {
                        Text("\(peripheral.name!)")
                    }
                }
            
            }.padding()
        }.onAppear {
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
        if (ble.isAllowed() && ble.isConnected && isFocusAuthorized && isNotificationAuthorized) {
            ble.sendCommand(status: !INFocusStatusCenter.default.focusStatus.isFocused!)
        }
    }
}

#Preview {
    ContentView()
}
