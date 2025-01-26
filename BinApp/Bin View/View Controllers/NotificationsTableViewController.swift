//
//  NotificationsTableViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 06/04/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

    @IBOutlet weak var eveningSwitch: UISwitch!
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var eveningTimeLabel: UILabel!
    @IBOutlet weak var morningTimeLabel: UILabel!
    @IBOutlet weak var eveningDatePicker: UIDatePicker!
    @IBOutlet weak var morningDatePicker: UIDatePicker!
    @IBOutlet weak var blackTypeCell: UITableViewCell!
    @IBOutlet weak var greenTypeCell: UITableViewCell!
    @IBOutlet weak var brownTypeCell: UITableViewCell!
    @IBOutlet weak var foodTypeCell: UITableViewCell!
    
    let eveningPickerIndexPath = IndexPath(row: 1, section: 0)
    let morningPickerIndexPath = IndexPath(row: 1, section: 1)
    let foodRowIndexPath = IndexPath(row: 2, section: 2)
    
    var eveningPickerHidden = true
    var morningPickerHidden = true
    
    var notificationState: BinNotifications?
    var binDays = [BinDays]()
    var notificationTypes = [0: true, 1: true, 2: true, 3: true]
    
//    let notificationController = NotificationDataController()
    let errorAlertController = ErrorAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        notificationState = notificationController.fetchNotificationState()
        
        if let notificationState = notificationState {
            blackTypeCell.accessoryType = notificationTypes[0]! ? .checkmark : .none
            greenTypeCell.accessoryType = notificationTypes[1]! ? .checkmark : .none
            foodTypeCell.accessoryType = notificationTypes[2]! ? .checkmark : .none
            brownTypeCell.accessoryType = notificationTypes[3]! ? .checkmark : .none
        }
        updateDateLabel(eveningTimeLabel, with: eveningDatePicker.date)
        updateDateLabel(morningTimeLabel, with: morningDatePicker.date)
    }
    
    func updateDateLabel(_ label: UILabel, with date: Date) {
//        label.text = BinNotifications.dateFormatter.string(from: date)
    }
    
    func updateNotifications() {
        if let notificationState = notificationState {
//            Task {
//                let isAuthorized = await notificationController.setupBinNotification(for: binDays, at: notificationState)
//                if !isAuthorized {
//                    DispatchQueue.main.async {
//                        self.errorAlertController.showErrorAlertView(in: self, with: "Notifications Not Enabled", and: "Notifications are not enabled. Please check your settings.")
//                    }
//                }
//            }
//            notificationController.saveNotificationState(notificationState)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(43.5)
        let largeCellHeight = CGFloat(200)
        
        switch indexPath {
        case eveningPickerIndexPath:
            return eveningPickerHidden || !eveningSwitch.isOn ? normalCellHeight : largeCellHeight
        case morningPickerIndexPath:
            return morningPickerHidden || !morningSwitch.isOn ? normalCellHeight : largeCellHeight
        case foodRowIndexPath:
            for binDay in binDays {
                if binDay.type == .food {
                    return normalCellHeight
                }
            }
            return 0
        default:
            return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        eveningTimeLabel.textColor = eveningPickerHidden || !eveningSwitch.isOn ? nil : tableView.tintColor
        morningTimeLabel.textColor = morningPickerHidden || !morningSwitch.isOn ? nil : tableView.tintColor
        
        switch indexPath {
        case [0,1]:
            cell.isUserInteractionEnabled = eveningSwitch.isOn
            cell.contentView.alpha = eveningSwitch.isOn ? 1 : 0.5
        case [1,1]:
            cell.isUserInteractionEnabled = morningSwitch.isOn
            cell.contentView.alpha = morningSwitch.isOn ? 1 : 0.5
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath {
        case [0,0], [1,0]:
            return false
        default:
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case eveningPickerIndexPath:
            eveningPickerHidden = !eveningPickerHidden
            eveningDatePicker.isEnabled = !eveningPickerHidden
            eveningTimeLabel.textColor = eveningPickerHidden || !eveningSwitch.isOn ? nil : tableView.tintColor
        case morningPickerIndexPath:
            morningPickerHidden = !morningPickerHidden
            morningDatePicker.isEnabled = !morningPickerHidden
            morningTimeLabel.textColor = morningPickerHidden || !morningSwitch.isOn ? nil : tableView.tintColor
        default:
            if let cell = tableView.cellForRow(at: indexPath) {
                notificationTypes.updateValue(cell.accessoryType != .checkmark, forKey: indexPath.row)
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
                updateNotifications()
            }
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func eveningSwitchChanged(_ sender: UISwitch) {
        if !sender.isOn {
            eveningTimeLabel.textColor = nil
            eveningPickerHidden = true
        }
        updateNotifications()
        self.tableView.reloadData()
    }
    
    @IBAction func morningSwitchChanged(_ sender: UISwitch) {
        if !sender.isOn {
            morningTimeLabel.textColor = nil
            morningPickerHidden = true
        }
        updateNotifications()
        self.tableView.reloadData()
    }
    
    @IBAction func eveningDatePickerChanged(_ sender: UIDatePicker) {
        updateDateLabel(eveningTimeLabel, with: eveningDatePicker.date)
        updateNotifications()
    }
    
    @IBAction func morningDatePickerChanged(_ sender: UIDatePicker) {
        updateDateLabel(morningTimeLabel, with: morningDatePicker.date)
        updateNotifications()
    }
}
