//
//  FlagPhoneNumberTextField.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import UIKit

open class FPNTextField: UITextField, FPNCountryPickerDelegate, FPNDelegate {

    
    public var validPhoneNumber:NBPhoneNumber? = nil
    
    @objc public let paddingView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    @objc public let arrowIconLable: UILabel = {
        let view = UILabel()
        view.isUserInteractionEnabled = true
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var phoneCodeTextField: UILabel = UILabel()
    private lazy var countryPicker: FPNCountryPicker = FPNCountryPicker()
    private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil()
    private var nbPhoneNumber: NBPhoneNumber? {
        didSet{
            self.validPhoneNumber = nbPhoneNumber
        }
    }
    private var formatter: NBAsYouTypeFormatter?


    open  var borderLeftColor: UIColor? {
        didSet {
            paddingView.addBorder(to: .right, in: borderLeftColor ?? .clear, width: 1)
          
        }
    }
    
    open override var font: UIFont? {
        didSet {
            phoneCodeTextField.font = font
        }
    }

    open override var textColor: UIColor? {
        didSet {
            phoneCodeTextField.textColor = textColor
        }
    }

    /// Present in the placeholder an example of a phone number according to the selected country code.
    /// If false, you can set your own placeholder. Set to true by default.
    @objc public var hasPhoneNumberExample: Bool = true {
        didSet {
            if hasPhoneNumberExample == false {
                placeholder = nil
            }
            updatePlaceholder()
        }
    }

    open var selectedCountry: FPNCountry? {
        didSet {
            updateUI()
        }
    }

    /// If set, a search button appears in the picker inputAccessoryView to present a country search view controller
    @IBOutlet public var parentViewController: UIViewController?

    /// Input Accessory View for the texfield
    @objc public var textFieldInputAccessoryView: UIView?

    init() {
        super.init(frame: .zero)

        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    deinit {
        parentViewController = nil
    }

    private func setup() {
        leftViewMode = .always

        setupFlagButton()
        setupPhoneCodeTextField()
        setupLeftView()
        setupCountryPicker()

        keyboardType = .numberPad
        autocorrectionType = .no
        addTarget(self, action: #selector(didEditText), for: .editingChanged)
        addTarget(self, action: #selector(displayNumberKeyBoard), for: .touchDown)
    }

    private func setupFlagButton() {
    }

    private func setupPhoneCodeTextField() {
        phoneCodeTextField.textAlignment = .center
        phoneCodeTextField.font = font
        phoneCodeTextField.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLeftView() {

        let view = UIControl()
        leftView = UIView()
        leftViewMode = .always
        leftView?.addSubview(view)
        view.addSubview(arrowIconLable)
        view.addSubview(phoneCodeTextField)
        phoneCodeTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.addSubview(paddingView)
        view.addTarget(self, action: #selector(displayCountryKeyboard), for: .touchUpInside)
        if let leftView = leftView {
            paddingView.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: leftView.trailingAnchor),
                view.topAnchor.constraint(equalTo: leftView.topAnchor),
                view.bottomAnchor.constraint(equalTo: leftView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: leftView.leadingAnchor,constant: 0),
                arrowIconLable.widthAnchor.constraint(equalToConstant: 20),
                arrowIconLable.heightAnchor.constraint(equalToConstant: 20),
                arrowIconLable.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                arrowIconLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                phoneCodeTextField.leadingAnchor.constraint(equalTo: paddingView.trailingAnchor,constant: 8),
                phoneCodeTextField.topAnchor.constraint(equalTo: view.topAnchor,constant: 2),
                phoneCodeTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -2),
                phoneCodeTextField.trailingAnchor.constraint(equalTo: arrowIconLable.leadingAnchor,constant: -6),
                paddingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
                paddingView.widthAnchor.constraint(equalToConstant: 1),
                paddingView.topAnchor.constraint(equalTo: view.topAnchor,constant: 0),
                paddingView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 0),
                
            ])
         
        }

    }

    open override func updateConstraints() {
        super.updateConstraints()

    }


    
    private func setupCountryPicker() {
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        countryPicker.backgroundColor = .white

        if let regionCode = Locale.current.regionCode, let countryCode = FPNCountryCode(rawValue: regionCode) {
            countryPicker.setCountry(countryCode)
        } else if let firstCountry = countryPicker.countries.first {
            countryPicker.setCountry(firstCountry.code)
        }
    }

    @objc private func displayNumberKeyBoard() {
        inputView = nil
        inputAccessoryView = textFieldInputAccessoryView
        tintColor = .gray
        reloadInputViews()
    }

    @objc private func displayCountryKeyboard() {
        inputView = countryPicker
        inputAccessoryView = getToolBar(with: getCountryListBarButtonItems())
        tintColor = .clear
        reloadInputViews()
        becomeFirstResponder()
    }

    @objc private func displayAlphabeticKeyBoard() {
        showSearchController()
    }

    @objc private func resetKeyBoard() {
        inputView = nil
        inputAccessoryView = nil
        resignFirstResponder()
    }

    // - Public

    /// Set the country image according to country code. Example "FR"
    public func setFlag(for countryCode: FPNCountryCode) {
        countryPicker.setCountry(countryCode)
    }

    /// Get the current formatted phone number
    public func getFormattedPhoneNumber(format: FPNFormat) -> String? {
        return try? phoneUtil.format(nbPhoneNumber, numberFormat: convert(format: format))
    }

    /// For Objective-C, Get the current formatted phone number
    @objc public func getFormattedPhoneNumber(format: Int) -> String? {
        if let formatCase = FPNFormat(rawValue: format) {
            return try? phoneUtil.format(nbPhoneNumber, numberFormat: convert(format: formatCase))
        }
        return nil
    }

        /// Get the current raw phone number
    @objc public func getRawPhoneNumber() -> String? {
        let phoneNumber = getFormattedPhoneNumber(format: .E164)
        var nationalNumber: NSString?

        phoneUtil.extractCountryCode(phoneNumber, nationalNumber: &nationalNumber)

        return nationalNumber as String?
    }

    /// Set directly the phone number. e.g "+33612345678"
    @objc public func set(phoneNumber: String) {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)

        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            if validPhoneNumber.italianLeadingZero {
                text = "0\(validPhoneNumber.nationalNumber.stringValue)"
            } else {
                text = validPhoneNumber.nationalNumber.stringValue
            }
            setFlag(for: FPNCountryCode(rawValue: phoneUtil.getRegionCode(for: validPhoneNumber))!)
        }
    }

    /// Set the country list excluding the provided countries
    public func setCountries(excluding countries: [FPNCountryCode]) {
        countryPicker.setup(without: countries)
    }

    /// Set the country list including the provided countries
    public func setCountries(including countries: [FPNCountryCode]) {
        countryPicker.setup(with: countries)
    }

    /// Set the country image according to country code. Example "FR"
    @objc public func setFlag(for key: FPNOBJCCountryKey) {
        if let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
            countryPicker.setCountry(countryCode)
        }
    }

    /// Set the country list excluding the provided countries
    @objc public func setCountries(excluding countries: [Int]) {
        let countryCodes: [FPNCountryCode] = countries.compactMap({ index in
            if let key = FPNOBJCCountryKey(rawValue: index), let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
                return countryCode
            }
            return nil
        })

        countryPicker.setup(without: countryCodes)
    }

    /// Set the country list including the provided countries
    @objc public func setCountries(including countries: [Int]) {
        let countryCodes: [FPNCountryCode] = countries.compactMap({ index in
            if let key = FPNOBJCCountryKey(rawValue: index), let code = FPNOBJCCountryCode[key], let countryCode = FPNCountryCode(rawValue: code) {
                return countryCode
            }
            return nil
        })

        countryPicker.setup(with: countryCodes)
    }

    // Private

    @objc private func didEditText() {
        if let phoneCode = selectedCountry?.phoneCode, let number = text {
            let cleanNmuber = number.replacingOccurrences(of: phoneCode, with: "")
            var cleanedPhoneNumber = clean(string: "\(phoneCode) \(cleanNmuber)")

            if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
                nbPhoneNumber = validPhoneNumber

                cleanedPhoneNumber = "+\(validPhoneNumber.countryCode.stringValue)\(validPhoneNumber.nationalNumber.stringValue)"

                if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                    text = remove(dialCode: phoneCode, in: inputString)
                }
                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, country: selectedCountry, isValid: true)
            } else {
                nbPhoneNumber = nil

                if let dialCode = selectedCountry?.phoneCode {
                    if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                        text = remove(dialCode: dialCode, in: inputString)
                    }
                }
                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, country: selectedCountry, isValid: false)
            }
        }
    }

    private func convert(format: FPNFormat) -> NBEPhoneNumberFormat {
        switch format {
        case .E164:
            return NBEPhoneNumberFormat.E164
        case .International:
            return NBEPhoneNumberFormat.INTERNATIONAL
        case .National:
            return NBEPhoneNumberFormat.NATIONAL
        case .RFC3966:
            return NBEPhoneNumberFormat.RFC3966
        }
    }

    private func updateUI() {
        if let countryCode = selectedCountry?.code {
            formatter = NBAsYouTypeFormatter(regionCode: countryCode.rawValue)
        }


        if let phoneCode = selectedCountry?.phoneCode {
            phoneCodeTextField.text = phoneCode
        }

        if hasPhoneNumberExample == true {
            updatePlaceholder()
        }
        didEditText()
    }

    private func clean(string: String) -> String {
        var allowedCharactersSet = CharacterSet.decimalDigits

        allowedCharactersSet.insert("+")

        return string.components(separatedBy: allowedCharactersSet.inverted).joined(separator: "")
    }

    private func getWidth(text: String) -> CGFloat {
        if let font = phoneCodeTextField.font {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: fontAttributes)

            return size.width.rounded(.up)
        } else {
            phoneCodeTextField.sizeToFit()

            return phoneCodeTextField.frame.size.width.rounded(.up)
        }
    }

    private func getValidNumber(phoneNumber: String) -> NBPhoneNumber? {
        guard let countryCode = selectedCountry?.code else { return nil }

        do {
            let parsedPhoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode.rawValue)
            let isValid = phoneUtil.isValidNumber(parsedPhoneNumber)

            return isValid ? parsedPhoneNumber : nil
        } catch _ {
            return nil
        }
    }

    private func remove(dialCode: String, in phoneNumber: String) -> String {
        return phoneNumber.replacingOccurrences(of: "\(dialCode) ", with: "").replacingOccurrences(of: "\(dialCode)", with: "")
    }

    private func showSearchController() {
        if let countries = countryPicker.countries {
            let searchCountryViewController = FPNSearchCountryViewController(countries: countries)
            let navigationViewController = UINavigationController(rootViewController: searchCountryViewController)

            searchCountryViewController.delegate = self

            parentViewController?.present(navigationViewController, animated: true, completion: nil)
        }
    }

    private func getToolBar(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()

        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }

    private func getCountryListBarButtonItems() -> [UIBarButtonItem] {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resetKeyBoard))

        doneButton.accessibilityLabel = "doneButton"

        if parentViewController != nil {
            let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(displayAlphabeticKeyBoard))

            searchButton.accessibilityLabel = "searchButton"

            return [searchButton, space, doneButton]
        }
        return [space, doneButton]
    }

    private func updatePlaceholder() {
        if let countryCode = selectedCountry?.code {
            do {
                let example = try phoneUtil.getExampleNumber(countryCode.rawValue)
                let phoneNumber = "+\(example.countryCode.stringValue)\(example.nationalNumber.stringValue)"

                if let inputString = formatter?.inputString(phoneNumber) {
                    placeholder = remove(dialCode: "+\(example.countryCode.stringValue)", in: inputString)
                } else {
                    placeholder = nil
                }
            } catch _ {
                placeholder = nil
            }
        } else {
            placeholder = nil
        }
    }

    // - FPNCountryPickerDelegate

    func countryPhoneCodePicker(_ picker: FPNCountryPicker, didSelectCountry country: FPNCountry) {
        var validPhoneNumber:NBPhoneNumber? = nil
        if let phoneCode = selectedCountry?.phoneCode, let number = text {
            var cleanedPhoneNumber = clean(string: "\(phoneCode) \(number)")
             validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber)
        }
        (delegate as? FPNTextFieldDelegate)?.fpnDidSelectCountry(country: country, isValid: validPhoneNumber != nil)
        selectedCountry = country
        self.validPhoneNumber = validPhoneNumber
    }

    // - FPNDelegate

    internal func fpnDidSelect(country: FPNCountry) {
        setFlag(for: country.code)
    }
}
extension UIView {
    enum ViewSide {
        case top
        case left
        case bottom
        case right
    }

    func addBorders(to sides: [ViewSide], in color: UIColor, width: CGFloat) {
        sides.forEach { addBorder(to: $0, in: color, width: width) }
    }

    func addBorder(to side: ViewSide, in color: UIColor, width: CGFloat) {
        switch side {
        case .top:
            addTopBorder(in: color, width: width)
        case .left:
            addLeftBorder(in: color, width: width)
        case .bottom:
            addBottomBorder(in: color, width: width)
        case .right:
            addRightBorder(in: color, width: width)
        }
    }

    func addTopBorder(in color: UIColor?, width borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(border)
    }

    func addBottomBorder(in color: UIColor?, width borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(border)
    }

    func addLeftBorder(in color: UIColor?, width borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(in color: UIColor?, width borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        addSubview(border)
    }
}
