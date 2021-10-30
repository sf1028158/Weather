//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Fang Shao on 10/28/21.

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    //let arr = ["Seattle WA, USA", "Seaside CA, USA"]
    var arr = [CityInfo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        arr.removeAll()
        getCitiesFromSearch(searchText)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
       // cell.textLabel?.text = arr[indexPath.row] // You will change this to getr values from arrCityinfo and assign text
        let city=arr[indexPath.row]
        cell.textLabel?.text ="\(city.localizedName) \(city.administrativeID), \(city.countryLocalizedName)"
        
        return cell
    }
    
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        // Network call from there
        let url = getSearchURL(searchText)
        
    
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrCityInfo
            // Reload table with the values
            let cityArray = JSON(response.data)
                       for (_, city):(String, JSON) in cityArray {
                           let cityInfo = CityInfo()
                           cityInfo.key = city["Key"].stringValue
                           cityInfo.administrativeID = city["AdministrativeArea"]["ID"].stringValue
                           cityInfo.countryLocalizedName = city["Country"]["LocalizedName"].stringValue
                           cityInfo.localizedName = city["LocalizedName"].stringValue
                           cityInfo.type = city["Type"].stringValue
                           self.arr.append(cityInfo)
                       }                       
                       self.tblView.reloadData()
        }
        
    }
    
    func addCityinDB(_ cityInfo : CityInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(cityInfo, update: Realm.UpdatePolicy.all)
            }
        }catch{
            print("Error in adding city in database\(error)")
        }
    }
    
    
    func checkIfCityAdded(_ index : String) -> Bool {
         do{
             let realm = try Realm()
             if realm.object(ofType: CityInfo.self, forPrimaryKey: index) != nil { return true }
         
         }catch{
             print("Error in checking if city is added \(error)")
         }
         return false
     }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        
        let cityInfo = arr[indexPath.row]
                if !checkIfCityAdded(cityInfo.key) {
                    addCityinDB(cityInfo)
                }
                self.navigationController?.popViewController(animated: true)
    }

}
