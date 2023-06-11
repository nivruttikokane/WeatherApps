//
//  Constant.swift
//  BasicWeatherApp
//
//  Created by Aventri on 11/06/23.
//

import Foundation
import UIKit


struct Path{
    
    static let appKey = "90ff405c8be271ca12aeccf4bcd9a394"
    static let baseUrl = "https://api.openweathermap.org/data/2.5/weather?q="
    static let ImageUrl = "https://openweathermap.org/img/wn/"
    static let  noInternet = " Make sure your Wi-Fi or cellular data is turned on and try again.";
}

final class Constant: NSObject {
   static let sharedInstance = Constant()

   private override init() { }
    
    func convertDateToMMDDForamat(dateStr:Double)->String{
        let date = Date(timeIntervalSince1970: dateStr)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd HH:mm a"//this your string date format
      //      dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
     //   dateFormatter.locale = Locale(identifier: "your_loc_id")
        return dateFormatter.string(from: date)
    }
    
    func convertTemp(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        let mf = MeasurementFormatter()
       mf.numberFormatter.maximumFractionDigits = 0
       mf.unitOptions = .providedUnit
       let input = Measurement(value: temp, unit: inputTempType)
       let output = input.converted(to: outputTempType)
       return mf.string(from: output)
     }
    
    func convertTempToCelsius(value:Double)->MeasurementFormatter{
        let mf = MeasurementFormatter()
        let measurement = Measurement(value: value, unit: UnitLength.meters).converted(to: .kilometers)
        mf.unitOptions = .providedUnit
        mf.unitStyle = .medium
        mf.numberFormatter.maximumFractionDigits = 1
        return mf
    }
    
    func setCornarRadiusToView(view:UIView){
        view.layer.cornerRadius = 10.0
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0
    }
    
}

extension UIButton{
    class func setCornarRadiusToButton(btn:UIButton)->UIButton{
        btn.layer.cornerRadius = 10.0
        btn.layer.borderWidth = 2.0
        return btn
    }
}

