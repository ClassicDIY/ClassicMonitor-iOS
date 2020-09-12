//
//  InSocket.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

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
        print("incoming message: \(data)");
        let signal:Signal = Signal.unarchive(d: data)
        print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)")
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    }
}
