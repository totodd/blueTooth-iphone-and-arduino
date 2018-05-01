//
//  ViewController.swift
//  CoreMotionExample
//
//  Created by Maxim Bilan on 1/21/16.
//  Copyright © 2016 Maxim Bilan. All rights reserved.
//

import UIKit
import CoreMotion

import CoreBluetooth

class ViewController: UIViewController {
    

	let motionManager = CMMotionManager()
	var timer: Timer!
    var gyroDataG: CMGyroData!
    var magnetometerDataG: CMMagnetometerData!
    var accelerometerDataG: CMAccelerometerData!
    var state: Int = 0

    // Bluetooth
    
    let chipName = "TOTO-BL"
    let characteristicName = CBUUID(string:"FFE1")
    let targetCBUUID = CBUUID(string: "FFE0")

    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    var characteristicASCIIValue = NSString()
    
    var centralManager: CBCentralManager!
    var targetPeripheral : CBPeripheral!
    var bluezList: Set<String>!
    var targetCharacteristic: CBUUID!
    var blePeripheral : CBPeripheral!
    
    var targetService: CBService!
	
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var barHeight: NSLayoutConstraint!
    @IBOutlet weak var displayNum: UILabel!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var gyroX: UILabel!
    @IBOutlet weak var gyroY: UILabel!
    @IBOutlet weak var gyroZ: UILabel!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
		super.viewDidLoad()
        button.setTitle( "gyroData" , for: .normal )
        centralManager = CBCentralManager(delegate: self, queue: nil)

		motionManager.startAccelerometerUpdates()
		motionManager.startGyroUpdates()
		motionManager.startMagnetometerUpdates()
		motionManager.startDeviceMotionUpdates()
		
		timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
	}
    
    @IBAction func buttonPressed(_ sender: Any) {
        switch state {
        case 0:
            state = 1
            button.setTitle( "magnetoMeter" , for: .normal )
        case 1:
            state = 2
            button.setTitle( "acceleroMeter" , for: .normal )
        case 2:
            state = 0
            button.setTitle( "gyroData" , for: .normal )
        default:
            state = 0
        }
        
    }
    
	@objc func update() {
		if let accelerometerData = motionManager.accelerometerData {
//            print(accelerometerData)
            accelerometerDataG = accelerometerData
		}
		if let gyroData = motionManager.gyroData {
            gyroDataG = gyroData
//            print(gyroData)
            
		}
		if let magnetometerData = motionManager.magnetometerData {
//            print(magnetometerData)
            magnetometerDataG = magnetometerData
		}
		if let deviceMotion = motionManager.deviceMotion {
//            print(deviceMotion)
            
		}
        
//        switch state {
//        case 0:
//            gyroX.text = String(format:"X: %.01f",gyroDataG.rotationRate.x)
//            gyroY.text = String(format:"Y: %.01f",gyroDataG.rotationRate.y)
//            gyroZ.text = String(format:"Z: %.01f",gyroDataG.rotationRate.z)
//        case 1:
//            gyroX.text = String(format:"X: %.01f",magnetometerDataG.magneticField.x)
//            gyroY.text = String(format:"Y: %.01f",magnetometerDataG.magneticField.y)
//            gyroZ.text = String(format:"Z: %.01f",magnetometerDataG.magneticField.z)
//        case 2:
//            gyroX.text = String(format:"X: %.01f",accelerometerDataG.acceleration.x)
//            gyroY.text = String(format:"Y: %.01f",accelerometerDataG.acceleration.y)
//            gyroZ.text = String(format:"Z: %.01f",accelerometerDataG.acceleration.z)
//        default:
//            state = 0
//        }
//        let varable = magnetometerDataG.magneticField.x
//        bar.frame.size.height = CGFloat(varable)
//        barHeight.constant = CGFloat(varable/150*440)
//        displayNum.text = String(format:"%.01f", varable)
        
        if(barHeight.constant > CGFloat(220)){
            bar.backgroundColor = .red
        }else{
            bar.backgroundColor = .green
        }
	}
	
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(central.state == .poweredOn){
            id.text = "central Bluez powerOn"
        }else{
            id.text = "central Bluez PowerOff"
        }
        
        
        
        switch central.state{
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
//            centralManager.scanForPeripherals(withServices: [targetCBUUID])
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
        }
    }
    
    
    // discovered peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        blePeripheral = peripheral
        blePeripheral.delegate = self
        print(blePeripheral)
        if(blePeripheral?.name == chipName){
            centralManager.connect(blePeripheral)
            centralManager.stopScan()

        }
        
    }
    
    // connected peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        print(peripheral)

        //    let ttargetCBUUID = CBUUID(string: "FFE0")
        peripheral.delegate = self

        blePeripheral.discoverServices(nil)
        //    targetPeripheral.discoverServices([targetCBUUID])
        //    targetPeripheral.discoverServices([ttargetCBUUID])
        
    }
    
}
    // discovered services
extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("****************************************** services ********************************")
        print("Found \(services.count) services!")

        for service in services {
            print(service.uuid)
            print(service.uuid.uuidString)
            if(service.uuid == targetCBUUID){
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // discovered charactreristic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            print(characteristic.uuid)
            print(characteristic)

            if characteristic.uuid.isEqual(characteristicName)  {
                print("characteristic id matched")
                rxCharacteristic = characteristic

                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
//            if characteristic.uuid.isEqual(targetCharacteristic){
//                txCharacteristic = characteristic
//                print("Tx Characteristic: \(characteristic.uuid)")
//            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Value Recieved: \((characteristicASCIIValue as String))")
                displayNum.text = characteristicASCIIValue as String
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor!
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
                print("Rx Value \(String(describing: rxCharacteristic?.value))")
                print("Tx Value \(String(describing: txCharacteristic?.value))")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
}

