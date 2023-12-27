//
//  BLEController.swift
//  Busy Status
//
//  Created by Matthew Berryman on 21/12/2023.
//

import Foundation
import CoreBluetooth

class BLEController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isSwitchedOn = false
    @Published var isConnected = false
    var board: CBPeripheral?
    var characteristic: CBCharacteristic?
    var myCentral: CBCentralManager!
    
    @Published var ledServiceUUID: CBUUID? = CBUUID(string: "180F")
    @Published var ledServiceCharacteristicUUID: CBUUID? = CBUUID(string: "2A58")
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setLedServiceUUID(UUID: String) {
        ledServiceUUID = CBUUID(string: UUID)
    }
    
    func setLedServiceCharacteristicUUID(UUID: String) {
        ledServiceCharacteristicUUID = CBUUID(string: UUID)
    }
    
    func isAllowed() -> Bool {
        return CBCentralManager.authorization == .allowedAlways
    }
    
    func scanForSensor() {
        print("scanning")
        if (ledServiceUUID != nil && ledServiceCharacteristicUUID != nil) {
            let serviceUUIDs: [CBUUID] = [ledServiceUUID!]
            myCentral.scanForPeripherals(withServices: serviceUUIDs, options: nil)
        }
    }
        
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        print("connecting")
        myCentral.connect(peripheral)
        board = peripheral
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        peripheral.delegate = self //
        //board = peripheral
        board!.discoverServices([ledServiceUUID!])
        isConnected = true
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {

        if let errorService = error{

            print(errorService)

            return
        }
        else if let services = peripheral.services as [CBService]? {
            for service in services{
                peripheral.discoverCharacteristics([ledServiceCharacteristicUUID!], for: service)
            }
        }
        print("==>",peripheral.services!)
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        characteristic = service.characteristics!.first!
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        isConnected = false
    }
    
    func sendCommand(status: Bool) {
        let cmd = Data([UInt8(truncating: status as NSNumber)])
        if (characteristic != nil) {
            board!.writeValue(cmd, for: characteristic!, type: .withResponse)
        }
    }
    
}
