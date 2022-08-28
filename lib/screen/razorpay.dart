import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPay extends StatefulWidget {
  const RazorPay({Key? key}) : super(key: key);

  @override
  State<RazorPay> createState() => _RazorPayState();
}

class _RazorPayState extends State<RazorPay> {

  TextEditingController pay = TextEditingController();
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Success!! $response");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Error: $response");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: $response");
  }

  String key = "";
  String secretKey = "";

  createOrderId(amount) async {
    final int Amount = int.parse(amount) * 100;
    http.Response response = await http.post(
        Uri.parse(
          "https://api.razorpay.com/v1/orders",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
          "Basic ${base64Encode(utf8.encode('$key:$secretKey'))} "
        },
        body: json.encode({
          "amount": Amount,
          "currency": "INR",
          "receipt": "OrderId_104",
        }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      openCheckout(amount, data["id"]);
    }
    print("Response"+response.body);
  }

  void openCheckout(amount, String orderId) async {
    final int Amount = int.parse(amount) * 100;

    var options = {
      'key': 'rzp_test_AWoXSYpqU2LzTC',
      'amount': Amount,
      'name': 'Name',
      'description': "test test",
      'order_id': orderId,
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: pay,
              decoration: InputDecoration(
                  label: Text("Amount"),
                  prefix: Text("₹ ",style: TextStyle(
                      color: Colors.blue
                  ),)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: GestureDetector(
              onTap: (){
                createOrderId(pay.text);
              },
              child: Container(
                height: 42.5,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5)
                ),
                alignment: Alignment.center,
                child: Text("Pay",style: TextStyle(
                    color: Colors.white
                ),),
              ),
            ),
          )
        ],
      ),
    );
  }
}
