
import Foundation
import UIKit
struct Device {
    
    // MARK: DEVICE & SCREEN SIZE CONSTANTS
    static let SCREEN_WIDTH   = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT  = UIScreen.main.bounds.size.height
    
    var hasNotch: Bool {
            guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
            if UIDevice.current.orientation.isPortrait {
                return window.safeAreaInsets.top >= 44
            } else {
                return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
            }
        }
}
var AllContacts = [Contact]()

struct Constant {
    static let ConnectivityError = "ConnectivityError"
    #if DEV
    static let BASE_URL = "https://apiphoneado.zimblecode.com"
    #else
//    static let BASE_URL = "https://apiphoneado.zimblecode.com"
    static let BASE_URL = "https://api.phoneado.com"
    #endif
  
    static let CHAT_BASE_URL = ""
    static let ContentType = "application/json"
    static let ContentTypeEncoded = "application/x-www-form-urlencoded"

    static let GoogleAPIKey = ""
    
    //Application Delegate instane
    static let appDelegate: AppDelegate     = (UIApplication.shared.delegate as! AppDelegate)
    static let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate  as? SceneDelegate
    static let devicePlatform               = "ios"
    static let AppName                      = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
}

enum StoryBoardName: String {
    case authentication = "Authentication"
    case main = "Main"
    case loggedIn = "LoggedIn"
}

struct SegueID {
    static let signup                   = ""
    static let forgotPasswordEmail      = ""
    static let forgotPassword           = ""
    static let showOTPVC                = ""
    static let suignupVerification      = ""
}

struct  UserDefault{
    static let userId = "userId"
    static let profilePic = "profilePic"
    static let firstName = "firstName"
    static let loginUser = "Login User"
    static let isAdmin = "isAdmin"
    static let phoneNumber = "phoneNumber"


    static let appToken = "appToken";
    static let ignoreUpdate = "ignoreUpdate"
    static let ignoreMaintenance = "ignoreMaintenance"
    static let flagImage = "flagImage"
    //User Authentication Stored Keys
    static let loginUserData = "loginUserData"
    static let verifyOTPToken = "verifyOTPToken"
    static let verifyOTPType = "verifyOTPType"
    static let enteredConfirmPin = "enteredConfirmPin"
    static let signUpUserName = "signUpUserName"
    static let signUpMobileNumber = "signUpMobileNumber"
    static let isLocationUpdateRequired = "isLocationUpdateRequired"
    static let lastLocation = "lastLocation"
    static let locationUpdateTime = "locationUpdateTime"
}


//MARK:- Text Strings
struct TextString
{
    static let signin_capital = "SIGN IN"
    
    static let alert = "Alert"
    static let ok = "OK"
    static let yes = "Yes"
    static let no = "No"
    static let cancel = "Cancel"
    static let select = "Select"
    
    //MARK:- Common Strings
    static let done                     = "Done"
    static let error                    = "Error!"
    static let camera                   = "Camera"
    static let photoGallery             = "Photo Gallery"
    static let inValidResponseError     = "Sorry, something went wrong. Please try again."
    static let noResultFound            = "No results found"
    static let succcess                 = "Success"
    static let warning                  = "Warning"
}

//MARK:- Text Messages
struct TextMessages
{
    static let emptyYourEmail           = "Please enter your email."
    static let emptyEmail               = "Please enter email."
    static let emptyPhoneEmail          = "Please enter phone number/email."
    static let enterValidEmail          = "Please enter a valid email."
    static let enterYourPassword        = "Please enter your password."
    static let enterAPassword           = "Please enter a password."
    static let enterValidPhone          = "Please enter a valid phone number."
    static let enterFirstName           = "Please enter first name."
    static let validFirstName           = "Please enter a valid First Name"
    static let emptyPhone               = "Please enter a phone number."
    static let validPassword            = "The minimum length of password must be 8 characters and maximum upto 20 characters."
    
    static let enterAddress             = "Please enter address."
    static let enterCity                = "Please enter city name."
    static let enterState               = "Please enter state name."
    static let enterZipCode             = "Please enter zip code."
    static let validZipCode             = "Please enter a valid zip code."
    static let invalidLocation          = "Please enter your address."
    static let chooseCurrentLocation    = "Please choose current location"
    
    static let validCardName            = "Please enter the name on card."
    static let validCardNumber          = "Please enter a valid card number."
    static let validMonth               = "Please select month of expire."
    static let validYear                = "Please select year of expire."
    static let enterCVV                 = "Please enter CVV."
    static let validCVV                 = "Please enter a valid CVV."
    
    static let emptyUserName            = "Please enter a name."
}
//MARK: - Otp Type
enum OtpType {
    static let REGISTER_OTP = "UR"
    static let FORGOT_OTP = "FP"
    static let MOBILE_UPDATE_OTP = "UU"
}
//MARK: - Toast Messages
struct TaostMessages {
    static let emptyPhoneNumber = "Please Enter a Phone Number."
    static let invalidPhoneNumber = "Please Enter a valid phone number."
    static let invalidPinEntered = "Please Enter a valid Pin."
    static let confirmPinEntered = "Please Enter a confirm Pin."

    static let enteredPinMismatch = "Entered Pin does not match."
    static let consentUnchecked = "You have to agree to the Terms and Conditions."
}

struct HObservers{
    static let updateMessagesCount = "updateMessagesCount"
    static let updateGroupNameImage = "updateGroupNameImage"
}

extension UserDefaults {
    static var loggedInUserId: String {
        get { return UserDefaults.standard.string(forKey: "userId") ?? ""}
        set(userId) {
            UserDefaults.standard.set(userId, forKey: "userId")
        }
    }

}
