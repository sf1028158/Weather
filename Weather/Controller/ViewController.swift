//
//  ViewController.swift
//  Weather
//
//  Created by Fang Shao on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
   // let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count // You will replace this with arrCurrentWeather.count
    
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = arr[indexPath.row] // replace this with values from arrCurrentWeather array
        let currentWeather = currentWeatherArray[indexPath.row]
        cell.textLabel?.text="\(currentWeather.cityInfoName)\(currentWeather.temp)℉\(currentWeathe.weatherText)"
        if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("rainny")){
                    cell.imgWeather.image = UIImage(named: "rainny")
                }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("cloudy")){
                    cell.imgWeather.image = UIImage(named: "cloudy")
                }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("snowy")){
                    cell.imgWeather.image = UIImage(named: "snowy")
                }else if(arrCurrentWeather[indexPath.row].weatherText.lowercased().contains("windy")){
                    cell.imgWeather.image = UIImage(named: "windy")
                }else{
                    cell.imgWeather.image = UIImage(named: "sunny")
                }
        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
//        do{
//            let realm = try Realm()
//            let cities = realm.objects(CityInfo.self)
//            self.arrCityInfo.removeAll()
//            getAllCurrentWeather(Array(cities)).done { currentWeather in
//               self.tblView.reloadData()
//            }
//            .catch { error in
//               print(error)
//            }
//       }catch{
//           print("Error in reading Database \(error)")
//       }
        
        
        
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ... cities.count - 1 {
                promises.append( getCurrentWeather(cities[i].key) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "\(currentWeatherURL)\(cityKey)?apikey=\(apiKey)"
                
                Alamofire.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let weatherJSON = JSON( response.data!).array
                    
                    guard let WeatherInfo = weatherJSON!.first else { seal.fulfill(CurrentWeather())
                        
                                            return
                                        }
                    let currentWeather = CurrentWeather()
                    
                    currentWeather.cityInfoName = cityName
                    currentWeather.cityKey = cityKey
                    currentWeather.epochTime = WeatherInfo["EpochTime"].intValue
                    currentWeather.isDayTime = WeatherInfo["IsDayTime"].boolValue
                    currentWeather.tempMetric = WeatherInfo["Temperature"]["Metric"]["Value"].intValue
                    currentWeather.tempImperial = WeatherInfo["Temperature"]["Imperial"]["Value"].intValue
                    currentWeather.weatherText = WeatherInfo["WeatherText"].stringValue
 
                                       
                    
                    
                    
                  
                  //  let currentWeather = CurrentWeather()
                    
                    
                    seal.fulfill(currentWeather)
                    
                }
            }
    }

}

