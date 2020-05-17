import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:VendorApp/razorpay/paymentFailed.dart';
import 'package:VendorApp/razorpay/paymentSuccess.dart';
import 'razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Razorpay _razorpay = Razorpay();
//  OrderId _orderId;
  double cartTotal = 1000;
  var options;
  String keyId = 'rzp_test_UBTFXZ8gM6iEeZ';
  String keyValue = 'Vpb6hVZtCBcrLpsY0UD26B4g';

  Future payData() async {

    try {
      _razorpay.open(options);
    } catch (e) {
      print("errror occured here is ......................./:$e");
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void capturePayment(PaymentSuccessResponse response) async{
    String apiUrl = 'https://$keyId:$keyValue@api.razorpay.com/v1/payments/${response.paymentId}/capture';
    final http.Response response2 = await http.post(apiUrl, headers: <String,String>{
      'Content-Type' : 'application/json'
    },body: jsonEncode(<dynamic,dynamic>{
        "amount": cartTotal,
        "currency": "INR",
    }),
    );
    if(response2.statusCode == 200){
      log('Payment is captured');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("payment has succedded");
    capturePayment(response);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SuccessPage(
          response: response,
        ),
      ),
          (Route<dynamic> route) => false,
    );
    _razorpay.clear();
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("payment has error00000000000000000000000000000000000000");
    // Do something when payment fails
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => FailedPage(
          response: response,
        ),
      ),
          (Route<dynamic> route) => false,
    );
    _razorpay.clear();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("payment has externalWallet33333333333333333333333333");

    _razorpay.clear();
    // Do something when an external wallet is selected
  }

  @override
  void initState() {
    super.initState();

    options = {
      'key': '$keyId', // Enter the Key ID generated from the Dashboard

      'amount': '$cartTotal', //in the smallest currency sub-unit.
      'name': 'E-Grocery',
      'currency': "INR",
      //"order_id": '${_OrderId.id}',
      'theme.color': '#E5126D',
      'buttontext': "E-Grocery",
      'description': 'DevUP',
      'prefill': {
        'contact': '',
        'email': '',
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // print("razor runtime --------: ${_razorpay.runtimeType}");
    return Scaffold(
      body: FutureBuilder(
          future: payData(),
          builder: (context, snapshot) {
            return Container(
              child: Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
