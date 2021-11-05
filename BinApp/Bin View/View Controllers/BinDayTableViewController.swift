//
//  BinDayTableViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 04/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit

class BinDayTableViewController: UITableViewController {
    
    let binDaysDataController = BinDaysDataController()
    let binAddressDataController = BinAddressDataController()
    let notificationDataController = NotificationDataController()
    let errorAlertController = ErrorAlertController()
    let binRefreshControl = UIRefreshControl()
    
    var addressID: Int?
    var binDays = [BinDays]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let address = binAddressDataController.fetchAddressData()
        
        if let address = address{
            navigationItem.title = address.title
            addressID = address.id
        } else {
            performSegue(withIdentifier: "LocationSegue", sender: nil)
        }
        
        if let binDays = binDaysDataController.fetchBinData() {
            self.binDays = binDays
        } else {
            updateBinLocation()
        }
        
        binRefreshControl.addTarget(self, action: #selector(updateBinLocation), for: .valueChanged)
        tableView.refreshControl = binRefreshControl
        updateUI()
    }

    @objc func updateUI() {
        
        binDays = binDays.sorted(by: {
            return $0.date.compare($1.date) == .orderedAscending
        })
        
        binDays = binDays.filter {
            return $0.date >= Date().addingTimeInterval(-86400)
        }
        
        tableView.reloadData()
    }
    
    @objc func updateBinLocation(){
        guard let addressID = addressID else { return }
        
        binDaysDataController.fetchBinDates(id: addressID) { binDays in
            guard let binDays = binDays else {
                self.errorAlertController.showErrorAlertView(in: self, with: "Network Connection Error", and: "Could not retrieve bin data. Please check your connection and try again")
                self.binRefreshControl.endRefreshing()
                return
            }
            self.binDays = binDays
            
            let notificationState = self.notificationDataController.fetchNotificationState()
            
            if let notificationState = notificationState {
                self.notificationDataController.setupBinNotification(for: binDays, at: notificationState) { result in
                    if !result {
                        DispatchQueue.main.async {
                            self.errorAlertController.showErrorAlertView(in: self, with: "Notifications Not Enabled", and: "Notifications are not enabled. Please check your settings.")
                            self.binRefreshControl.endRefreshing()
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updateUI()
                self.binRefreshControl.endRefreshing()
            }
        }
    }
    
    func manuallyShowRefreshControl() {
        let top = self.tableView.adjustedContentInset.top
        let y = self.binRefreshControl.frame.maxY + top
        self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
        self.binRefreshControl.beginRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return binDays.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let binDay = binDays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BinDayCell", for: indexPath) as! BinDayTableViewCell
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE, d MMMM"
        
        cell.dateLabel.text = "\(dateFormatterPrint.string(from: binDay.date))"
        
        let binType = binDay.type
        
        if let binImage = UIImage(named: String(binType.description).lowercased()) {
            cell.binIcon.image = binImage
        } else {
            cell.binIcon.tintColor = binType.color
        }
        cell.binTypeLabel.text = binType.description
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NotificationSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let notificationController = destinationNavigationController.topViewController as! NotificationsTableViewController
            notificationController.binDays = self.binDays
        } else if segue.identifier == "LocationSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let notificationController = destinationNavigationController.topViewController as! LocationModalViewController
            if addressID != nil {
                notificationController.firstTimeOpeningApp = false
            }
        }
    }
    
    @IBAction func rewindToBinTable(segue: UIStoryboardSegue) {
        if segue.identifier == "saveUnwind" {
            
            let sourceViewController = segue.source as! LocationModalViewController
            guard let address = sourceViewController.selectedAddress else {return}
            
            binAddressDataController.saveAddressData(address)
            navigationItem.title = address.title
            addressID = address.id
            
            manuallyShowRefreshControl()
            updateBinLocation()
        }
    }

}
