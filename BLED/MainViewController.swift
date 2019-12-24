//
//  ViewController.swift
//  BLED
//
//  Created by Roman Matusewicz on 11/12/2019.
//  Copyright © 2019 Roman Matusewicz. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var parentView:MainViewController? = nil
    let greenLEDCharUUID = CBUUID(string: "f0001112-0451-4000-b000-000000000000")
    var greenLEDCharacteristic: CBCharacteristic?
    
    let BLEService = "DFB0"
    let BLECharacteristic = "DFB1"

    @IBOutlet weak var receivedMessageText: UILabel!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil);
        
        customiseNavigationBar()

       }
    
    @IBAction func SendButton(_ sender: UIButton) {
        let color: UInt8 = 0xff
        let dataData = Data(repeating: color, count: 1)
//        let colorToString = String(color)
//        let dataToSend = colorToString.data(using: String.Encoding.utf8)
        
        if (mainPeripheral != nil) {
            print("sending...")
            mainPeripheral?.writeValue(dataData, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            print(dataData)
        } else {
            print("haven't discovered device yet")
        }
    }
    
    @IBAction func ColorSlider(_ sender: UISlider) {
        let color = UInt8(sender.value)
        let dataData = Data(repeating: color, count: 1)
        
        if (mainPeripheral != nil) {
            print("sending...")
            mainPeripheral?.writeValue(dataData, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            print(dataData)
        } else {
            print("haven't discovered device yet")
        }
    }
    
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        
        let rightButton = UIButton()
        
        if (mainPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "scan-segue" {
            let scanController : ScanTableTableViewController = segue.destination as! ScanTableTableViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanController.parentView = self
            
        }
        
    }
    
    // MARK: - Button Methods
    @objc func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }
    
    @objc func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        manager?.cancelPeripheralConnection(mainPeripheral!)
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        mainPeripheral = nil
        customiseNavigationBar()
        print("Disconnected" + peripheral.name!)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    // MARK: - CBPeripheralDelegate Methods
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
            for service in peripheral.services! {
                
                print("Service found with UUID: " + service.uuid.uuidString)
                
                //device information service
                if (service.uuid.uuidString == "180A") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
                //GAP (Generic Access Profile) for Device Name
                // This replaces the deprecated CBUUIDGenericAccessProfileString
                if (service.uuid.uuidString == "1800") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
                //Bluno Service
                if (service.uuid.uuidString == BLEService) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

            //get device name
            if (service.uuid.uuidString == "1800") {
                
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == "2A00") {
                        peripheral.readValue(for: characteristic)
                        print("Found Device Name Characteristic")
                    }
                    
                }
                
            }
            
            if (service.uuid.uuidString == "180A") {
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == "2A29") {
                        peripheral.readValue(for: characteristic)
                        print("Found a Device Manufacturer Name Characteristic")
                    } else if (characteristic.uuid.uuidString == "2A23") {
                        peripheral.readValue(for: characteristic)
                        print("Found System ID")
                    }
                    
                }
                
            }
            
            if (service.uuid.uuidString == BLEService) {
                
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == BLECharacteristic) {
                        //we'll save the reference, we need it to write data
                        mainCharacteristic = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("Found Bluno Data Characteristic")
                    }
                    
                }
                
            }
            
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            
            
            if (characteristic.uuid.uuidString == "2A00") {
                //value for device name recieved
                let deviceName = characteristic.value
                print(deviceName ?? "No Device Name")
            } else if (characteristic.uuid.uuidString == "2A29") {
                //value for manufacturer name recieved
                let manufacturerName = characteristic.value
                print(manufacturerName ?? "No Manufacturer Name")
            } else if (characteristic.uuid.uuidString == "2A23") {
                //value for system ID recieved
                let systemID = characteristic.value
                print(systemID ?? "No System ID")
            } else if (characteristic.uuid.uuidString == BLECharacteristic) {
                //data recieved
                if(characteristic.value != nil) {
                    let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
                print("**\(stringValue)**")
                    //receivedMessageText.text = stringValue
                }
            }
            
            
        }
        
    
}

//********************************************
