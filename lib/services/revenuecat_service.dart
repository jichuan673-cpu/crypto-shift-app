import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

class RevenueCatService {
  // TODO: Replace with your actual RevenueCat Public SDK Keys
  static const String _appleApiKey = 'appl_api_key_placeholder';
  static const String _googleApiKey = 'goog_api_key_placeholder';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings;
      }
    } on PlatformException catch (e) {
      print('Error fetching offerings: ${e.message}');
    }
    return null;
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      // TODO: Replace 'premium' with your actual Entitlement ID set up in RevenueCat
      if (customerInfo.entitlements.all['premium']?.isActive == true) {
        return true;
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print('Purchase error: ${e.message}');
      }
    }
    return false;
  }

  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.all['premium']?.isActive == true) {
        return true;
      }
    } on PlatformException catch (e) {
      print('Restore error: ${e.message}');
    }
    return false;
  }

  static Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['premium']?.isActive == true;
    } on PlatformException catch (e) {
      print('Error checking status: ${e.message}');
    }
    return false;
  }
}
