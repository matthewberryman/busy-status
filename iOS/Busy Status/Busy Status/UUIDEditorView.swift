//
//  UUIDEditorView.swift
//  Busy Status
//
//  Created by Matthew Berryman on 26/12/2023.
//

import SwiftUI
import CoreBluetooth

extension String {
    var isHexNumber: Bool {
        filter(\.isHexDigit).count == count
    }
}

struct UUIDEditorView: View {
    
    @Binding var ble: BLEController
    
    @State var ledServiceUUID: String = ""
    @State var ledServiceCharacteristicUUID: String = ""
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "Service ID",
                    text: $ledServiceUUID
                )
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                TextField(
                    "Characteristic ID",
                    text: $ledServiceCharacteristicUUID
                )
                .disableAutocorrection(true)
            }.textFieldStyle(.roundedBorder)
            Section {
                Text("enter two four-digit hexadecmimal numbers")
            }.disabled(validate(input: ledServiceUUID) && validate(input: ledServiceCharacteristicUUID))
            Section {
                Button("Set device IDs") {
                    print("Setting device IDs…")
                    ble.setLedServiceUUID(UUID: ledServiceUUID)
                    ble.setLedServiceCharacteristicUUID(UUID: ledServiceCharacteristicUUID)
                }
                Button("Test device connection") {
                    // action goes here
                }
            }.disabled(!validate(input: ledServiceUUID) || !validate(input: ledServiceCharacteristicUUID))
        }
    }
    
    func validate(input: String) -> Bool {
        if (input.count != 4) {
            return false
        } else {
            return input.isHexNumber
        }
    }
}
