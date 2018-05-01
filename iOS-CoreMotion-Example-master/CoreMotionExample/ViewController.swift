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
    var centralManager: CBCentralManager!
    var targetPeripheral : CBPeripheral!
    var bluezList: Set<String>!
    var targetCharacteristic: CBUUID!
    let targetCBUUID = CBUUID(string: "FFE0")
    var blePeripheral : CBPeripheral!

	
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
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        blePeripheral = peripheral
        blePeripheral.delegate = self
        print(blePeripheral)
        if(blePeripheral?.name == "BT05"){
            centralManager.connect(blePeripheral)
            centralManager.stopScan()

        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        print(peripheral)

        //    let ttargetCBUUID = CBUUID(string: "FFE0")
        blePeripheral.discoverServices(nil)
        //    targetPeripheral.discoverServices([targetCBUUID])
        //    targetPeripheral.discoverServices([ttargetCBUUID])
        
    }
    
}

extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("************** services ******************")

        for service in services {
            print(service.uuid)
            print(service.uuid.uuidString)
            //      if(service.uuid.uuidString == "180F"){
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
            //      }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print("************** characteristics ******************")

        for characteristic in characteristics {
            print(characteristic)
            print(characteristic.uuid.uuidString)
            
            if(characteristic.properties.contains(.read)){
                print("\(characteristic.uuid):properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if(characteristic.properties.contains(.notify)){
                print("\(characteristic.uuid):properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
