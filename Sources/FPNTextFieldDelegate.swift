//
//  FlagPhoneNumberTextFieldDelegate.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import UIKit

public protocol FPNTextFieldDelegate: UITextFieldDelegate {
	func fpnDidSelectCountry(country: FPNCountry?)
	func fpnDidValidatePhoneNumber(textField: FPNTextField,country: FPNCountry?, isValid: Bool)
}
