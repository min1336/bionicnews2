import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// 스토어에 등록한 상품 ID (실제 출시 시에는 자신의 ID로 변경해야 함)
const String _lifetimeProductId = 'focus_news_lifetime_premium';
const Set<String> _productIds = {_lifetimeProductId};

class IapService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // 구매 상태 변경을 감지하는 Stream
  final StreamController<PurchaseDetails> _purchaseUpdatedController =
  StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseUpdatedController.stream;

  // 결제 시스템 리스너 초기화
  void initialize() {
    _subscription = _inAppPurchase.purchaseStream.listen(
          (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // 에러 처리
        debugPrint("[IapService] Purchase Stream Error: $error");
      },
    );
  }

  // 스토어에서 상품 정보 불러오기
  Future<List<ProductDetails>> getProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint("[IapService] In-App Purchase is not available.");
      return [];
    }
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint("[IapService] Failed to load products: ${response.error}");
      return [];
    }
    return response.productDetails;
  }

  // 상품 구매 요청
  void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // 구매 결과 처리
  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // 구매 성공 또는 복원 성공
        _purchaseUpdatedController.add(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint("[IapService] Purchase Error: ${purchaseDetails.error}");
      }
      // 구매 완료/오류/취소 등 모든 경우에 대해 pendingCompletePurchase 처리를 해주어야 함
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // 구매 복원 요청
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void dispose() {
    _subscription.cancel();
    _purchaseUpdatedController.close();
  }
}