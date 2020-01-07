//
//  ViewController.swift
//  BLED
//
//  Created by Roman Matusewicz on 11/12/2019.
//  Copyright © 2019 Roman Matusewicz. All rights reserved.
//

import UIKit
import CoreBluetooth
import ColorSlider

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var parentView:MainViewController? = nil
    
    let BLEService = "DFB0"
    let BLECharacteristic = "DFB1"
    
    var lightMode:Int? = nil
    
    @IBOutlet weak var changeColorSlider: UISlider!
    @IBOutlet weak var modeButton: UIButton!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil);
        buttonMode()
        customiseNavigationBar()
       }
    
    // MARK: - Button Methods
    
    @IBAction func TurnOffButton(_ sender: UIButton) {
        let offValue: UInt8 = 254
        sliderColor(color: offValue)
       sendData(data: offValue)
    }
    @IBAction func ColorSelected(_ sender: UIButton) {
        var color: UInt8 = 255
        switch sender.tag {
        case 1:
            color = 32
        case 2:
            color = 70
        case 3:
            color = 80
        case 4:
            color = 96
        case 5:
            color = 118
        case 6:
            color = 134
        case 7:
            color = 176
        case 8:
            color = 192
        case 9:
            color = 216
        case 10:
            color = 0
        case 11:
            color = 16
        case 12:
            color = 24
        default:
            print("...")
        }
        sliderColor(color: color)
        sendData(data: color)
    }
    
    @IBAction func SendButton(_ sender: UIButton) {
        let color: UInt8 = 255
        sendData(data: color)
    }
    
    @IBAction func ColorSlider(_ sender: UISlider) {
        let color = UInt8(sender.value)
        sliderColor(color: color)
        sendData(data: color)

    }
    // MARK: - functions
    
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController?.navigationBar.barTintColor = UIColor.systemGray6
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let rightButton = UIButton()
        
        if (mainPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.white, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.green, for: [])
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
    
    func buttonMode(){
        if lightMode != nil {
            var modeValue = lightMode!%10
            
            switch modeValue {
            case 1:
                modeButton.setTitle("Light Off", for: .normal)
            case 2:
                modeButton.setTitle("Mode 1", for: .normal)
            case 3:
                modeButton.setTitle("Mode 2", for: .normal)
            case 4:
                modeButton.setTitle("Mode 3", for: .normal)
            default:
                print("mode")
            }
        } else {
            modeButton.setTitle("ON", for: .normal)
        }
        
    }
    
    func sliderColor (color: UInt8) {
        changeColorSlider.value = Float(color)
        switch color {
        case 0...7:
            changeColorSlider.thumbTintColor = UIColor.systemRed
            changeColorSlider.minimumTrackTintColor = UIColor.systemRed
        case 8...19:
            changeColorSlider.thumbTintColor = UIColor(red: 235/255, green: 102/255, blue: 20/255, alpha: 1)
            changeColorSlider.minimumTrackTintColor = UIColor(red: 235/255, green: 102/255, blue: 20/255, alpha: 1)
        case 20...29:
            changeColorSlider.thumbTintColor = UIColor.systemOrange
            changeColorSlider.minimumTrackTintColor = UIColor.systemOrange
        case 30...49:
            changeColorSlider.thumbTintColor = UIColor(red: 247/255, green: 224/255, blue: 22/255, alpha: 1)
            changeColorSlider.minimumTrackTintColor = UIColor(red: 247/255, green: 224/255, blue: 22/255, alpha: 1)
        case 50...75:
            changeColorSlider.thumbTintColor = UIColor(red: 137/255, green: 215/255, blue: 55/255, alpha: 1)
            changeColorSlider.minimumTrackTintColor = UIColor(red: 137/255, green: 215/255, blue: 55/255, alpha: 1)
        case 76...89:
            changeColorSlider.thumbTintColor = UIColor.systemGreen
            changeColorSlider.minimumTrackTintColor = UIColor.systemGreen
        case 90...109:
            changeColorSlider.thumbTintColor = UIColor(red: 37/255, green: 215/255, blue: 172/255, alpha: 1)
            changeColorSlider.minimumTrackTintColor = UIColor(red: 37/255, green: 215/255, blue: 172/255, alpha: 1)
        case 110...124:
            changeColorSlider.thumbTintColor = UIColor.systemTeal
            changeColorSlider.minimumTrackTintColor = UIColor.systemTeal
        case 125...159:
                changeColorSlider.thumbTintColor = UIColor.systemBlue
                changeColorSlider.minimumTrackTintColor = UIColor.systemBlue
        case 160...183:
            changeColorSlider.thumbTintColor = UIColor.systemIndigo
            changeColorSlider.minimumTrackTintColor = UIColor.systemIndigo
        case 184...204:
            changeColorSlider.thumbTintColor = UIColor.systemPurple
            changeColorSlider.minimumTrackTintColor = UIColor.systemPurple
        case 205...224:
            changeColorSlider.thumbTintColor = UIColor.systemPink
            changeColorSlider.minimumTrackTintColor = UIColor.systemPink
        case 225...253:
            changeColorSlider.thumbTintColor = UIColor.systemRed
            changeColorSlider.minimumTrackTintColor = UIColor.systemRed
        case 254:
            changeColorSlider.thumbTintColor = UIColor.lightGray
            changeColorSlider.minimumTrackTintColor = UIColor.lightGray
        default:
            print("...")
        }
    }
    
    func sendData(data: UInt8){
        let dataData = Data(repeating: data, count: 1)
        if (mainPeripheral != nil) {
            print("sending...")
            mainPeripheral?.writeValue(dataData, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("haven't discovered device yet")
        }
    }

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
                        sendData(data: 255)
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
                    let intValue = Int(stringValue)
                print("**\(stringValue)**")
                    lightMode = intValue
                    buttonMode()
                }
            }
            
            
        }
}

