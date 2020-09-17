////
////  TestViewController.swift
////  Classic
////
////  Created by Urayoan Miranda on 9/12/20.
////  Copyright © 2020 Urayoan Miranda. All rights reserved.
////
////https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45
//
//import UIKit
//import CocoaAsyncSocket
//import CoreData
//
//class DetectDeviceViewController: UIViewController, GCDAsyncUdpSocketDelegate, UISearchBarDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
//    
//    @IBOutlet weak var tableView:           UITableView!
//    @IBOutlet weak var searchController:    UISearchBar!
//    @IBOutlet weak var headerLabel:         UILabel!
//    
//    var searchActive: Bool  = false
//    let IP                  = "255.255.255.255"
//    let PORT: UInt16        = 4626
//    var socket:             GCDAsyncUdpSocket!
//    var detectedDevice:     ClassicDeviceLists!
//    var classicUrl:         String?
//    var classicPort:        Int32?
//    var reachability:       Reachability?
//    var selectedDevice      = [ClassicDeviceLists]()
//    
//    var swiftLibModbus:     SwiftLibModbus?
//    
//    // MARK: - Lists
//    var devicelists = [ClassicDeviceLists]() {
//        didSet {
//            guard devicelists != oldValue else { return }
//            devicesDidUpdate()
//        }
//    }
//    var searchedDevice = [ClassicDeviceLists]()
//    
//    
//    var refreshControl: UIRefreshControl = {
//        return UIRefreshControl()
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //MARK: Configure Buttons
//        headerLabel.font            = UIFont(name: GaugeView.defaultFontName, size: 20)
//        headerLabel.textColor       = UIColor(white: 0.7, alpha: 1)
//        
//        searchController.delegate   = self
//        tableView.dataSource        = self
//        
//        //declare color for text inputs and textviews
//        let fieldsColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
//        
//        //SearchBar tint and font color
//        let textFieldInsideSearchBar        = searchController.value(forKey: "searchField") as? UITextField
//        textFieldInsideSearchBar?.textColor = fieldsColor
//        textFieldInsideSearchBar?.tintColor = fieldsColor
//        
//        //Hide Keyboard
//        self.hideKeyboardWhenTappedAround()
//        // Register 'Nothing Found' cell xib
//        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
//        tableView.register(cellNib, forCellReuseIdentifier: "NothingFound")
//        
//        // Setup TableView
//        tableView.backgroundColor   = UIColor.clear
//        tableView.backgroundView    = nil
//        tableView.separatorStyle    = UITableViewCell.SeparatorStyle.none
//        
//        //MARK: Load dummy data
//        //loadDummyData()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        stopNotifier()
//        setupReachability(IP as String, useClosures: true)
//        startNotifier()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if (!socket.isClosed()) {
//            socket.close()
//        }
//    }
//    
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        print("Prefered Barstatus Style")
//        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
//        return .lightContent
//    }
//    
//    
//    deinit {
//        // Be a good citizen.
//    }
//    
//    func setupConnection() {
//        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
//        do { try socket.bind(toPort: PORT)} catch { print("Not Able to BIND Port")}
//        do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
//        do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not proceed")}
//        do { try socket.beginReceiving()} catch { print("beginReceiving not proceed")}
//    }
//    
//    //MARK:-GCDAsyncUdpSocketDelegate
//    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
//        print("incoming message: \(data)");
//        let signal:Signal = Signal.unarchive(d: data)
//        print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)")
//        //print("updSocket")
//        let lsb3 = signal.firstSignal & 0xFF
//        let msb3 = (signal.firstSignal >> 8) & 0xFF
//        let lsb2 = signal.secondSignal & 0xFF
//        let msb2 = (signal.secondSignal >> 8) & 0xFF
//        print("IP Address: \(lsb3).\(msb3).\(lsb2).\(msb2) with port \(signal.thirdSignal)")
//        
//        var deviceModel: String?
//        swiftLibModbus = SwiftLibModbus(ipAddress: "\(lsb3).\(msb3).\(lsb2).\(msb2)" as NSString, port: Int32(signal.thirdSignal), device: 1)
//        swiftLibModbus!.readRegistersFrom(startAddress: 4100, count: 1, success: { (array: [AnyObject]) -> Void in
//            if kDebugLog { print("Received Data 1: \(array)") }
//            
//            let unitId = Int(truncating: array[0] as! NSNumber)
//            if kDebugLog { print("Unit Type: \(unitId & 0xFF) PCB revision: \(unitId >> 8 & 0xFF)") }
//            switch (unitId & 0xFF) {
//            case 150:
//                if kDebugLog { print("Classic 150: \(unitId >> 8 & 0xFF)") }
//                deviceModel = "Classic 150"
//            case 200:
//                if kDebugLog { print("Classic 200: \(unitId >> 8 & 0xFF)") }
//                deviceModel = "Classic 200"
//            case 250:
//                if kDebugLog { print("Classic 250: \(unitId >> 8 & 0xFF)") }
//                deviceModel = "Classic 250"
//            case 251:
//                if kDebugLog { print("Classic 250 KS: \(unitId >> 8 & 0xFF)") }
//                deviceModel = "Classic 250 KS"
//            default:
//                if kDebugLog { print("Not Recognized") }
//                deviceModel = "Not Recognized"
//            }
//            
//            self.detectedDevice = ClassicDeviceLists(
//                ip:                 "\(lsb3).\(msb3).\(lsb2).\(msb2)",
//                port:               Int32(signal.thirdSignal),
//                deviceName:         deviceModel,
//                serialNumber:       "Serial Number"
//            )
//            
//            if (!self.devicelists.contains(self.detectedDevice)) {
//                self.devicelists.append(self.detectedDevice)
//            }
//        },
//        failure:  { (error: NSError) -> Void in
//            //Handle error
//            if kDebugLog { print("Error Getting Network Data 1: \(error)") }
//            self.swiftLibModbus!.disconnect()
//        })
//        self.swiftLibModbus!.disconnect()
////
////        detectedDevice = ClassicDeviceLists(
////            ip:                 "\(lsb3).\(msb3).\(lsb2).\(msb2)",
////            port:               Int32(signal.thirdSignal),
////            deviceName:         deviceModel,
////            serialNumber:       "Serial Number"
////        )
//        
////        if (!devicelists.contains(detectedDevice)) {
////            devicelists.append(detectedDevice)
////        }
//    }
//    
//    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
//    }
//    
//    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
//    }
//    
//    //MARK: Esto tiene que estar para poder hacer unwind del segue
//    @IBAction func unwindFromPresentedViewController(segue: UIStoryboardSegue) {
//        print("Unwind Form")
//    }
//    
//    private func devicesDidUpdate() {
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchActive {
//            return searchedDevice.count
//        } else {
//            return devicelists.isEmpty ? 0 : devicelists.count
//        }
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if devicelists.isEmpty {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFound", for: indexPath) as! DetectDeviceViewCell
//            cell.backgroundColor = .clear
//            cell.selectionStyle  = .none
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DetectDeviceViewCell
//            // alternate background color
//            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.2)
//            
//            if(searchedDevice.count == 0){
//                let deviceList = devicelists[indexPath.row]
//                cell.configureDeviceCell(deviceList: deviceList)
//            } else {
//                let deviceList = searchedDevice[indexPath.row]
//                cell.configureDeviceCell(deviceList: deviceList)
//            }
//            return cell
//        }
//    }
//    
//    // This method updates filteredData based on the text in the Search Box
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // When there is no text, filteredData is the same as the original data
//        // When user has entered text into the search box
//        // Use the filter method to iterate over all items in the data array
//        // For each item, return true if the item should be included and false if the
//        // item should NOT be included
//        searchedDevice = devicelists.filter {
//            return ($0.ip!.range(of: searchText, options: [.caseInsensitive]) != nil) || ($0.deviceName!.range(of: searchText, options: [.caseInsensitive]) != nil)
//        }
//        self.tableView.reloadData()
//    }
//}
//
////*****************************************************************
//// MARK: - TableViewDelegate
////*****************************************************************
//
//extension DetectDeviceViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        classicUrl  = devicelists[indexPath.row].ip
//        classicPort = devicelists[indexPath.row].port
//        print("SELECTED: \(String(describing: classicUrl)) - \(String(describing: classicPort))")
//        performSegue(withIdentifier: "SelectedSegue", sender: self)
//    }
//    
//    //*****************************************************************
//    // MARK: - Segue
//    //*****************************************************************
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SelectedSegue" {
//            let viewController          = segue.destination as! ViewController
//            viewController.classicURL   = classicUrl! as NSString
//            viewController.classicPort  = classicPort!
//        }
//    }
//}
//
//extension DetectDeviceViewController {
//    func setupReachability(_ hostName: String?, useClosures: Bool) {
//        let reachability: Reachability?
//        if let hostName = hostName {
//            reachability = try? Reachability(hostname: hostName)
//        } else {
//            reachability = try? Reachability()
//        }
//        self.reachability = reachability
//        if kDebugLog { print("--- Set up with host name: \(String(describing: hostName))") }
//        print("--- Set up with host name: \(String(describing: hostName))")
//        if useClosures {
//            reachability?.whenReachable = { reachability in
//                self.setupConnection()
//            }
//            reachability?.whenUnreachable = { reachability in
//                if (!self.socket.isClosed()) {
//                    self.socket.close()
//                }
//            }
//        } else {
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(reachabilityChanged(_:)),
//                name: .reachabilityChanged,
//                object: reachability
//            )
//        }
//    }
//    
//    @objc func reachabilityChanged(_ note: Notification) {
//        let reachability = note.object as! Reachability
//        if reachability.connection != .unavailable {
//            if (!self.socket.isClosed()) {
//                self.socket.close()
//            }
//        } else {
//            self.setupConnection()
//        }
//    }
//    
//    func startNotifier() {
//        if kDebugLog { print("--- start notifier") }
//        do {
//            try reachability?.startNotifier()
//        } catch {
//            if kDebugLog { print("Unable to start notifier") }
//            return
//        }
//    }
//    
//    func stopNotifier() {
//        reachability?.stopNotifier()
//        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
//        reachability = nil
//    }
//    
//    @objc func reachabilityChanged(note: Notification) {
//        let reachability = note.object as! Reachability
//        switch reachability.connection {
//        case .wifi:
//            if kDebugLog { print("Reachable via WiFi") }
//            setupConnection()
//        case .cellular:
//            if kDebugLog { print("Reachable via Cellular") }
//            if (!self.socket.isClosed()) {
//                self.socket.close()
//            }
//        case .unavailable:
//            if kDebugLog { print("Network not reachable") }
//            if (!self.socket.isClosed()) {
//                self.socket.close()
//            }
//        case .none:
//            if kDebugLog {print("Unknown") }
//            if (!self.socket.isClosed()) {
//                self.socket.close()
//            }
//        }
//    }
//}
