// import 'package:velocity_x/velocity_x.dart';

class Api {
  static String get baseUrl {
    return "https://mahila-sarthi.mytechbro.com/api";
    // return "http://192.168.10.6:8000/api";
    //   return "https://mahila.easysoft.pk/api";
  }

  static const driver_traininUri = "https://mahila-sarthi.mytechbro.com/driver_training_contents/";

  static const appSettings = "/app/settings";
  static const emergencyContacts = "/app/emergency-contacts";
  static const appOnboardings = "/app/onboarding?type=driver";
  static const faqs = "/app/faqs?type=driver";

  static const accountDelete = "/account/delete";
  static const login = "/login";
  static const newAccount = "/driver/register";
  static const qrlogin = "/login/qrcode";
  static const logout = "/logout";
  static const forgotPassword = "/password/reset/init";
  static const verifyPhoneAccount = "/verify/phone";
  static const updateProfile = "/profile/update";
  static const updatePassword = "/profile/password/update";
  static const myProfile = "/my/profile";
  //
  static const sendOtp = "/otp/send";
  static const verifyOtp = "/otp/verify";
  static const verifyFirebaseOtp = "/otp/firebase/verify";

  static const orders = "/orders";
  
  // Cashfree Verification
  static const generateAadhaarOtp = "/verify/aadhaar/generate-otp";
  static const verifyAadhaarOtp = "/verify/aadhaar/submit-otp";
  static const verifyFaceLiveness = "/verify/face-liveness";

  static const orderStopVerification = "/package/order/stop/verify";
  static const chat = "/chat/notification";

  //
  static const earning = "/earning/user";
  //
  //wallet
  static const walletBalance = "/wallet/balance";
  static const walletTopUp = "/wallet/topup";
  static const walletTransactions = "/wallet/transactions";
  static const transferWalletBalance = "/wallet/transfer";

  //Payment accounts
  static const paymentAccount = "/payment/accounts";
  static const payoutRequest = "/payouts/request";

  //Taxi booking
  static const currentTaxiBooking = "/taxi/current/order";
  static const cancelTaxiBooking = "/taxi/order/cancel";
  static const rejectTaxiBookingAssignment = "/taxi/order/asignment/reject";
  static const acceptTaxiBookingAssignment = "/taxi/order/asignment/accept";
  static const rating = "/rating";
  static const vehicleTypes = "/partner/vehicle/types";
  static const carMakes = "/partner/car/makes";
  static const carModels = "/partner/car/models";

  //driver type
  static const driverTypeSwitch = "/driver/type/switch";
  static const driverVehicleRegister = "/driver/vehicle/register";
  static const vehicles = "/driver/vehicles";
  static const activateVehicle = "/driver/vehicle/{id}/activate";
  //
  static const documentSubmission = "/driver/document/request/submission";

  // Other pages
  static String get privacyPolicy {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/privacy/policy";
  }

  static String get terms {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/terms";
  }

  //
  static String get register {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/register#driver";
  }

  static String get contactUs {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/contact";
  }

  static String get inappSupport {
    final webUrl = baseUrl.replaceAll('/api', '');
    return "$webUrl/pages/contact";
  }
}
