//
//  ViewController.swift
//  TravelCost
//
//  Created by Marco on 16/06/2019.
//  Copyright © 2019 Marco. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        buildForm()
        
    }
    
    private func buildForm(){
        form
            
            +++ Section()
            
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
            }
        
            <<< DecimalRow() {
                $0.title = "KM/L"
                $0.value = 20.83
                $0.tag = "kml"
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
        
            +++ Section()
            
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
                    let distanceForm: DecimalRow? = self?.form.rowBy(tag: "distance")
                    let fuel_priceForm : DecimalRow? = self?.form.rowBy(tag: "fuel_price")
                    let l100Form : DecimalRow? = self?.form.rowBy(tag: "l100")
                    let kmlForm : DecimalRow? = self?.form.rowBy(tag: "kml")
                    let roundtripForm : SwitchRow? = self?.form.rowBy(tag: "roundtrip")

                    if distanceForm?.value==nil || fuel_priceForm?.value==nil || l100Form?.value==nil {
                        self!.showAlert(title: "Error", message: "Fill the missing fields")
                    } else {
                    
                        let l100 = Double(l100Form!.value!)
                        var distance = Double(distanceForm!.value!)
                        let fuel_price = Double(fuel_priceForm!.value!)
                        let kml = 100/l100
                        let roundtrip = roundtripForm!.value!
                        
                        let kml_row = self!.form.rowBy(tag: "kml") as! DecimalRow
                        kml_row.value = self!.roundToPlaces(value: kml, places: 2)
                        kml_row.reload()
                        
                        if (roundtrip) {
                            distance = distance * 2
                        }
                        
                        let price = (distance * fuel_price) / kml

                        let trip_cost_row = self!.form.rowBy(tag: "trip_cost") as! DecimalRow
                        trip_cost_row.value = self!.roundToPlaces(value: price, places: 2)
                        trip_cost_row.reload()
                        
                    }
                    
            } //end button selection
        
        
        
    } //end function

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

