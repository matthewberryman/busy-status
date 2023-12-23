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
    
    let ledServiceUUID = CBUUID(string: "180A")
    let ledServiceCharacteristicUUID = CBUUID(string: "2A57")
    
    let ArduinoUUID = CBUUID(string: "1A2E813E-1C13-4B82-9A56-98D622785B6D")
    
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
    
    
    func connectToSensor() {
        print("scanning")
        let serviceUUIDs: [CBUUID] = [ledServiceUUID]
        myCentral.scanForPeripherals(withServices: serviceUUIDs, options: nil)
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
        board!.discoverServices([ledServiceUUID])
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
                peripheral.discoverCharacteristics([ledServiceCharacteristicUUID], for: service)
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
