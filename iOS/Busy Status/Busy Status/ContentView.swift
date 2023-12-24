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
    
    @State var ble: BLEController = BLEController()
    
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Please leave open. Use the app by changing your focus status.")
            
        }
        .padding()
        .onAppear {
            INFocusStatusCenter.default.requestAuthorization { status in
                print(status)
            }
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                
                if let error = error {
                    // Handle the error here.
                }
                
                // Enable or disable features based on the authorization.
            }

            pollingManager.startPolling {
                self.pollingAction()
            }
        }
    }
    
    
    func pollingAction() {
        // Perform your polling logic here
        print("Polling...")
        if (!ble.isConnected) {
            ble.scanForSensor();
        } else {
            print(!INFocusStatusCenter.default.focusStatus.isFocused!)
            ble.sendCommand(status: !INFocusStatusCenter.default.focusStatus.isFocused!)
        }
        
        
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Board.self, inMemory: true)
}
