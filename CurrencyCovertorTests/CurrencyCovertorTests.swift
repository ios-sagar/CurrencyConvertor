//
//  CurrencyCovertorTests.swift
//  CurrencyCovertorTests
//
//  Created by Admin on 08/08/22.
//

import XCTest
import Alamofire

@testable import CurrencyCovertor

class CurrencyCovertorTests: XCTestCase {

    let networkManagerObj = NetworkManager()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetAllRatesRequest(){
        let testrequest = URL(string: "https://openexchangerates.org/api/latest.json?app_id=7c7cf4440ab54a5db460e63b289bb82c")
        let request = URL(string: API.baseURL)
        XCTAssertNotNil(request)
        XCTAssert(testrequest == request)
    }
    
    func testAPIResponse(){
        let request = URL(string: API.baseURL)!
        networkManagerObj.getDataFrom(url: request) { currency, Error in
            if currency != nil{
                XCTAssertTrue(true)
            }else{
                XCTAssertFalse(false)
            }
        }
    }
    
    func testBindData(){
        let mockDashboardModel = MockDashboardViewModel()
        let request = URL(string: API.baseURL)!
        var bindResult : Bool?
        networkManagerObj.getDataFrom(url: request, completion: { currency, Error in
            if let response = currency {
                bindResult = mockDashboardModel.testBindData(parameter: response)
                if(bindResult!){
                    XCTAssert(true)
                }else{
                    XCTAssert(false)
                }
            }
        })
    }
    
    func testConvertCurrency(){
        let mockDashboardModel = MockDashboardViewModel()
        let convertedCurrency = mockDashboardModel.testConvertCurrency(enteredAmount: "1", selectedCurrency: "NZD")
        let rateArray = [0.9, 0.81, 4.24, 0.61, 0.52, 50.04, 84.97, 1.0, 0.86, 22.25, 0.62]
        if(rateArray == convertedCurrency){
            XCTAssert(true)
        }else{
            XCTAssert(false)
        }
    }
}
