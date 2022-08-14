//
//  DashboardViewModel.swift
//  CurrencyCovertor
//
//  Created by Admin on 09/08/22.
//

import Foundation
import UIKit
import CoreData
import UniformTypeIdentifiers

protocol DashboardViewDelegate{
    func getRateValues(rateValues : [String: Double])
    func getUpdatesRateValues(rateValues : [String: Double])
}

struct CurrencyResponse: Codable {
    let disclaimer: String
    let license: String
    let timestamp: Int
    let base: String
    let rates: [String: Double]
}

class DashboardViewModel{
    let currencies = ["AUD", "CAD", "CNH", "EUR", "GBP", "INR", "JPY", "NZD", "SGD", "THB", "USD"]
    private var amount : String = ""
    private var outputCurrency = [Double]()
    var rateValues = [String: Double]()
    var networkManager = NetworkManager()
    var dashboardDelegate : DashboardViewDelegate?
    var ratesValue = [String: Double]()
    let reachability = Reachability()
    
    //MARK: check if call is done in last 30 min
    func saveLastServiceCalledDate() {
        UserDefaults.standard.set(Date(), forKey: "lastServiceCallDate")
    }

    func isCalledInLast30Min() -> Bool {
        guard let lastDate = UserDefaults.standard.value(forKey: "lastServiceCallDate") as? Date else { return false }
        let timeElapsed: Int = Int(Date().timeIntervalSince(lastDate))
        return timeElapsed < 30 * 60 // 30 minutes
    }

    func serviceCallToGetAPI() {
        if(isCalledInLast30Min()){
            getFromPlist()
        }else{
            loadRates()
            saveLastServiceCalledDate()
        }
    }
    
    //MARK: API to get rates
    func loadRates() {
        if(reachability.isConnectedToNetwork()){
            let fileUrl = URL(string: API.baseURL)
            networkManager.getDataFrom(url: fileUrl!, completion: { currency, Error in
                if let response = currency {
                    self.bindData(parameter: response)
                }
            })
        }else{
            getFromPlist()
        }
        
    }
    
    func bindData(parameter: Any?) {
        if let data = parameter as? CurrencyResponse {
            self.ratesValue = data.rates
            dashboardDelegate?.getRateValues(rateValues: self.ratesValue)
            writePlist(dictContent: self.ratesValue)
        }else{
            print("error")
        }
    }
    
    //MARK: function to convert rates for selective currencies
    func convertCurrency(enteredAmount : String, selectedCurrency : String){
        let convertedAmount = convert(enteredAmount, selectedCurrency: selectedCurrency)
        print(convertedAmount)
    }
    
