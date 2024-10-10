import Foundation
import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralDelegate, CBPeripheralManagerDelegate, ObservableObject {
    private var peripheralManager: CBPeripheralManager?
    let serviceUUID = CBUUID(string: "9f37e282-60b6-42b1-a02f-7341da5e2eba")
    let characteristicUUID = CBUUID(string: "87654321-4321-8765-4321-876543218765")
    private var characteristic: CBMutableCharacteristic?
    
    var services: [CBMutableService]?
    
    @Published var offsetX: CGFloat = 0
    @Published var offsetY: CGFloat = 0
    
    /**
     初始化
     */
    func initialize() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        startAdvertising()
    }
    
    func startAdvertising() {
        // 创建特性
        characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        // 创建服务
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic!]
        
        services=[service]
        peripheralManager?.add(service)
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [services![0].uuid]])
    }
    
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
    }
    
    /**
     中央设备请求读取特性的值
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic == characteristic {
            let data = "Hello from Peripheral".data(using: .utf8)!
            request.value = data
            peripheralManager?.respond(to: request, withResult: .success)
        }
    }
    
    /**
     处理中央设备写入的数据
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        guard let request = requests.first, let data = request.value else { return }
        
        let receivedString = String(data: data, encoding: .utf8)
        print("Received data from Central: \(receivedString ?? "")")
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
        peripheral.respond(to: request, withResult: .success)
    }
    
    /**
     数据准备好发送到已订阅的中央设备
     */
    func sendUpdateToCentral(pos: String) {
        if let dataToSend = pos.data(using: .utf8) {
            peripheralManager?.updateValue(dataToSend, for: characteristic!, onSubscribedCentrals: nil)
        }
    }
}
