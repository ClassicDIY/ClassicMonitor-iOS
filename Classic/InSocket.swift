//
//  InSocket.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
//https://stackoverflow.com/questions/26790129/swift-receive-udp-with-gcdasyncudpsocket

import CocoaAsyncSocket

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    let IP = "255.255.255.255"
    let PORT:UInt16 = 4626
    var socket:GCDAsyncUdpSocket!
    override init(){
        super.init()
        setupConnection()
    }
    func setupConnection(){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        do { try socket.bind(toPort: PORT)} catch { print("Not Able to BIND Port")}
        do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
        do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not proceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not proceed")}
    }
    
    //MARK:-GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        //print("incoming message: \(data)");
        let signal:Signal = Signal.unarchive(d: data)
        //print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)")
        
        let lsb3 = signal.firstSignal & 0xFF
        let msb3 = (signal.firstSignal >> 8) & 0xFF
        let lsb2 = signal.secondSignal & 0xFF
        let msb2 = (signal.secondSignal >> 8) & 0xFF
        print("IP Address: \(lsb3).\(msb3).\(lsb2).\(msb2) with port \(signal.thirdSignal)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    }
}