    func convert(_ convert : String, selectedCurrency: String) -> [Double]{
        outputCurrency.removeAll()
        var conversion : Double = 1.0
        let amount = Double(convert) ?? 0.0
        let selectedCurrency = selectedCurrency
        
        let audRates = ["AUD" : 1.0, "CAD": 0.90, "CNH" : 4.70, "EUR" : 0.68, "GBP" : 0.58, "INR" : 55.42, "JPY" : 94.11, "NZD" : 1.11, "SGD" : 0.96, "THB" : 24.65, "USD" : 0.70]
        let cadRates = ["AUD" : 1.11, "CAD": 1.0, "CNH" : 5.24, "EUR" : 0.76, "GBP" : 0.64, "INR" : 61.77, "JPY" : 104.89, "NZD" : 1.23, "SGD" : 1.07, "THB" : 27.48, "USD" : 0.78]
        let cnhRates = ["AUD" : 0.21, "CAD": 0.19, "CNH" : 1.0, "EUR" : 0.99, "GBP" : 0.12, "INR" : 11.78, "JPY" : 20.0, "NZD" : 0.23, "SGD" : 0.20, "THB" : 5.24, "USD" : 0.14]
        let eurRates = ["AUD" : 1.46, "CAD": 1.31, "CNH" : 6.89, "EUR" : 1.0, "GBP" : 0.84, "INR" : 81.28, "JPY" : 138.02, "NZD" : 1.62, "SGD" : 1.40, "THB" : 36.15, "USD" : 1.02]
        let gbpRates = ["AUD" : 1.73, "CAD": 1.55, "CNH" : 8.15, "EUR" : 1.18, "GBP" : 1.0, "INR" : 96.07, "JPY" : 163.14, "NZD" : 1.91, "SGD" : 1.66, "THB" : 42.73, "USD" : 1.20]
        let inrRates = ["AUD" : 0.018, "CAD": 0.016, "CNH" : 0.08, "EUR" : 0.012, "GBP" : 0.010, "INR" : 1.0, "JPY" : 1.69, "NZD" : 0.019, "SGD" : 0.017, "THB" : 0.44, "USD" : 0.012]
        let jpyRates = ["AUD" : 0.010, "CAD": 0.0095, "CNH" : 0.049, "EUR" : 0.0072, "GBP" : 0.0061, "INR" : 0.58, "JPY" : 1.0, "NZD" : 0.011, "SGD" : 0.010, "THB" : 0.26, "USD" : 0.0074]
        let nzdRates = ["AUD" : 0.90, "CAD": 0.81, "CNH" : 4.24, "EUR" : 0.61, "GBP" : 0.52, "INR" : 50.04, "JPY" : 84.97, "NZD" : 1.0, "SGD" : 0.86, "THB" : 22.25, "USD" : 0.62]
        let sgdRates = ["AUD" : 1.04, "CAD": 0.93, "CNH" : 4.89, "EUR" : 0.71, "GBP" : 0.60, "INR" : 57.71, "JPY" : 98.01, "NZD" : 1.15, "SGD" : 1.0, "THB" : 25.67, "USD" : 0.72]
        let thbRates = ["AUD" : 0.04, "CAD": 0.03, "CNH" : 0.19, "EUR" : 0.02, "GBP" : 0.02, "INR" : 2.24, "JPY" : 3.81, "NZD" : 0.04, "SGD" : 0.03, "THB" : 1.0, "USD" : 0.028]
        let usdRates = ["AUD" : 1.43, "CAD": 1.28, "CNH" : 6.75, "EUR" : 0.97, "GBP" : 0.82, "INR" : 79.56, "JPY" : 135.13, "NZD" : 1.59, "SGD" : 1.37, "THB" : 35.39, "USD" : 1.0]
                
        switch (selectedCurrency){
        case "AUD" :
            for i in 0...currencies.count-1{
                conversion = amount * (audRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
        case "CAD" :
            for i in 0...currencies.count-1{
                conversion = amount * (cadRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "CNH" :
            for i in 0...currencies.count-1{
                conversion = amount * (cnhRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "EUR" :
            for i in 0...currencies.count-1{
                conversion = amount * (eurRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "GBP" :
            for i in 0...currencies.count-1{
                conversion = amount * (gbpRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "INR" :
            for i in 0...currencies.count-1{
                conversion = amount * (inrRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "JPY" :
            for i in 0...currencies.count-1{
                conversion = amount * (jpyRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "NZD" :
            for i in 0...currencies.count-1{
                conversion = amount * (nzdRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "SGD" :
            for i in 0...currencies.count-1{
                conversion = amount * (sgdRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "THB" :
            for i in 0...currencies.count-1{
                conversion = amount * (thbRates[currencies[i]] ?? 0.0)
                outputCurrency.append(conversion)
            }
            rateValues = Dictionary(uniqueKeysWithValues: zip(currencies, outputCurrency))
            dashboardDelegate?.getUpdatesRateValues(rateValues: rateValues)
            
        case "USD" :
            if(reachability.isConnectedToNetwork()){
                self.loadRates()
            }else{
                for i in 0...self.currencies.count-1{
                    conversion = amount * (usdRates[self.currencies[i]] ?? 0.0)
                    self.outputCurrency.append(conversion)
                }
                self.rateValues = Dictionary(uniqueKeysWithValues: zip(self.currencies, self.outputCurrency))
                self.dashboardDelegate?.getUpdatesRateValues(rateValues: self.rateValues)
            }
        default:
            print("something went wrong")
        }
        return outputCurrency
    }
        
    //MARK: function to save received rates from API locally
    func writePlist(dictContent: [String: Double]) {
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/data.plist")
        let url = URL(fileURLWithPath: path)
        
        if(!fileManager.fileExists(atPath: path)){
            let data : [String:Any] = [:]
            let someData = NSDictionary(dictionary: data)
            let isWritten = someData.write(toFile: path, atomically: true)
        } else {
            print("file exists")
        }
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: dictContent, format: .xml, options: 0)
            try plistData.write(to: url)
        } catch {
            print(error)
        }
    }
    
    //MARK: function to retrived received rates from locally
    func getFromPlist(){
        do {
            self.ratesValue = try loadPropertyList()
            dashboardDelegate?.getRateValues(rateValues: self.ratesValue)
        } catch {
            print(error)
        }
    }
    
    func loadPropertyList() throws -> [String:Double]
    {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/data.plist")
        let plistURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: plistURL)
        guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Double] else {
            return [:]
        }
        return plist
    }
}
