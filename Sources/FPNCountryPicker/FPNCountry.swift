import UIKit

public struct FPNCountry {
    public var code: FPNCountryCode
    public var name: String
    public var phoneCode: String
    public var languageCode: String
    public var flag: UIImage?
    public var languageDescription: String

    init(code: String, name: String, phoneCode: String,languageCode:String,languageDescription:String) {
        self.name = name
        self.phoneCode = phoneCode
        self.languageCode = languageCode
        self.code = FPNCountryCode(rawValue: code)!
        self.languageDescription = languageDescription

        if let flag = UIImage(named: code, in: Bundle.FlagIcons, compatibleWith: nil) {
            self.flag = flag
        } else {
            self.flag = UIImage(named: "unknown", in: Bundle.FlagIcons, compatibleWith: nil)
        }
    }
}
