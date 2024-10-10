//
//  BlePeripheralManager.swift
//  CoreBluetoothControl
//
//  Created by 邓璟琨 on 2024/10/10.
//

import Foundation
import CoreBluetooth

class BLEPeripheralManager: NSObject, CBPeripheralManagerDelegate,ObservableObject {
    var peripheralManager: CBPeripheralManager?

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    // 启动不包含服务 UUID 的广告
    func startAdvertising() {
        if peripheralManager?.isAdvertising == true {
            stopAdvertising()
            print("停止")
        }
        
        // 开始只广播设备名称，不包含服务UUID
        peripheralManager?.startAdvertising([
            CBAdvertisementDataLocalNameKey: "My BLE Device DJK"  // 仅广播设备名称
        ])
        
        print("开始广播")
    }

    // 停止广告
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
    }

    // Peripheral Manager Delegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()  // 当蓝牙设备准备好时开始广播
        } else {
            print("Bluetooth is not available.")
        }
    }
}
