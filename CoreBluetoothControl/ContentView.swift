//
//  ContentView.swift
//  CoreBluetoothControl
//
//  Created by 邓璟琨 on 2023/10/13.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var cm: CentralManager = CentralManager()
    @StateObject var pm: PeripheralManager = PeripheralManager()
    @StateObject var manager: BluetoothManager = BluetoothManager()
    @StateObject var BleperManager: BLEPeripheralManager = BLEPeripheralManager()
    @State var isCenter: Bool = false
    @State var isPeripheral: Bool = false
    @State var isManager: Bool = false
    
    var body: some View {
        ZStack {
            if !isCenter && !isPeripheral && !isManager {
                main
            }
            
            if isCenter {
                center
            }
            
            if isPeripheral {
                peripheral
            }
            
            if isManager {
                managerSearch
            }
        }
    }
}

extension ContentView {
    var main: some View {
        HStack {
            Button("中心设备") {
                isCenter = true
            }
            
            Button("外围设备") {
                isPeripheral = true
            }
            
            Button("扫描设备") {
                isManager = true
            }
            
            Button("只广播") {
                BleperManager.startAdvertising()
            }
        }
    }
    
    var managerSearch: some View{
        Text("Discovered Devices")
            .font(.headline)
        
        // 列表显示设备名称
        return List(manager.discoveredDevices, id: \.identifier) { device in
            Button(action: {
                manager.connectToDevice(device)
            }) {
                // 如果设备名称为空，则显示 "Unknown Device"
                Text(device.name ?? "Unknown Device")
                    .padding()
            }
        }
    }
    
    var center: some View {
        ZStack {
            rectangleCentral
            
            VStack(spacing: 20) {
                Text("中心设备")
                    .font(.largeTitle)
                
                Text("配对码：\(cm.changeUUID)")
                    .font(.largeTitle)
                
                Text("正在扫描，等待连接")
                
                Button("重新扫描") {
                    cm.stopScanning()
                    cm.startScanning()
                }
                
                if cm.name != ""{
                    VStack(spacing: 20) {
                        Text("已连接设备: \(cm.name)")
                        
                        HStack {
                            Button("断开连接") {
                                cm.disconnectFromPeripheral()
                            }
                            
                            Button("还原位置") {
                                cm.writeDataToPeripheral(data: "Send data to 外围".data(using: .utf8)!)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button {
                                cm.writeDataToPeripheral(data: "up".data(using: .utf8)!)
                            } label: {
                                Text("上")
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                cm.writeDataToPeripheral(data: "down".data(using: .utf8)!)
                            } label: {
                                Text("下")
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            
                            Button {
                                cm.writeDataToPeripheral(data: "left".data(using: .utf8)!)
                            } label: {
                                Text("左")
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                cm.writeDataToPeripheral(data: "right".data(using: .utf8)!)
                            } label: {
                                Text("右")
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .onAppear() {
                cm.initialize()
            }
        }
        .padding()
    }
    
    var peripheral: some View {
        ZStack {
            rectanglePeripheral
            
            VStack {
                Text("外围设备")
                    .font(.largeTitle)
                    .padding()
                
                VStack {
                    Text("请输入配对码：\(pm.pairCode)")
                    
                    HStack {
                        ForEach(1..<4){ index in
                            Button {
                                pm.enterPairCode(code: index.description)
                            } label: {
                                Text("\(index)")
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    HStack {
                        ForEach(4..<7){ index in
                            Button {
                                pm.enterPairCode(code: index.description)
                            } label: {
                                Text("\(index)")
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    HStack {
                        ForEach(7..<10){ index in
                            Button {
                                pm.enterPairCode(code: index.description)
                            } label: {
                                Text("\(index)")
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    Button {
                        pm.enterPairCode(code: "0")
                    } label: {
                        Text("0")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    HStack {
                        Button {
                            pm.pairCode = ""
                        } label: {
                            Text("清空配对码")
                                .frame(width: 100, height: 40)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            pm.startAdvertising()
                        } label: {
                            Text("开始配对")
                                .frame(width: 100, height: 40)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                HStack {
                    Button {
                        pm.sendUpdateToCentral(pos: "up")
                    } label: {
                        Text("上")
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        pm.sendUpdateToCentral(pos: "down")
                    } label: {
                        Text("下")
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    
                    Button {
                        pm.sendUpdateToCentral(pos: "left")
                    } label: {
                        Text("左")
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        pm.sendUpdateToCentral(pos: "right")
                    } label: {
                        Text("右")
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .onAppear() {
            pm.initialize()
        }
    }
    
    var rectangleCentral: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
            .opacity(0.5)
            .padding(.top, cm.offsetY)
            .padding(.bottom, -cm.offsetY)
            .padding(.leading, cm.offsetX)
            .padding(.trailing, -cm.offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        cm.offsetX = value.translation.width
                        cm.offsetY = value.translation.height
                    }
                    .onEnded { _ in
                        cm.offsetX = 0
                        cm.offsetY = 0
                    }
            )
    }
    
    var rectanglePeripheral: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
            .opacity(0.5)
            .padding(.top, pm.offsetY)
            .padding(.bottom, -pm.offsetY)
            .padding(.leading, pm.offsetX)
            .padding(.trailing, -pm.offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        pm.offsetX = value.translation.width
                        pm.offsetY = value.translation.height
                    }
                    .onEnded { _ in
                        pm.offsetX = 0
                        pm.offsetY = 0
                    }
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
