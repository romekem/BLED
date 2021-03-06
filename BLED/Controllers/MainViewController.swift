//
//  ViewController.swift
//  BLED
//
//  Created by Roman Matusewicz on 11/12/2019.
//  Copyright © 2019 Roman Matusewicz. All rights reserved.
//

import UIKit
import CoreBluetooth
import Spring

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var parentView:MainViewController? = nil
    
    let BLEService = "DFB0"
    let BLECharacteristic = "DFB1"
    
    private var colorUI: Colors = Colors()
    
    private var mode: Int? {
        didSet {
            if mode != oldValue {
                sliderColor()
                colorUI.mode = mode!
            }
        }
    }
    
    @IBOutlet weak var changeColorSlider: UISlider!
    @IBOutlet weak var modeButton: SpringButton!
    @IBOutlet weak var offButton: SpringButton!
    @IBOutlet var colorButtons: [SpringButton]!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil);
        buttonMode()
        customiseNavigationBar()
       }
    
    // MARK: - Button Methods
    
    @IBAction func offButtonPressed(_ sender: UIButton) {
        let offValue: UInt8 = 254
        sliderColor()
        sendData(data: offValue)
        if (mainPeripheral == nil) {
            colorUI.shakeButton(offButton)
            
        }
    }
    @IBAction func ColorSelected(_ sender: UIButton) {
        let color = colorUI.colorValue(tagValue: sender.tag)
        
        colorUI.lightColor = color
        sliderColor()
        sendData(data: color)
        
        colorButtons[sender.tag-1].animation = "pop"
        colorButtons[sender.tag-1].curve = "linear"
        colorButtons[sender.tag-1].velocity = 0.4
        colorButtons[sender.tag-1].animate()
    }
    
    @IBAction func modeButtonPressed(_ sender: UIButton) {
        let modeChange: UInt8 = 255
        sendData(data: modeChange)
        sendData(data: 253)
        if colorUI.lightColor != nil {
            sendData(data: colorUI.lightColor!)
        }
        if (mainPeripheral == nil) {
            colorUI.shakeButton(modeButton)
        }
        
    }
    
    @IBAction func ColorSlider(_ sender: UISlider) {
        let color = UInt8(sender.value)
        colorUI.lightColor = color
        sliderColor()
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
        modeButton.setTitle(colorUI.getModeText(), for: .normal)
    }
    
    func sliderColor () {
        var actualColor: UIColor? = nil
        
        if let color = colorUI.lightColor {
            if mode == 1 {
                actualColor = UIColor.gray
            } else if mode == 2 {
                actualColor = colorUI.getColor(color: color)
            } else if mode == 3 {
                actualColor = UIColor.systemYellow
            } else if mode == 4 {
                actualColor = UIColor.white
            }
            changeColorSlider.value = Float(color)
            changeColorSlider.thumbTintColor = actualColor
            changeColorSlider.minimumTrackTintColor = actualColor
        }
        
    }
    
    func sendData(data: UInt8){
        let dataData = Data(repeating: data, count: 1)
        if (mainPeripheral != nil) {
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
                        sendData(data: 253)
                        
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
                    if stringValue.count < 4 {
                        mode = intValue!%10
                    }
                    print("**\(stringValue)**")
                    buttonMode()
                    
                }
            }
        
        }
}

