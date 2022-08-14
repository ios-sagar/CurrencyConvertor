//
//  NetworkManager.swift
//  CurrencyCovertor
//
//  Created by Admin on 09/08/22.
//

import Foundation
import Alamofire

class NetworkManager: NSObject {

    func getDataFrom(url: URL, completion: @escaping (CurrencyResponse?, Error?) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            guard let data = response.data else { return }
            do {
                let currencies = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                completion(currencies, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
}
