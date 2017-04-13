//
//  ViewController.swift
//  BLEX
//
//  Created by Yanqi Liu on 4/13/17.
//  Copyright © 2017 Yanqi Liu. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var peers: [String] = ["device1"]
    var ble: Robotx_BLE
    init(){
        self.ble = Robotx_BLE(timerPauseInterval: 10, timerScanInterval: 10)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? (coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemetned")
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var Switch: UISwitch!
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor  = UIColor.white
        
        Switch = UISwitch()
        Switch.translatesAutoresizingMaskIntoConstraints = false
        Switch.addTarget(self, action: #selector(switchToggled(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(Switch)
        
        NSLayoutConstraint.activate([
            Switch.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            Switch.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant:100)
            ])
        
        let tableView = UITableView(frame: CGRect(x: screenWidth*0.1, y: 150, width: screenWidth*0.8, height: screenHeight*0.6))

        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Peer Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView = tableView
        self.view.addSubview(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Peer Cell", for: indexPath)
        
        cell.textLabel!.text = self.peers[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("device name: \(self.peers[indexPath.row])")
        
        let destination = FunctionViewController()
        destination.deviceName = self.peers[indexPath.row]
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func switchToggled(_ Switch: UISwitch){
        if(Switch.isOn){
            //code run on background queue but need to get to the main queue for UI display
            //back ground queue(0)
            self.ble.start()
            var list: [String]
            list = self.ble.getDeviceList()
            DispatchQueue.main.async(execute: {
                //run on main queue(2)
                //self.peers.append("device")
                //self.tableView.insertRows(at: [IndexPath(row: self.peers.count-1, section:0)], with: .fade)
                
                self.tableView.insertRows(at: [IndexPath(row: list.count-1, section:0)], with: .fade)
                
            
            })
            
        }
        else{
            peers.removeAll()
            self.tableView.reloadData()
        }
    }

}

