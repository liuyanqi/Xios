//
//  Robotx_BLE.swift
//  robotx_BLE
//
//  Created by Xipeng Wang on 4/13/17.
//  Copyright © 2017 Xipeng Wang. All rights reserved.
//

import CoreBluetooth

class Robotx_BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    //TODO: set as private members
    //MARK: BLE properties
    var centralManager:CBCentralManager!
    var robotxBLE:CBPeripheral?

    //MARK: varaibles
    let timerPauseInterval:TimeInterval!
    let timerScanInterval:TimeInterval!
    var keepScanning:Bool
    var deviceName:String!
    var deviceList:[String]!

    
    // MAKR: INIT
    init(timerPauseInterval:TimeInterval, timerScanInterval:TimeInterval, deviceName:String = "Robotx") {
        self.timerPauseInterval = timerPauseInterval
        self.timerScanInterval = timerScanInterval
        self.keepScanning = false
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    // MARK: DEINIT'
    
    // MARK: Interface methods
    func start() {
        if (centralManager.state == .poweredOn) {
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func getDeviceList()->[String] {
        
        return self.deviceList
    }
    
    func stop() {
        
    }
    
    // MARK: CBCentralManagerDelegate methods
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var message = ""
        
        switch central.state {
        case .poweredOff:
            message = "Bluetooth on this device is currently powered off."
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        case .poweredOn:
            message = "Bluetooth LE is turned on and ready for communication."
            
            //DEBUG:
            print(message)
            
            /*
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            // Initiate Scan for Peripherals
            if (true) {
                //Option 1: Scan for all devices
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            } else {
                // Option 2: Scan for devices that have the service you're interested in...
                let robotxBLEAdvertisingUUID = CBUUID(string: RobotxDevice.CBADVERTISINGUUID)
                print("Scanning for robotxBLE adverstising with UUID: \(robotxBLEAdvertisingUUID)")
                centralManager.scanForPeripherals(withServices: [robotxBLEAdvertisingUUID], options: nil)
            }
 */
        }
    }
    
    
    // Invoked when the central manager discovers a peripheral while scanning.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
        
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        self.deviceList.removeAll();
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            //print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            self.deviceList.append(peripheralName)
            if peripheralName == self.deviceName {
                print("ROBOTX_BLE FOUND! ADDING NOW!!!")
                // to save power, stop scanning for other devices
                keepScanning = false
                // save a reference to the sensor tag
                robotxBLE = peripheral
                robotxBLE!.delegate = self
                // Request a connection to the peripheral
                // centralManager.connect(robotxBLE!, options: nil)
            }
        }
    }
    
    
    // Invoked when a connection is successfully created with a peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO ROBOTX!!!")
        peripheral.discoverServices(nil)
    }
    
    
    // Invoked when the central manager fails to create a connection with a peripheral.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("**** CONNECTION TO ROBOTX FAILS!!!")
    }
    
    
    
    // Invoked when an existing connection with a peripheral is torn down.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("**** DISCONNECTED FROM ROBOTX!!!")
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        robotxBLE = nil
    }
    
    
    //MARK: - CBPeripheralDelegate methods
    
    // Invoked when you discover the peripheral’s available services.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES: \(String(describing: error?.localizedDescription))")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                // If we found either the temperature or the humidity service, discover the characteristics for those services.
                if (service.uuid == CBUUID(string: "FFE0")) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    // Invoked when you discover the characteristics of a specified service.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if let characteristics = service.characteristics {
            //var enableValue:UInt8 = 1
            //let enableBytes = Data(bytes: &enableValue, count: MemoryLayout<UInt8>.size)
            
            for characteristic in characteristics {
                print("Chacteristic: \(characteristic)")
                //robotxBLE?.setNotifyValue(true, for: characteristic)
                //robotxBLE?.writeValue(enableBytes, for: characteristic, type: .withResponse)
            }
        }
    }
    
    // Invoked when you retrieve a specified characteristic’s value,
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                print("lenght \(dataBytes.count)")
                for i in 0 ..< dataBytes.count {
                    print("next bytes: \(dataBytes[i].description)")
                }
                if let string = String(data: dataBytes, encoding: .utf8) {
                    print(string)
                }
            }
        }
    }

    //MARK: Private method
    func pauseScan() {
    // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

}

