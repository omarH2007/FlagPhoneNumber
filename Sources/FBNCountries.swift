//
//  FBNCountries.swift
//  FlagPhoneNumber
//
//  Created by Omar Ameen Hariri  on 26/05/2025.
//  Copyright © 2025 chronotruck. All rights reserved.
//


import UIKit

open class FBNCountries {
    open var selectedLocale: Locale?

    public init() {
        if let code = Locale.preferredLanguages.first {
            self.selectedLocale = Locale(identifier: code)
        }
    }
    
    public func getAllCountries() -> [FPNCountry] {
        let bundle: Bundle = Bundle.FlagPhoneNumber()
        let resource: String = "countryCodes"
        let jsonPath = bundle.path(forResource: resource, ofType: "json")
        
        assert(jsonPath != nil, "Resource file is not found in the Bundle")
        
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath!))
        
        assert(jsonPath != nil, "Resource file is not found")
        
        var countries = [FPNCountry]()
        
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSArray {
                
                for jsonObject in jsonObjects {
                    guard let countryObj = jsonObject as? NSDictionary else { return countries }
                    guard let code = countryObj["code"] as? String, let phoneCode = countryObj["dial_code"] as? String, let name = countryObj["name"] as? String, let languageCode = countryObj["language_code"] as? String else { return countries }
                    
                    if let locale = self.selectedLocale {
                        let country = FPNCountry(code: code, name: locale.localizedString(forRegionCode: code) ?? name, phoneCode: phoneCode,languageCode: languageCode)

                        countries.append(country)
                    } else {
                        let country = FPNCountry(code: code, name: name, phoneCode: phoneCode,languageCode: languageCode)
                        
                        countries.append(country)
                    }
                }
                
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        return countries.sorted(by: { $0.name < $1.name })
    }
}
