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
    @State var isCenter: Bool = false
    @State var isPeripheral: Bool = false
    
    var body: some View {
        ZStack {
            if !isCenter && !isPeripheral {
                main
            }
            
            if isCenter {
                center
            }
            
            if isPeripheral {
                peripheral
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
        }
    }
    
    var center: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("中心设备")
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
            
            rectangleCentral
        }
        .padding()
    }
    
    var peripheral: some View {
        ZStack {
            VStack {
                Text("外围设备")
                    .font(.largeTitle)
                    .padding()
                
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
            
            rectanglePeripheral
        }
        .padding()
        .onAppear() {
            pm.initialize()
        }
    }
    
    var rectangleCentral: some View {
        Rectangle()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
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
            .foregroundColor(.blue)
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
