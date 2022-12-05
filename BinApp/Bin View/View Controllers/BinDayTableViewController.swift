//
//  BinDayTableViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 04/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit
import SwiftUI

class BinDayTableViewController: UITableViewController {
    
    let binDaysDataController = BinDaysDataController()
    let binAddressDataController = BinAddressDataController()
    let notificationDataController = NotificationDataController()
    let errorAlertController = ErrorAlertController()
    let binDaysProvider = BinDaysProvider()
    let binRefreshControl = UIRefreshControl()
    
    var addressID: Int?
    var binDays = [BinDays]()
    var lastTableReloadDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSetupOnInitialLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBinData), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBinData), name: NSNotification.Name(rawValue: "NotificationReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationTapped), name: NSNotification.Name(rawValue: "NotificationTapped"), object: nil)
        
        binRefreshControl.addTarget(self, action: #selector(updateBinLocation), for: .valueChanged)
        tableView.refreshControl = binRefreshControl
    }
    
    @objc func notificationTapped() {
        binDays = notificationDataController.getTappedNotification(binDays: binDays)
        
        if let tappedNotificationId = self.notificationDataController.tappedNotificationId {
            guard let chosenBinIndex = binDays.firstIndex(where: {$0.id == tappedNotificationId}) else { return }
            self.notificationDataController.tappedNotificationId = nil
            
            DispatchQueue.main.async {
                self.updateUI()
                self.goToDetailsPage(forIndex: chosenBinIndex)
            }
        }
    }
    
    @objc func reloadBinData() {
        //Run bin data through notification controller to see if any have been triggered
        notificationDataController.getTriggeredNotifications(binDays: binDays) { binDays in
            if let binDays = binDays {
                self.binDays = binDays
                DispatchQueue.main.async {
                    self.updateUI()
                }
            }
        }
        
        //Check if list is out of date and refresh UI so only show bins from today onwards - not yesterday etc.
        if let lastTableReloadDate = lastTableReloadDate {
            let currentDate = Date()
            if currentDate.stripTime() > lastTableReloadDate.stripTime() {
                updateUI()
            }
        } else {
            updateUI()
        }
    }

    @objc func updateUI() {
        
        binDays = binDays.sorted(by: {
            return $0.date.compare($1.date) == .orderedAscending
        })
        
        binDays = binDays.filter {
            return $0.date >= Date().addingTimeInterval(-86400)
        }
        
        if let tabItems = tabBarController?.tabBar.items {
            let tabItem = tabItems[0]
            let pendingBins = binDays.filter({$0.isPending})
            
            if pendingBins.count > 0 {
                tabItem.badgeValue = "1"
            } else {
                tabItem.badgeValue = nil
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        
        lastTableReloadDate = Date()
        tableView.reloadData()
    }
    
    @objc func updateBinLocation(){
        guard let addressID = addressID else { return }
        
        Task {
            do {
                binDays = try await binDaysProvider.fetchDataFromTheNetwork(usingId: addressID)
                binDaysProvider.binDays = binDays
                updateNotifications()
                updateUI()
                binRefreshControl.endRefreshing()
            } catch {
                binRefreshControl.endRefreshing()
                if let error = error as? AlertError {
                    self.errorAlertController.showErrorAlertView(in: self, with: error.title, and: error.body)
                }
            }
        }
        
    }
    
    func performSetupOnInitialLoad() {
        let address = binAddressDataController.fetchAddressData()
        
        if let address = address{
            navigationItem.title = address.title
            addressID = address.id
            
            Task {
                do {
                    binDays = try await binDaysProvider.fetchBinDays(addressID: address.id)
                    updateUI()
                } catch {
                    if let error = error as? AlertError {
                        errorAlertController.showErrorAlertView(in: self, with: error.title, and: error.body)
                    }
                }
            }
            
        } else {
            performSegue(withIdentifier: "LocationSegue", sender: nil)
        }
    }
    
    func updateNotifications() {
        
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
    }
    
    func manuallyShowRefreshControl() {
        let top = self.tableView.adjustedContentInset.top
        let y = self.binRefreshControl.frame.maxY + top
        self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
        self.binRefreshControl.beginRefreshing()
    }
    
    func goToDetailsPage(forIndex index: Array<BinDays>.Index) {
        let bin = binDays[index]
        
        func doneButtonPressed() {
            binDays[index].isPending = false
            updateUI()
        }
        
        let binDetailViewController = UIHostingController(rootView: BinDetailView(bin: bin, donePressed: doneButtonPressed))
        binDetailViewController.title = bin.type.description
        self.navigationController?.pushViewController(binDetailViewController, animated: true)
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
        
        cell.dateLabel.text = binDay.date.formatDateTodayTomorrowOrActual()
            
        let binType = binDay.type
        
        if let binImage = UIImage(named: String(binType.description).lowercased()) {
            cell.binIcon.image = binImage
        } else {
            cell.binIcon.tintColor = binType.color
        }
        
        if binDay.isPending {
            cell.badgeLabel.text = "1"
            cell.badgeLabel.backgroundColor = .systemRed
            cell.badgeLabel.layer.cornerRadius = cell.badgeLabel.frame.width / 2
            cell.badgeLabel.clipsToBounds = true
        } else {
            cell.badgeLabel.text = ""
            cell.badgeLabel.backgroundColor = .none
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToDetailsPage(forIndex: indexPath.row)
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

extension Date {

    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }

}
