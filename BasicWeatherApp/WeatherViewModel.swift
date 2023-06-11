//
//  WeatherViewModel.swift
//  BasicWeatherApp
//
//  Created by Aventri on 11/06/23.
//

import Foundation
import UIKit


final class WeatherViewModel: NSObject {
    static let sharedInstance = WeatherViewModel()
    
    private override init() { }
    
    func getWeather(url:URL?,vc:UIViewController,indicator:UIActivityIndicatorView!,completion:@escaping (WeatherModel) -> ()) {
        // This is a pretty simple networking task, so the shared session will do.
        // The data task retrieves the data.
        //  let task = session.dataTask(with: weatherRequestURL as URL,
        let task = URLSession.shared.dataTask(with: url!) { data, responce, error in
            DispatchQueue.main.async {
                indicator.stopAnimating()
                indicator.hidesWhenStopped = true
            }
            // An error occurred while trying to get data from the server.
            if error != nil{
                print(error!)
                DispatchQueue.main.async {
                    vc.showToast(message: "Error Occured", font: .systemFont(ofSize: 12.0))
                }
                return
            }
            guard let responce = responce as? HTTPURLResponse,responce.statusCode == 200 else{
                DispatchQueue.main.async {
                    vc.showToast(message: "HTTP error", font: .systemFont(ofSize: 12.0))
                    print("HTTP error")
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    vc.showToast(message: "No Response Found", font: .systemFont(ofSize: 12.0))
                }
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "weatherData")
            // We got data from the server!
            // Try to convert that data into a model
            let responseData = try? JSONDecoder().decode(WeatherModel.self, from: data)
            if let responseData = responseData{
                completion(responseData)
            }
            
        }
        // The data task is set up...launch it!
        task.resume()
    }
}

