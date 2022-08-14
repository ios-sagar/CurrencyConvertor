//
//  MockClasses.swift
//  CurrencyCovertorTests
//
//  Created by Admin on 14/08/22.
//

import XCTest

@testable import CurrencyCovertor

class MockDashboardViewModel : DashboardViewModel{
    func testBindData(parameter: Any?) -> Bool{
        if let data = parameter as? CurrencyResponse {
            self.ratesValue = data.rates
            return true
        }else{
            print("error")
            return false
        }
    }
    
    func testConvertCurrency(enteredAmount : String, selectedCurrency : String) ->[Double]{
        let convertedAmount = convert(enteredAmount, selectedCurrency: selectedCurrency)
        return convertedAmount
    }
}

class MockNetworkManager : NetworkManager{

    func getDataFrom(url: URL, completion: @escaping ([CurrencyResponse]?, Error?) -> Void) {
        completion(getSuccessData(), nil)
    }
    
    func getSuccessData() -> [CurrencyResponse]{
        let currency = [CurrencyResponse(disclaimer: "Usage subject to terms: https://openexchangerates.org/terms", license: "https://openexchangerates.org/license", timestamp: 1659981600, base: "USD", rates: ["AED":3.672975])]
        return currency
    }
}
