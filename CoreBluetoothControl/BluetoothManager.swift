//
//  BluetoothManager.swift
//  CoreBluetoothControl
//
//  Created by 邓璟琨 on 2024/10/10.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevice: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // 检查蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 开始扫描设备
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    // 发现蓝牙设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, !name.isEmpty {
                // 如果设备不在已发现列表中，则添加
                if !discoveredDevices.contains(peripheral) {
                    discoveredDevices.append(peripheral)
                }
            } else {
                // 设备名称为空的设备不进行处理
//                print("Discovered device without name, ignoring.")
            }
    }
    
    // 连接设备
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
        peripheral.delegate = self
        connectedDevice = peripheral
    }
    
    // 设备连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown device")")
        peripheral.discoverServices(nil)
    }
    
    // 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // 发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic)")
            }
        }
    }
}
