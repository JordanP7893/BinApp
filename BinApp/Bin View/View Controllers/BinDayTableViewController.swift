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
        
        Task {
            await performSetupOnInitialLoad()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForChangesInData), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForChangesInData), name: NSNotification.Name(rawValue: "NotificationReceived"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearNotification), name: NSNotification.Name(rawValue: "NotificationsCleared"), object: nil)
        
        binRefreshControl.addTarget(self, action: #selector(updateBinLocation), for: .valueChanged)
        tableView.refreshControl = binRefreshControl
    }
    
    func notificationTapped(withId id: String) {
        Task {
            await performSetupOnInitialLoad()
            
            guard let chosenBinIndex = binDays.firstIndex(where: {$0.id == id}) else { return }
            
            binDays[chosenBinIndex].isPending = true
            binDaysDataController.saveBinData(binDays)
            
            updateUI()
            goToDetailsPage(forIndex: chosenBinIndex)
        }
    }
    
    @objc func clearNotification(notification: Notification) {
        guard let id = notification.userInfo?["id"] as? String else { return }
        
        if let chosenBinIndex = binDays.firstIndex(where: {$0.id == id}) {
            binDays[chosenBinIndex].isPending = false
            binDaysDataController.saveBinData(binDays)
        }
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    @objc func checkForChangesInData() {
        //Check if list is out of date and refresh UI so only show bins from today onwards - not yesterday etc.
        if let lastTableReloadDate = lastTableReloadDate, Date().stripTime() > lastTableReloadDate.stripTime() {
            guard let addressID = addressID else { return }
            Task {
//                binDays = try await binDaysProvider.fetchDataFromTheNetwork(usingId: addressID)
                refreshBinListWithNotifications()
            }
        } else {
            refreshBinListWithNotifications()
        }
    }
    
    func refreshBinListWithNotifications() {
        Task {
            binDays = await notificationDataController.getTriggeredNotifications(binDays: binDays)
            binDaysDataController.saveBinData(binDays)
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
            }
        }
        
        lastTableReloadDate = Date()
        tableView.reloadData()
    }
    
    @objc func updateBinLocation(){
        guard let addressID = addressID else { return }
        
        Task {
            do {
//                binDays = try await binDaysProvider.fetchDataFromTheNetwork(usingId: addressID)
                binDaysProvider.binDays = binDays
                await updateNotifications(binDays: binDays)
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
    
    func performSetupOnInitialLoad() async {
        let address = binAddressDataController.fetchAddressData()
        
        if let address = address{
            navigationItem.title = address.title
            addressID = address.id
            
            do {
//                binDays = try await binDaysProvider.fetchBinDays(addressID: address.id)
                updateUI()
            } catch {
                if let error = error as? AlertError {
                    errorAlertController.showErrorAlertView(in: self, with: error.title, and: error.body)
                }
            }
            
        } else {
            performSegue(withIdentifier: "LocationSegue", sender: nil)
        }
    }
    
    func updateNotifications(binDays: [BinDays]) async {
        
//        let isAuthorized = await binDaysProvider.updateNotifications(binDays: binDays)
//        
//        if isAuthorized {
//            DispatchQueue.main.async {
//                UIApplication.shared.applicationIconBadgeNumber = 0
//            }
//        }
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
            binDaysDataController.saveBinData(binDays)
            notificationDataController.removeDeliveredNotification(withIdentifier: bin.id)
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            updateUI()
        }
        
        func remindButtonPresses(snoozeFor time: TimeInterval) {
            binDays[index].isPending = false
            notificationDataController.snoozeBin(bin, for: time)
            updateUI()
        }
        
        func tonightButtonPressed() {
            binDays[index].isPending = false
            notificationDataController.tonightBin(bin)
            updateUI()
        }
        
        let binDetailViewController = UIHostingController(rootView: BinDetailView(bin: .constant(bin), donePressed: doneButtonPressed, remindPressed: remindButtonPresses, tonightPressed: tonightButtonPressed))
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
