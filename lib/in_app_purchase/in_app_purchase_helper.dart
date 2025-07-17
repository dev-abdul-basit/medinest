import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// ignore: depend_on_referenced_packages, implementation_imports
import 'package:in_app_purchase_android/src/billing_client_wrappers/billing_client_wrapper.dart';

/// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:medinest/in_app_purchase/iap_callback.dart';
import 'package:medinest/utils/utils.dart';

import '../main.dart';
import '../utils/debug.dart';
import '../utils/preference.dart';
import 'iap_receipt_data.dart';

class InAppPurchaseHelper {
  static final InAppPurchaseHelper _inAppPurchaseHelper =
      InAppPurchaseHelper._internal();

  InAppPurchaseHelper._internal();

  factory InAppPurchaseHelper() {
    return _inAppPurchaseHelper;
  }

  static final List<String> _kProductIds = Platform.isIOS
      ? <String>[Utils.getProductId(), Utils.getIosProductId()]
      : <String>[Utils.getProductId()];

  final InAppPurchase _connection = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  List<PurchaseDetails> _purchases = [];
  IAPCallback? _iapCallback;

  initialize() {
    if (Platform.isAndroid) {
      /// ignore: deprecated_member_use
      InAppPurchaseAndroidPlatformAddition;
      // InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    } else {
      SKPaymentQueueWrapper().restoreTransactions();
    }
  }

  ProductDetails? getProductDetail(
    String productID, {
    required bool isMonthlySelected,
  }) {
    if (isMonthlySelected) {
      return products.last;
    } else {
      return products.first;
    }
    // for (ProductDetails item in products) {
    //   if (item.title == productID && isMonthlySelected) {
    //     Debug.printLog("item.id", item.price.toString());
    //     return item;
    //   }else {
    //     Debug.printLog("item.id", item.price.toString());
    //     return item;
    //   }
    // }
    // return null;
  }

