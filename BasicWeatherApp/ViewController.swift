//
//  ViewController.swift
//  BasicWeatherApp
//
//  Created by Aventri on 11/06/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    // variable Declaration
    @IBOutlet var txtCity : UITextField!
    @IBOutlet var searchButton : UIButton!
    @IBOutlet var outerView : UIView!
    @IBOutlet var currentDateTimeLabel : UILabel!
    @IBOutlet var cityNameLabel : UILabel!
    @IBOutlet var img : UIImageView!
    @IBOutlet var temp_maxLabel : UILabel!
    @IBOutlet var feels_likeLabel : UILabel!
    @IBOutlet var visibilityLabel : UILabel!
    @IBOutlet var humidityLabel : UILabel!
    var indicator = UIActivityIndicatorView()
    let mf = MeasurementFormatter()
    let locationManager = CLLocationManager()
    @IBOutlet weak var getLocationWeatherButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton = UIButton.setCornarRadiusToButton(btn: self.searchButton)
        activityIndicator()
        outerView.isHidden = true
        setPrevoiusDataForWeatherInformation()
    }
    
    func setPrevoiusDataForWeatherInformation(){
        let defaults = UserDefaults.standard
        if let weatherObject = defaults.object(forKey: "weatherData") as? Data {
            let decoder = JSONDecoder()
            if let weatherData = try? decoder.decode(WeatherModel.self, from: weatherObject) {
                print(weatherData.name)
                outerView.isHidden = false
                self.displayWeatherDataOnView(weatherdata: weatherData)
            }
        }
    }
    @IBAction func getLocationButtonClicked(){
        getLocation()
    }
    
    @IBAction func searchButtonClicked(){
        var newSring = ""
        if !txtCity.text!.isEmpty{
            newSring = txtCity.text!.replacingOccurrences(of: " ", with: "%20")
            let urlString = "\(Path.baseUrl)\(newSring)&appid=\(Path.appKey)"
            if Helper.connectedToNetwork(){
                indicator.startAnimating()
                indicator.backgroundColor = .white
                WeatherViewModel.sharedInstance.getWeather(url: URL(string: urlString), vc: self, indicator: self.indicator) { response in
                    // This method is called asynchronously, which means it won't execute in the main queue.
                    // All UI code needs to execute in the main queue, which is why we're wrapping the code
                    // that updates all the labels in a dispatch_async() call.
                    DispatchQueue.main.async {
                        self.outerView.isHidden = false
                        self.displayWeatherDataOnView(weatherdata: response)
                    }
                    
                }
            }else{
                // self.view.makeToast(Path.noInternet, duration: 1.0, position: .center)
                DispatchQueue.main.async {
                    self.showToast(message: "Please check internet connection", font: UIFont.systemFont(ofSize: 20))
                }
                
                
            }
        }else{
            self.showToast(message: "Please enter city here", font: UIFont.systemFont(ofSize: 20))
        }
    }
    
    func displayWeatherDataOnView(weatherdata:WeatherModel){
        var localDate = ""
        if weatherdata.dt != 0.0 {
            localDate = Constant.sharedInstance.convertDateToMMDDForamat(dateStr: weatherdata.dt)
        }
        let temperature = weatherdata.main.tempMax
        let celsius = Constant.sharedInstance.convertTemp(temp: temperature, from: .kelvin, to: .celsius)
        DispatchQueue.main.async {
            Constant.sharedInstance.setCornarRadiusToView(view: self.outerView)
            self.currentDateTimeLabel.text = "\(localDate )"
            self.cityNameLabel.text = "\(weatherdata.name ), \(weatherdata.sys.country )"
            self.temp_maxLabel.text = celsius
            self.feels_likeLabel.text = "Feels Like :\(celsius)     \(weatherdata.weather[0].description )"
            self.humidityLabel.text = "Humidity:\(weatherdata.main.humidity )%"
            let value = Double(weatherdata.visibility )
            let measurement = Measurement(value: value, unit: UnitLength.meters).converted(to: .kilometers)
            self.visibilityLabel.text = "Visibilty:\(Constant.sharedInstance.convertTempToCelsius(value: value).string(from: measurement))"
        }
        let icon = weatherdata.weather[0].icon
        if icon != ""{
            let url = URL(string: "\(Path.ImageUrl)\(icon)@2x.png")
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    if let tempData = data{
                        self.img.image = UIImage(data: tempData)
                    }
                }
            }
        }
    }
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    // MARK: - CLLocationManagerDelegate and related methods
    
    func getLocation() {
        
        // Create a CLLocationManager and assign a delegate
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        // Request a user’s location once
        locationManager.requestLocation()
        
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                // Handle location update
                let urlString = "\(Path.baseUrl)&appid=\(Path.appKey)&lat=\(latitude)&lon=\(longitude)"
                
                
                if Helper.connectedToNetwork(){
                    indicator.startAnimating()
                    indicator.backgroundColor = .white
                    WeatherViewModel.sharedInstance.getWeather(url: URL(string: urlString), vc: self, indicator: self.indicator) { response in
                        //  self.model = response
                        DispatchQueue.main.async {
                            self.outerView.isHidden = false
                            self.displayWeatherDataOnView(weatherdata: response)
                        }
                        
                    }
                }else{
                    // self.view.makeToast(Path.noInternet, duration: 1.0, position: .center)
                    DispatchQueue.main.async {
                        self.showToast(message: "Please check internet connection", font: UIFont.systemFont(ofSize: 20))
                    }
                    
                    
                }
            }
        }
    
    
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error) {
        // Handle failure to get a user’s location
        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't determine your location",
                                 message: "The GPS and other location services aren't responding.")
        }
        print("locationManager didFailWithError: \(error)")
    }
    
    // MARK: - Utility methods
    // -----------------------
    
    func showSimpleAlert(title title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
}
extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/3 - 80, y: self.view.frame.size.height-100, width: 300, height: 50))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
}
   
}

