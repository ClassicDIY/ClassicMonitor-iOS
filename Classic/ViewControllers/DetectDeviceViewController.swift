//
//  TestViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class DetectDeviceViewController: UIViewController, GCDAsyncUdpSocketDelegate, UISearchBarDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView:           UITableView!
    @IBOutlet weak var searchController:    UISearchBar!
    
    var searchActive: Bool  = false
    let IP                  = "255.255.255.255"
    let PORT: UInt16        = 4626
    var socket:             GCDAsyncUdpSocket!
    var detectedDevice:     ClassicDeviceLists!
    //var addedToList:        Bool = false
    
    var ipLabel: String     = ""
    var portLabel: String   = ""
    
    var selectedDevice:     Set<ClassicDeviceLists>!
    
    // MARK: - Lists
    var devicelists = Set<ClassicDeviceLists>() {
        didSet {
            guard devicelists != oldValue else { return }
            devicesDidUpdate()
        }
    }
    var searchedDevice = Set<ClassicDeviceLists>()

    
    var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (!socket.isClosed()) {
            socket.close()
        }
    }
    
    
    deinit {
        // Be a good citizen.
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
        print("updSocket")
        let lsb3 = signal.firstSignal & 0xFF
        let msb3 = (signal.firstSignal >> 8) & 0xFF
        let lsb2 = signal.secondSignal & 0xFF
        let msb2 = (signal.secondSignal >> 8) & 0xFF
        print("IP Address: \(lsb3).\(msb3).\(lsb2).\(msb2) with port \(signal.thirdSignal)")
        
        detectedDevice = ClassicDeviceLists(
            ip:                 "\(lsb3).\(msb3).\(lsb2).\(msb2)",
            port:               Int32(signal.thirdSignal),
            deviceName:         "CLASSIC",
            serialNumber:       "Serial Number"
        )
        devicelists.insert(detectedDevice)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
    }
    
    func loadDummyData() {
        detectedDevice = ClassicDeviceLists(
            ip:                 "192.168.1.50",
            port:               502,
            deviceName:         "CLASSIC",
            serialNumber:       "Serial Number"
        )
        devicelists.insert(detectedDevice)
        
        detectedDevice = ClassicDeviceLists(
            ip:                 "192.168.1.50",
            port:               502,
            deviceName:         "CLASSIC",
            serialNumber:       "Serial Number"
        )
        devicelists.insert(detectedDevice)
    }
    
    //MARK: Esto tiene que estar para poder hacer unwind del segue
    @IBAction func unwindFromPresentedViewController(segue: UIStoryboardSegue) {
        if kDebugLog { print("Unwind Form") }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFound", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle  = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DetectDeviceViewCell
            // alternate background color
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.2)
            
            if(searchedDevice.count == 0){
                let deviceList = devicelists.index(devicelists.startIndex, offsetBy: indexPath.row)
                cell.configureDeviceCell(deviceList: devicelists[deviceList])
            } else {
                let deviceList = searchedDevice.index(devicelists.startIndex, offsetBy: indexPath.row)//searchedDevice[indexPath.row]
                cell.configureDeviceCell(deviceList: devicelists[deviceList])
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
            return ($0.ip!.range(of: searchText, options: [.caseInsensitive]) != nil) || ($0.deviceName!.range(of: searchText, options: [.caseInsensitive]) != nil) }
        self.tableView.reloadData()
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension DetectDeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as! DetectDeviceViewCell
        ipLabel                         = cell.ipLabel.text!
        portLabel                       = cell.portLabel.text!
        let deviceNameLabel: String     = cell.deviceNameLabel.text!
        let serialNumberLabel: String   = cell.serialNumberLabel.text!
        print("Selected \(ipLabel) with port \(portLabel) device name \(deviceNameLabel) with serial number \(serialNumberLabel)")
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            switch identifier {
                case "SelectedSegue":
                    let indexPath       = self.tableView.indexPathForSelectedRow
                    let index           = devicelists.index(devicelists.startIndex, offsetBy: indexPath!.row)
                    let viewController  = segue.destination as! ViewController
                    viewController.classicURL   = (devicelists[index].ip!) as NSString
                    viewController.classicPort  = (devicelists[index].port)! as Int32
                default: break
            }
        }
    }
}
