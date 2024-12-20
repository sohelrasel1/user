// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool? createAccount;

  const PaymentWebViewScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.subscriptionUrl,
    this.storeId,
    this.createAccount = false,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  late String selectedUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if ((widget.addFundUrl?.isEmpty ?? true) &&
        (widget.subscriptionUrl?.isEmpty ?? true)) {
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if (widget.subscriptionUrl?.isNotEmpty ?? false) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _handlePaymentRedirect(url);
          },
          onNavigationRequest: (NavigationRequest request) async {
            Uri uri = Uri.parse(request.url);
            if (!["http", "https"].contains(uri.scheme)) {
              if (await canLaunch(request.url)) {
                await launch(request.url);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(selectedUrl));
  }

  void _handlePaymentRedirect(String url) {
    Get.find<OrderController>().paymentRedirect(
      url: url,
      canRedirect: true,
      onClose: () {},
      addFundUrl: widget.addFundUrl,
      orderID: widget.orderModel.id.toString(),
      contactNumber: widget.contactNumber,
      subscriptionUrl: widget.subscriptionUrl,
      storeId: widget.storeId,
      createAccount: widget.createAccount ?? false,
      guestId: widget.guestId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(
          title: '',
          onBackPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            } else {
              Navigator.pop(context);
            }
          },
          backButton: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