  getAlreadyPurchaseItems(IAPCallback iapCallback) {
    _iapCallback = iapCallback;
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _connection.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        Debug.printLog(
          "purchaseDetailsList.isNotEmpty : ",
          purchaseDetailsList.isNotEmpty,
        );
        if (purchaseDetailsList != [] && purchaseDetailsList.isNotEmpty) {
          purchaseDetailsList.sort(
            (a, b) => a.transactionDate!.compareTo(b.transactionDate!),
          );

          if (purchaseDetailsList[0].status == PurchaseStatus.restored) {
            getPastPurchases(purchaseDetailsList);
          } else {
            _listenToPurchaseUpdated(purchaseDetailsList);
          }
        } else {
          getPastPurchases(purchaseDetailsList);
        }
      },
      cancelOnError: true,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        Debug.printLog("", error);
        handleError(error);
      },
    );
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    Debug.printLog("isAvailable : ", isAvailable.toString());
    if (!isAvailable) {
      products = [];
      _purchases = [];
      return;
    }

    ProductDetailsResponse productDetailResponse = await _connection
        .queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      products = productDetailResponse.productDetails;
      _purchases = [];
      Debug.printLog("Products1", products.toString());
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      products = productDetailResponse.productDetails;
      Debug.printLog("Products2", products.toString());
      _purchases = [];
      return;
    } else {
      products = productDetailResponse.productDetails;
      for (var product in products) {
        Debug.printLog("Products3", product.rawPrice);
      }
      _purchases = [];
    }
    await _connection.restorePurchases();
  }

  Future<void> getPastPurchases(List<PurchaseDetails> verifiedPurchases) async {
    verifiedPurchases.sort(
      (a, b) => a.transactionDate!.compareTo(b.transactionDate!),
    );

    if (Platform.isIOS) {
      if (verifiedPurchases.isNotEmpty) {
        await _verifyProductReceipts(verifiedPurchases);
      } else {
        Debug.printLog("", "You have not Purchased :::::::::::::::::::=>");
        Preference.shared.setIsPurchase(false);
        _iapCallback?.onBillingError(
          "You haven't purchase our product, so we can't restore.",
        );
      }
    }

    if (verifiedPurchases.isNotEmpty) {
      if (verifiedPurchases != [] && verifiedPurchases.isNotEmpty) {
        _purchases = verifiedPurchases;
        Debug.printLog("", "You have already Purchased :::::::::::::::::::=>");
        Preference.shared.setIsPurchase(true);

        for (var element in _purchases) {
          MyApp.purchaseStreamController.add(element);
          _iapCallback?.onSuccessPurchase(element);
        }
      } else {
        Debug.printLog("", "You have not Purchased :::::::::::::::::::=>");
        _iapCallback?.onBillingError(
          "You haven't purchase our product, so we can't restore.",
        );
        Preference.shared.setIsPurchase(false);
        _iapCallback?.onBillingError("");
      }
    } else {
      Debug.printLog("", "You have not Purchased :::::::::::::::::::=>");
      _iapCallback?.onBillingError(
        "You haven't purchase our product, so we can't restore.",
      );
      Preference.shared.setIsPurchase(false);
      _iapCallback?.onBillingError("");
    }
  }

  _verifyProductReceipts(List<PurchaseDetails> verifiedPurchases) async {
    var dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ),
    );

    Map<String, String> data = {};
    data.putIfAbsent(
      "receipt-data",
      () => verifiedPurchases[0].verificationData.localVerificationData,
    );

    try {
      String verifyReceiptUrl;

      if (Debug.sandboxVerifyRecieptUrl) {
        verifyReceiptUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
      } else {
        verifyReceiptUrl = 'https://buy.itunes.apple.com/verifyReceipt';
      }

      final graphResponse = await dio.post<String>(
        verifyReceiptUrl,
        data: data,
      );
      Map<String, dynamic> profile = jsonDecode(graphResponse.data!);

      var receiptData = IapReceiptData.fromJson(profile);

      if (receiptData.latestReceiptInfo != null) {
        receiptData.latestReceiptInfo!.sort(
          (a, b) => b.expiresDateMs!.compareTo(a.expiresDateMs!),
        );
        if (int.parse(receiptData.latestReceiptInfo![0].expiresDateMs!) >
            DateTime.now().millisecondsSinceEpoch) {
          for (PurchaseDetails data in verifiedPurchases) {
            if (data.productID == receiptData.latestReceiptInfo![0].productId) {
              _purchases.clear();
              _purchases.add(data);
              if (_purchases != [] && _purchases.isNotEmpty) {
                Preference.shared.setBool(Preference.isPurchasePremium, true);
                for (var element in _purchases) {
                  MyApp.purchaseStreamController.add(element);
                  _iapCallback?.onSuccessPurchase(element);
                }
              } else {
                Preference.shared.setBool(Preference.isPurchasePremium, false);
                _iapCallback?.onBillingError("");
              }
              Debug.printLog(
                "",
                "Already Purchased =======>${receiptData.latestReceiptInfo![0].toJson()}",
              );

              return;
            } else {
              Preference.shared.setBool(Preference.isPurchasePremium, false);
              _iapCallback?.onBillingError("");
            }

            if (data.pendingCompletePurchase) {
              await _connection.completePurchase(data);
            }
          }
        } else {
          Preference.shared.setIsPurchase(false);
          _iapCallback?.onBillingError("");
        }
      }
      // ignore: deprecated_member_use
    } on DioError catch (ex) {
      try {
        Preference.shared.setIsPurchase(false);
        _iapCallback?.onBillingError("");
        Debug.printLog("", "Verify Receipt =======> ${ex.response!.data}");
      } catch (e) {
        Preference.shared.setIsPurchase(false);
        _iapCallback?.onBillingError("");
        Debug.printLog("", e.toString());
      }
    }
  }

  Map<String, PurchaseDetails> getPurchases() {
    Map<String, PurchaseDetails> purchases = Map.fromEntries(
      _purchases.map((PurchaseDetails purchase) {
        if (purchase.pendingCompletePurchase) {
          _connection.completePurchase(purchase);
        }
        return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
      }),
    );
    return purchases;
  }

  finishTransaction() async {
    final transactions = await SKPaymentQueueWrapper().transactions();

    if (transactions != []) {
      for (final transaction in transactions) {
        try {
          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            await SKPaymentQueueWrapper().finishTransaction(
              transaction.originalTransaction!,
            );
          }
        } catch (e) {
          Debug.printLog("", e.toString());
          _iapCallback?.onBillingError(e);
        }
      }
    }
  }

  buySubscription(
    ProductDetails productDetails,
    Map<String, PurchaseDetails> purchases,
  ) async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();

      Debug.printLog("", transactions.toString());

      for (final transaction in transactions) {
        try {
          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            await SKPaymentQueueWrapper().finishTransaction(
              transaction.originalTransaction!,
            );
          }
        } catch (e) {
          _iapCallback?.onBillingError(e);
          Debug.printLog("", e.toString());
        }
      }

      final transaction = await SKPaymentQueueWrapper().transactions();

      Debug.printLog("", transaction.toString());

      for (final transaction in transaction) {
        try {
          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            await SKPaymentQueueWrapper().finishTransaction(
              transaction.originalTransaction!,
            );
          }
        } catch (e) {
          _iapCallback?.onBillingError(e);
          Debug.printLog("", e.toString());
        }
      }
    } else {
      if (Platform.isIOS) {
        _iapCallback?.onBillingError("");
      }
    }
    PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      final oldSubscription = _getOldSubscription(productDetails, purchases);

      purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
        changeSubscriptionParam: (oldSubscription != null)
            ? ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                replacementMode: ReplacementMode.chargeProratedPrice,
              )
            : null,
      );
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    }

    _connection.buyNonConsumable(purchaseParam: purchaseParam).catchError((
      error,
    ) async {
      handleError(error);
      Debug.printLog("", error.toString());
      return true;
    });
  }

  Future<void> clearTransactions() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
            await SKPaymentQueueWrapper().finishTransaction(
              transaction.originalTransaction!,
            );
          }
        } catch (e) {
          _iapCallback?.onBillingError(e);
          Debug.printLog("", e.toString());
        }
      }
    }
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    /// IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    _purchases.add(purchaseDetails);
    MyApp.purchaseStreamController.add(purchaseDetails);
    _iapCallback?.onSuccessPurchase(purchaseDetails);
  }

  void handleError(dynamic error) {
    _iapCallback?.onBillingError(error);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    /// IMPORTANT!! Always verify a purchase before delivering the product.
    /// For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    /// handle invalid purchase here if  _verifyPurchase` failed.
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    /// ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailsList.forEach((PurchaseDetails detailsPurchase) async {
      if (detailsPurchase.status == PurchaseStatus.pending) {
        _iapCallback?.onPending(detailsPurchase);
      } else {
        if (detailsPurchase.status == PurchaseStatus.error) {
          handleError(detailsPurchase.error);
        } else if (detailsPurchase.status == PurchaseStatus.restored) {
          getPastPurchases(purchaseDetailsList);
        } else if (detailsPurchase.status == PurchaseStatus.canceled) {
          _iapCallback?.onBillingError(detailsPurchase.error);
        } else if (detailsPurchase.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(detailsPurchase);
          if (valid) {
            deliverProduct(detailsPurchase);
          } else {
            _handleInvalidPurchase(detailsPurchase);
            return;
          }
        }

        if (detailsPurchase.pendingCompletePurchase) {
          await _connection.completePurchase(detailsPurchase);
          // finishTransaction();
        }
      }
    });
    await clearTransactions();
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
    ProductDetails productDetails,
    Map<String, PurchaseDetails> purchases,
  ) {
    return purchases[productDetails.id] as GooglePlayPurchaseDetails?;
  }
}
