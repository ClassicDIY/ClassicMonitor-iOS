//
//  TestViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
//https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45

import UIKit
import CocoaAsyncSocket
import CoreData

class DetectDeviceViewController: UIViewController, GCDAsyncUdpSocketDelegate, UISearchBarDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var tableView:           UITableView!
    @IBOutlet weak var searchController:    UISearchBar!
    @IBOutlet weak var headerLabel:         UILabel!
    @IBOutlet weak var addButton:           UIButton!
    
    var searchActive: Bool  = false
    let IP                  = "255.255.255.255"
    let PORT: UInt16        = 4626
    var socket:             GCDAsyncUdpSocket!
    var detectedDevice:     ClassicDeviceLists!
    var classicUrl:         String?
    var classicPort:        Int32?
    var reachability:       Reachability?
    var selectedDevice      = [ClassicDeviceLists]()
    
    // MARK: - Lists
    var devicelists = [ClassicDeviceLists]() {
        didSet {
            guard devicelists != oldValue else { return }
            devicesDidUpdate()
        }
    }
    var searchedDevice = [ClassicDeviceLists]()
    
    
    var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Configure Buttons
        headerLabel.font            = UIFont(name: GaugeView.defaultFontName, size: 20)
        headerLabel.textColor       = UIColor(white: 0.7, alpha: 1)
        
        addButton.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20)
        addButton.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        searchController.delegate   = self
        tableView.dataSource        = self
        
        //declare color for text inputs and textviews
        let fieldsColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
        //SearchBar tint and font color
        let textFieldInsideSearchBar        = searchController.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = fieldsColor
        textFieldInsideSearchBar?.tintColor = fieldsColor
        
        //Hide Keyboard
        self.hideKeyboardWhenTappedAround()
        // Register 'Nothing Found' cell xib
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "NothingFound")
        
        // Setup TableView
        tableView.backgroundColor   = UIColor.clear
        tableView.backgroundView    = nil
        tableView.separatorStyle    = UITableViewCell.SeparatorStyle.none
        
        //MARK: Load dummy data
        //loadDummyData()
    }
    
    func loadDummyData() {
        detectedDevice = ClassicDeviceLists(
            ip:                 "24.50.233.83",
            visualUrl:          "24.50.233.83",
            port:               502,
            deviceName:         "CLASSIC",
            serialNumber:       "Serial Number",
            MQTTUser:           "",
            MQTTPassword:       "",
            isMQTT:             false,
            mqttTopic:          ""
        )
        devicelists.append(self.detectedDevice)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopNotifier()
        setupReachability(IP as String, useClosures: true)
        startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (socket != nil && !socket.isClosed()) {
            socket.close()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if kDebugLog { print("Prefered Barstatus Style") }
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return .lightContent
    }
    
    
    deinit {
        // Be a good citizen.
    }
    
    func setupConnection() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        do { try socket.bind(toPort: PORT)} catch { print("Not Able to BIND Port")}
        do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
        do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not proceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not proceed")}
    }
    
    //MARK:-GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if kDebugLog { print("Incoming message: \(data)") }
        let signal:Signal = Signal.unarchive(d: data)
        
        if kDebugLog { print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)") }
        //print("updSocket")
        let lsb3 = signal.firstSignal   & 0xFF
        let msb3 = (signal.firstSignal  >> 8) & 0xFF
        let lsb2 = signal.secondSignal  & 0xFF
        let msb2 = (signal.secondSignal >> 8) & 0xFF
        if kDebugLog { print("Detected IP Address: \(lsb3).\(msb3).\(lsb2).\(msb2) with port \(signal.thirdSignal)") }
        
        DataManager.readRegistersValues(classicURL: "\(lsb3).\(msb3).\(lsb2).\(msb2)" as NSString, classicPort: Int32(signal.thirdSignal), device: 1, startAddress: 4100, count: 44) { data, error in
            if kDebugLog { print("ENTRO AL DATAMANAGER: \(String(describing: data))") }
            if error == nil {
                var deviceModel: String?
                let unitId = Int(truncating: data?[0] as! NSNumber)
                if kDebugLog { print("Unit Type: \(unitId & 0xFF) PCB revision: \(unitId >> 8 & 0xFF)") }
                switch (unitId & 0xFF) {
                case 150:
                    if kDebugLog { print("Classic 150: \(unitId >> 8 & 0xFF)") }
                    deviceModel = "Classic 150"
                case 200:
                    if kDebugLog { print("Classic 200: \(unitId >> 8 & 0xFF)") }
                    deviceModel = "Classic 200"
                case 250:
                    if kDebugLog { print("Classic 250: \(unitId >> 8 & 0xFF)") }
                    deviceModel = "Classic 250"
                case 251:
                    if kDebugLog { print("Classic 250 KS: \(unitId >> 8 & 0xFF)") }
                    deviceModel = "Classic 250 KS"
                default:
                    if kDebugLog { print("Not Recognized") }
                    deviceModel = "Not Recognized"
                }
                
                self.detectedDevice = ClassicDeviceLists(
                    ip:                 "\(lsb3).\(msb3).\(lsb2).\(msb2)",
                    visualUrl:          "\(lsb3).\(msb3).\(lsb2).\(msb2)",
                    port:               Int32(signal.thirdSignal),
                    deviceName:         deviceModel,
                    serialNumber:       "Serial Number",
                    MQTTUser:           "",
                    MQTTPassword:       "",
                    isMQTT:             false,
                    mqttTopic:          ""
                )
                
                if (!self.devicelists.contains(self.detectedDevice)) {
                    self.devicelists.append(self.detectedDevice)
                    if kDebugLog { print("No es igual \(String(describing: self.detectedDevice))") }
                } else {
                    if kDebugLog { print("Es igual o parece igual") }
                }
            } else {
                if kDebugLog { print("Error !nil: \(String(describing: error))") }
            }
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if kDebugLog { print("Did not connect") }
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        if kDebugLog { print("Socket did close") }
    }
    
    //MARK: Esto tiene que estar para poder hacer unwind del segue
    @IBAction func unwindFromPresentedViewController(segue: UIStoryboardSegue) {
        if kDebugLog { print("Unwind Form") }
    }
    
    //MARK: Reference https://medium.com/swift-india/uialertcontroller-in-swift-22f3c5b1dd68
    @IBAction func buttonAddDevice(_ sender: Any) {
        let alert = UIAlertController(title: "Add Classic Charge Controller", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        let addModbus = UIAlertAction(title: "Add Modbus Charge Controller", style: .default, handler: { (_) in
            if kDebugLog { print("Add Modbus Charge Controller") }
            self.alertModbusEntry()
        })
        
        let addMQTT = UIAlertAction(title: "Add MQTT Controller", style: .default, handler: { (_) in
            if kDebugLog { print("Add MQTT Controller") }
            self.alertMQTTEntry()
        })
        
        let addCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            if kDebugLog { print("User click Dismiss button") }
        })
        
        alert.addAction(addModbus)
        alert.addAction(addMQTT)
        alert.addAction(addCancel)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertModbusEntry() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Classic Manual Entry", message: "Enter your Midnite Classic IP and Port", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { classicUrl in
            classicUrl.placeholder = "Enter the Classic URL"
        })
        
        alert.addTextField(configurationHandler: { classicPort in
            classicPort.placeholder = "Enter the Classic Port"
        })
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            if let classicUrl = alert.textFields?.first?.text, let classicPort = alert.textFields?.last?.text {
                if (classicUrl.count != 0 && classicPort.count != 0) {
                    self.addManualEntryModbus(classicUrl: classicUrl, classicPort: classicPort)
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Please enter your Classic URL and Port.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertMQTTEntry() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Classic MQTT Entry", message: "Enter your MQTT Broaker Details", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { classicName in
            classicName.placeholder = "Enter Controller Unit Name"
        })
        
        alert.addTextField(configurationHandler: { classicUrl in
            classicUrl.placeholder = "MQTT Broker Host Name"
        })
        
        alert.addTextField(configurationHandler: { classicPort in
            classicPort.placeholder = "MQTT Broker Port"
        })
        
        alert.addTextField(configurationHandler: { MQTTUsername in
            MQTTUsername.placeholder = "MQTT Username"
        })
        
        alert.addTextField(configurationHandler: { MQTTPassword in
            MQTTPassword.placeholder = "MQTT Password"
        })
        
        alert.addTextField(configurationHandler: { MQTTTopic in
            MQTTTopic.placeholder = "MQTT Topic /example@mail.com/"
        })
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            if let classicName = alert.textFields?.first?.text, let classicUrl = alert.textFields?[1].text,
               let classicPort = alert.textFields?[2].text, let MQTTUsername = alert.textFields?[3].text,
               let MQTTPassword = alert.textFields?.last?.text {
                if (classicName.count != 0 && classicUrl.count != 0 && classicPort.count != 0 && MQTTUsername.count != 0 && MQTTPassword.count != 0) {
                    self.addManualEntryMQTT(classicName: classicName, classicUrl: classicUrl, classicPort: classicPort, MQTTUser: MQTTUsername, MQTTPassword: MQTTPassword)
                } else {
                    let alert = UIAlertController(title: "Alert", message: "At least one parameter is missing. Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func addManualEntryModbus(classicUrl: String, classicPort: String) {
        if (classicUrl.lowercased() == "demo") {
            self.detectedDevice = ClassicDeviceLists(
                ip:                 "demo",
                visualUrl:          "demo",
                port:               502,
                deviceName:         "Demo Mode",
                serialNumber:       "Serial Number",
                MQTTUser:           "",
                MQTTPassword:       "",
                isMQTT:             false,
                mqttTopic:          ""
            )
            
            if (!self.devicelists.contains(self.detectedDevice)) {
                self.devicelists.append(self.detectedDevice)
                if kDebugLog { print("No es igual \(String(describing: self.detectedDevice))") }
            } else {
                if kDebugLog { print("Es igual o parece igual") }
            }
        } else {
            let host = CFHostCreateWithName(nil,classicUrl as CFString).takeRetainedValue()
            CFHostStartInfoResolution(host, .addresses, nil)
            var success: DarwinBoolean = false
            if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
               let theAddress = addresses.firstObject as? NSData {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),&hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    if kDebugLog { print("Detected IP: \(numAddress)") }
                    self.detectedDevice = ClassicDeviceLists(
                        ip:                 numAddress,
                        visualUrl:          classicUrl,
                        port:               Int32(classicPort),
                        deviceName:         "Remote Classic",
                        serialNumber:       "Serial Number",
                        MQTTUser:           "",
                        MQTTPassword:       "",
                        isMQTT:             false,
                        mqttTopic:          ""
                    )
                    
                    if (!self.devicelists.contains(self.detectedDevice)) {
                        self.devicelists.append(self.detectedDevice)
                        if kDebugLog { print("No es igual \(String(describing: self.detectedDevice))") }
                    } else {
                        if kDebugLog { print("Es igual o parece igual") }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "Host does not resolve to and ip address.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func addManualEntryMQTT(classicName: String, classicUrl: String, classicPort: String, MQTTUser: String, MQTTPassword: String) {
        if (classicUrl.lowercased() == "demo") {
            self.detectedDevice = ClassicDeviceLists(
                ip:                 "demo",
                visualUrl:          "demo",
                port:               502,
                deviceName:         "Demo Mode",
                serialNumber:       "Serial Number",
                MQTTUser:           "demo",
                MQTTPassword:       "demo",
                isMQTT:             true,
                mqttTopic:          ""
            )
            
            if (!self.devicelists.contains(self.detectedDevice)) {
                self.devicelists.append(self.detectedDevice)
                if kDebugLog { print("No es igual \(String(describing: self.detectedDevice))") }
            } else {
                if kDebugLog { print("Es igual o parece igual") }
            }
        } else {
            if kDebugLog { print("HOST QUE LLEGA \(classicUrl)") }
            let host = CFHostCreateWithName(nil,classicUrl as CFString).takeRetainedValue()
            CFHostStartInfoResolution(host, .addresses, nil)
            var success: DarwinBoolean = false
            if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
               let theAddress = addresses.firstObject as? NSData {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),&hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    if kDebugLog { print("Detected IP: \(numAddress)") }
                    self.detectedDevice = ClassicDeviceLists(
                        ip:                 numAddress,
                        visualUrl:          classicUrl,
                        port:               Int32(classicPort),
                        deviceName:         classicName,
                        serialNumber:       "Serial Number",
                        MQTTUser:           MQTTUser,
                        MQTTPassword:       MQTTPassword,
                        isMQTT:             true,
                        mqttTopic:          ""
                    )
                    
                    if (!self.devicelists.contains(self.detectedDevice)) {
                        self.devicelists.append(self.detectedDevice)
                        if kDebugLog { print("No es igual \(String(describing: self.detectedDevice))") }
                    } else {
                        if kDebugLog { print("Es igual o parece igual") }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "Host does not resolve to and ip address.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    private func devicesDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchedDevice.count
        } else {
            return devicelists.isEmpty ? 0 : devicelists.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if devicelists.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFound", for: indexPath) as! DetectDeviceViewCell
            cell.backgroundColor = .clear
            cell.selectionStyle  = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DetectDeviceViewCell
            // alternate background color
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.2)
            
            if(searchedDevice.count == 0){
                let deviceList = devicelists[indexPath.row]
                cell.configureDeviceCell(deviceList: deviceList)
            } else {
                let deviceList = searchedDevice[indexPath.row]
                cell.configureDeviceCell(deviceList: deviceList)
            }
            return cell
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        searchedDevice = devicelists.filter {
            return ($0.ip!.range(of: searchText, options: [.caseInsensitive]) != nil) || ($0.deviceName!.range(of: searchText, options: [.caseInsensitive]) != nil)
        }
        self.tableView.reloadData()
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension DetectDeviceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        classicUrl  = devicelists[indexPath.row].ip
        classicPort = devicelists[indexPath.row].port
        if kDebugLog { print("SELECTED: \(String(describing: classicUrl)) - \(String(describing: classicPort))") }
        performSegue(withIdentifier: "SelectedSegue", sender: self)
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectedSegue" {
            let viewController          = segue.destination as! ViewController
            viewController.classicURL   = classicUrl! as NSString
            viewController.classicPort  = classicPort!
        }
    }
}

extension DetectDeviceViewController {
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }
        self.reachability = reachability
        if kDebugLog { print("--- Set up with host name: \(String(describing: hostName))") }
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.setupConnection()
            }
            reachability?.whenUnreachable = { reachability in
                //MARK: se le puso verificacion de nil antes para asegurarse que esté activo el objeto
                if (!self.socket.isClosed()) {
                    self.socket.close()
                }
            }
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection != .unavailable {
            if (!self.socket.isClosed()) {
                self.socket.close()
            }
        } else {
            self.setupConnection()
        }
    }
    
    func startNotifier() {
        if kDebugLog { print("--- start notifier") }
        do {
            try reachability?.startNotifier()
        } catch {
            if kDebugLog { print("Unable to start notifier") }
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            if kDebugLog { print("Reachable via WiFi") }
            setupConnection()
        case .cellular:
            if kDebugLog { print("Reachable via Cellular") }
            if (!self.socket.isClosed()) {
                self.socket.close()
            }
        case .unavailable:
            if kDebugLog { print("Network not reachable") }
            if (!self.socket.isClosed()) {
                self.socket.close()
            }
        case .none:
            if kDebugLog {print("Unknown") }
            if (!self.socket.isClosed()) {
                self.socket.close()
            }
        }
    }
}
