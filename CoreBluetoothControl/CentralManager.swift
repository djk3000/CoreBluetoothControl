import Foundation
import CoreBluetooth

class CentralManager :  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject{
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var peripheralName: String = ""
    var serviceUUID = CBUUID(string: "9f37e282-60b6-42b1-a02f-7341da5e2eba")
    let characteristicUUID = CBUUID(string: "87654321-4321-8765-4321-876543218765")
    
    private var rssiThreshold: Int = -60
    
    var characteristic: CBCharacteristic?
    
    @Published var name: String = ""
    @Published var offsetX: CGFloat = 0
    @Published var offsetY: CGFloat = 0
    @Published var changeUUID: String = ""
    
    func initialize() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        changeUUID = Int(arc4random_uniform(8999)+1000).description
        let uuidString = "9f37e282-60b6-42b1-a02f-7341da5e\(changeUUID)"
        serviceUUID = CBUUID(string: uuidString)
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
    
    /*
     连接该设备
     */
    func connectToPeripheral() {
        if let peripheral = peripheral {
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    /**
     初始化后开始扫描
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        startScanning()
    }
    
    /**
     判断连接设备
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let advertismentServiceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else {
            return
        }
        
        if RSSI.intValue < rssiThreshold {
            // RSSI 低于阈值，断开连接
            disconnectFromPeripheral()
            return
        }
        
        let uuid = advertismentServiceUUIDs.first!
        name = peripheral.name ?? uuid.uuidString
        self.peripheral = peripheral
        connectToPeripheral()
        
        //        /*
        //         根据蓝牙名称判断
        //         */
        //        if peripheral.name == "蓝牙名称" {
        //            if peripheral.name == nil { return }
        //            print(peripheral.name ?? 0)
        //            print(RSSI.intValue)
        //
        //            self.peripheral = peripheral
        //            connectToPeripheral()
        //        }
    }
    
    /**
     断开连接
     */
    func disconnectFromPeripheral() {
        if let peripheral = peripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
            self.peripheral = nil
        }
    }
    
    /**
     是否外围设备连接成功
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //        stopScanning()
        peripheral.delegate = self
        
        peripheral.discoverServices(nil)
    }
    
    /**
     连接service后发现特征
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Unable to discover services: \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                //                print(service.uuid.uuidString)
                if service.uuid == serviceUUID {
                    peripheral.services?.forEach { service in
                        peripheral.discoverCharacteristics([characteristicUUID], for: service)
                    }
                }
            }
        }
    }
    
    /**
     订阅特征
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    // 发现所需的特性后，订阅它
                    self.characteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    // 写入数据到特性
    func writeDataToPeripheral(data: Data) {
        if let characteristic = characteristic {
            peripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    /**
     处理从外围收到的数据
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // 处理特性的值更新
        if characteristic.uuid == characteristicUUID {
            if let data = characteristic.value {
                // 处理接收到的数据
                let receivedString = String(data: data, encoding: .utf8)
                print("Received data from Peripheral: \(receivedString ?? "")")
                switch receivedString {
                case "up"  :
                    offsetY = offsetY - 10
                case "down"  :
                    offsetY = offsetY + 10
                case "left"  :
                    offsetX = offsetX - 10
                case "right"  :
                    offsetX = offsetX + 10
                default :
                    offsetX = 0
                    offsetY = 0
                }
            }
        }
    }
    
    // 外围设备断开连接时调用
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // 外围设备与中央设备的连接已断开
        self.peripheral = nil
        self.name = ""
        print("断开连接")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // 外围设备关闭程序
//        for service in invalidatedServices {
//            // 处理被修改或删除的服务
//            disconnectFromPeripheral()
//        }
        disconnectFromPeripheral()
    }
}
