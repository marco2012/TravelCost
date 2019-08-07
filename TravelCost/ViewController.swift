//
//  ViewController.swift
//  TravelCost
//
//  Created by Marco on 16/06/2019.
//  Copyright © 2019 Marco. All rights reserved.
//

import UIKit
import Eureka
import GooglePlacesRow
import MapKit

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        buildForm()
        
    }
    
    private func buildForm(){
        form
            
            +++ Section()
            
//            <<< GooglePlacesTableRow() { row in
//                row.placeFilter?.type = .address    //suggest addresses
//                row.placeholder = "Enter start location"
//                row.tag = "start_location" // Upon parsing a form you get a nice key if you use a tag
//                row.add(ruleSet: RuleSet<GooglePlace>()) // We can use GooglePlace() as a rule
//                row.validationOptions = .validatesOnChangeAfterBlurred
//                row.cell.textLabel?.textColor = UIColor.black
//                row.cell.textLabel?.numberOfLines = 0
//                }
//                .cellUpdate { cell, row in // Optional
//                }
//
//            <<< GooglePlacesTableRow() { row in
//                row.placeFilter?.type = .address    //suggest addresses
//                row.placeholder = "Enter end location"
//                row.tag = "end_location" // Upon parsing a form you get a nice key if you use a tag
//                row.add(ruleSet: RuleSet<GooglePlace>()) // We can use GooglePlace() as a rule
//                row.validationOptions = .validatesOnChangeAfterBlurred
//                row.cell.textLabel?.textColor = UIColor.black
//                row.cell.textLabel?.numberOfLines = 0
//                }
//                .cellUpdate { cell, row in // Optional
//            }
            
            <<< DecimalRow() {
                $0.title = "Distance"
                $0.tag = "distance"
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "Km"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
                    }
                }
            
            <<< SwitchRow(){
                $0.title = "Roundtrip"
                $0.tag = "roundtrip"
                $0.value = true
            }
        
            +++ Section()
            
            <<< DecimalRow() {
                $0.title = "L/100KM"
                $0.value = 4.8
                $0.tag = "l100"
                }.onCellHighlightChanged { cell, row in
                    if !row.isHighlighted {
                        let kml = 100 / row.value!
                        let kml_row = self.form.rowBy(tag: "kml") as! DecimalRow
                        kml_row.value = self.roundToPlaces(value: kml , places: 2)
                        kml_row.reload()
                    }
                }
        
            <<< DecimalRow() {
                $0.title = "KM/L"
                $0.value = 20.83
                $0.tag = "kml"
                }.onCellHighlightChanged { cell, row in
                    if !row.isHighlighted {
                        let l100 = 100 / row.value!
                        let l100_row = self.form.rowBy(tag: "l100") as! DecimalRow
                        l100_row.value = self.roundToPlaces(value: l100 , places: 2)
                        l100_row.reload()
                    }
            }
        
            <<< DecimalRow() {
                $0.title = "Fuel price"
                $0.value = 1.45
                $0.tag = "fuel_price"
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "€"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
                    }
            }
        
            +++ Section(footer: "Average cost for this trip")
            
            <<< DecimalRow() {
                $0.title = "Trip cost"
                $0.tag = "trip_cost"
                $0.disabled = true
                let formatter = DecimalFormatter()
                formatter.locale = .current
                formatter.positiveSuffix = "€"
                $0.formatter = formatter
                }.onCellHighlightChanged { cell, row in
                    if row.isHighlighted {
                        let position = cell.textField.position(from: cell.textField.endOfDocument, offset: 0)!
                        cell.textField.selectedTextRange = cell.textField.textRange(from: position, to: position)
                    }
                }
            
            
            +++ Section() {section in
                section.tag = "button_section"
            }
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Calculate"
                }
                .onCellSelection { [weak self] (cell, row) in
                    
                    DispatchQueue.main.async {
                    
//                        let start_locationForm: GooglePlacesTableRow? = self?.form.rowBy(tag: "start_location")
//                        let end_locationForm: GooglePlacesTableRow? = self?.form.rowBy(tag: "end_location")
                        let distanceForm: DecimalRow? = self?.form.rowBy(tag: "distance")
                        let fuel_priceForm : DecimalRow? = self?.form.rowBy(tag: "fuel_price")
//                        let l100Form : DecimalRow? = self?.form.rowBy(tag: "l100")
                        let kmlForm : DecimalRow? = self?.form.rowBy(tag: "kml")
                        let roundtripForm : SwitchRow? = self?.form.rowBy(tag: "roundtrip")

                        if distanceForm?.value==nil || fuel_priceForm?.value==nil || kmlForm?.value==nil {
                            self!.showAlert(title: "Error", message: "Fill the missing fields")
                        } else {
                        
//                            let start_address = start_locationForm?.value.debugDescription.components(separatedBy: "\"")[1]
//                            let end_address = end_locationForm?.value.debugDescription.components(separatedBy: "\"")[1]
                            
                            var distance = Double(distanceForm!.value!)
                            let fuel_price = Double(fuel_priceForm!.value!)
                            //let l100 = Double(l100Form!.value!)
                            let kml = Double(kmlForm!.value!)
                            let roundtrip = roundtripForm!.value!
                           
                            if (roundtrip) {
                                distance = distance * 2
                            }
                            
                            let price = (distance * fuel_price) / kml

                            let trip_cost_row = self!.form.rowBy(tag: "trip_cost") as! DecimalRow
                            trip_cost_row.value = self!.roundToPlaces(value: price, places: 2)
                            trip_cost_row.reload()
                            
                        }
                        
                    }
                    
            } //end button selection
        
        
        
    } //end function
    
    
//    //https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user-friendly_place_names
//    func getCoordinate( addressString : String,
//                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
//            if error == nil {
//                if let placemark = placemarks?[0] {
//                    let location = placemark.location!
//
//                    completionHandler(location.coordinate, nil)
//                    return
//                }
//            }
//            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
//        }
//    }
//
//    // Returns a distance in meters from a starting location to a destination location.
//    func calculateDrivingDistance(to destination: CLLocation, completion: @escaping(CLLocationDistance?) -> Void) {
//
//
//        getCoordinate(addressString: book.address!, completionHandler: {
//            coordinates, error in
//
//
//
//        }
//
//        let request = MKDirections.Request()
//
//        let startingPoint = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(self.coordinate.latitude, self.coordinate.longitude)))
//        let endingPoint = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(destination.coordinate.latitude, destination.coordinate.longitude)))
//        request.source = startingPoint
//        request.destination = endingPoint
//
//        let directions = MKDirections(request: request)
//        directions.calculate { (response, error) in
//            if error != nil {
//                assertionFailure("Failed to calculate driving distance. \(String(describing: error))")
//            }
//
//            guard let data = response else { return }
//
//            let meterDistance = data.routes.first?.distance
//            completion(meterDistance)
//        }
//    }

    public func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true)
    }
    
    func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    

}

