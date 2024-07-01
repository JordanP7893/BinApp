//
//  LocationModalViewController.swift
//  BinApp
//
//  Created by Jordan Porter on 27/03/2020.
//  Copyright © 2020 Jordan Porter. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationModalViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressPicker: UIPickerView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var addressPickerStackView: UIStackView!
    @IBOutlet weak var addressPickerStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var AddressLabelSuperview: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    let geocoder = CLGeocoder()
    let userLocationController = UserLocationController()
    let binAddressDataController = BinAddressDataController()
    let errorAlertController = ErrorAlertController()
    
    var addresses: [Int: String] = [:]
    var addressesSorted = [Dictionary<Int, String>.Element]()
    var firstTimeOpeningApp = true
    var textFieldActive = false
    var selectedAddress: AddressData? {
        didSet {
            updateSaveButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressPicker.delegate = self
        
        if firstTimeOpeningApp {
            self.isModalInPresentation = true
            /*
            cancelButton.isEnabled = false
            cancelButton.tintColor = UIColor.clear
            */
        }
        
        setupView()
    }
    
    func setupView() {
        addressPickerStackViewBottomConstraint.constant = -addressPickerStackView.frame.height
        addressLabel.text = ""
        updateSaveButton()
    }
    
    func calculateCurrentAddress() {
        guard let currentLocation = userLocationController.getUsersCurrentLocation() else {
            errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
            hidePickerView()
            loadingIndicator.stopAnimating()
            return
        }
        
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            
            if let _ = error {
                self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
                self.hidePickerView()
                self.loadingIndicator.stopAnimating()
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
                self.hidePickerView()
                self.loadingIndicator.stopAnimating()
                return
            }
            
            let postcode = placemark.postalCode ?? ""
            
            DispatchQueue.main.async {
                self.searchField.text = postcode
                self.locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
                self.searchForAddress()
            }
        }
    }
    
    func searchForAddress() {
        addressLabel.text = ""
        textFieldActive = false
        
        guard let postcode = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            errorAlertController.showErrorAlertView(in: self, with: "Postcode error", and: "Please try entering your postcode again")
            hidePickerView()
            loadingIndicator.stopAnimating()
            return
        }
        
        let postcodeToSearch = postcode.replacingOccurrences(of: " ", with: "")
        
        guard postcode.count > 4 else {
            errorAlertController.showErrorAlertView(in: self, with: "Postcode too short", and: "Please enter your full postcode")
            hidePickerView()
            loadingIndicator.stopAnimating()
            return
        }
        
//        binAddressDataController.fetchAddress(postcode: postcodeToSearch) { addresses in
//            guard let addresses = addresses else {
//                DispatchQueue.main.async {
//                    self.errorAlertController.showErrorAlertView(in: self, with: "Network Connection Error", and: "Could not retrieve address data. Please check your connection and try again")
//                }
//                self.loadingIndicator.stopAnimating()
//                return
//            }
//            self.addresses.removeAll()
//            
//            if addresses.count == 0 {
//                DispatchQueue.main.async {
//                    self.errorAlertController.showErrorAlertView(in: self, with: "Postcode not found", and: "Please check that your postcode is valid for Leeds")
//                    self.hidePickerView()
//                    self.loadingIndicator.stopAnimating()
//                }
//                return
//            }
//            
//            for address in addresses {
//                let streetNameAndNumber = [address.address1 + ",", address.address2, address.street]
//                self.addresses[address.premisesId] = streetNameAndNumber.filter({$0 != "" && $0 != ","}).joined(separator: " ")
//            }
//            
//            self.addressesSorted = self.addresses.sorted { $0.1.localizedStandardCompare($1.1) == .orderedAscending }
//            
//            DispatchQueue.main.async {
//                self.addressPicker.reloadAllComponents()
//                self.addressPicker.selectRow(0, inComponent: 0, animated: false)
//                self.selectedAddress = AddressData(id: self.addressesSorted[0].key, title: self.addressesSorted[0].value)
//                self.addressLabel.text = self.selectedAddress?.title
//                self.loadingIndicator.stopAnimating()
//            
//                self.addressPickerStackViewBottomConstraint.constant = 0
//                UIView.animate(withDuration: 0.2) {
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
    }
    
    func updateSaveButton() {
        let address = selectedAddress?.title ?? ""
        saveButton.isEnabled = !address.isEmpty
    }
    
    func hidePickerView() {
        addressPickerStackViewBottomConstraint.constant = -addressPickerStackView.frame.height
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func addressLabelTapped() {
        if textFieldActive {
            loadingIndicator.stopAnimating()
            searchField.resignFirstResponder()
            searchForAddress()
        }
    }
    
    @IBAction func locationButtonPresses(_ sender: UIButton) {
        loadingIndicator.startAnimating()
        searchField.resignFirstResponder()
        guard let isLocationAuthorized = userLocationController.checkLocationAuthorization(forViewController: self) else { return }
        if isLocationAuthorized {
            calculateCurrentAddress()
        } else {
            loadingIndicator.stopAnimating()
            errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        hidePickerView()
    }
    
    @IBAction func returnKeyPressed(_ sender: UITextField) {
        loadingIndicator.startAnimating()
        searchField.resignFirstResponder()
        searchForAddress()
    }
    
    @IBAction func searchFieldEditted(_ sender: UITextField) {
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
    }
    
    @IBAction func searchFieldTapped(_ sender: Any) {
        textFieldActive = true
    }
    
    @IBAction func didTapLabelSuperview(_ sender: UITapGestureRecognizer) {
        addressLabelTapped()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
    }
    
}

extension LocationModalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addressesSorted.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return addressesSorted[row].value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAddress = AddressData(id: addressesSorted[row].key, title: addressesSorted[row].value)
        addressLabel.text = selectedAddress?.title
    }
    
}

extension LocationModalViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let isLocationAuthorized = userLocationController.checkLocationAuthorization(forViewController: self) else { return }
        if isLocationAuthorized {
            calculateCurrentAddress()
        } else {
            errorAlertController.showErrorAlertView(in: self, with: "Location Not Found", and: "Could not retrive your current location. Please check your settings.")
        }
    }
}
