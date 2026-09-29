// ///dev
// class ApiAppConstant {
//   static  String domain = 'https://prohealth-dev.symmetry.care/';
//   static const String authDomain = 'https://auth.symmetry.care/';
//   static  String clinicialBaseUrl = '${domain}api/';
//   static const String clinicialAuthBaseUrl = '${authDomain}api/';
//   static const googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";
//
//   static const int proHealth = 2;
//   static const int clinician = 1;
//   //  pass appType to get dynamic base URL
//   static String endPointByAlias(int appType,String aliasString) {
//     switch (appType) {
//       case clinician:
//         domain = "https://prohealth-dev.symmetry.care";
//         return "https://prohealth-dev.symmetry.care";
//       case proHealth:
//         domain = "https://prohealth-dev.symmetry.care";
//         return "https://prohealth-dev.symmetry.care";
//       default:
//         domain = "https://prohealth-dev.symmetry.care/";
//         return "https://prohealth-dev.symmetry.care/";
//     }
//   }
// }




///demo
class ApiAppConstant {
  static  String domain = 'https://greenvalley.symmetry.care/';
  static  String authDomain = 'http://32.199.183.39:3033/';
  static  String get clinicialBaseUrl => '${domain}api/';
  static  String get clinicialAuthBaseUrl => '${authDomain}api/';
  static  String googleApiKey = "AIzaSyCw6mXOPCtbKn5i0bWcAcnfXCkb0y5G7Lg";

  static const int proHealth = 2;
  static const int clinician = 1;
  //  pass appType to get dynamic base URL
  static String endPointByAlias(int appType,String aliasString) {
    switch (appType) {
      case clinician:
        domain = "https://$aliasString.symmetry.care";
        return "https://$aliasString.symmetry.care";
      case proHealth:
        domain = "https://$aliasString.symmetry.care";
        return "https://$aliasString.symmetry.care";
      default:
        domain = "https://$aliasString.symmetry.care/api/";
        return "https://$aliasString.symmetry.care/api/";
    }
  }
}


