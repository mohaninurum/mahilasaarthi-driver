import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahilasaarthi/requests/wallet.request.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import 'package:http/http.dart' as http;



class Phonepe {
  String environment = "UAT_SIM";
  String appId = "SALTINDEX 1";
  String transactionId = DateTime
      .now()
      .millisecondsSinceEpoch
      .toString();

  String merchantId = "MAHILASAARTHIONLINE";
  bool enableLogging = true;
  String checksum = "";
  String saltKey = "036f7d54-3d78-43b2-9514-1d1a6d0c600c";

  String saltIndex = "1";

  String callbackUrl =
      "https://webhook.site/f63d1195-f001-474d-acaa-f7bc4f3b20b1";

  String body = "";
  String apiEndPoint = "/pg/v1/pay";

  Object? result;

  getChecksum(amount) {
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": transactionId,
      "merchantUserId": "90223250",
      "amount": amount,
      "mobileNumber": "9999999999",
      "callbackUrl": callbackUrl,
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));

    checksum =
    '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey))
        .toString()}###$saltIndex';

    return base64Body;
  }

  void start(context,amount){


    phonepeInit();

    body = getChecksum(amount).toString();
    startPgTransaction(context,amount);

  }



  void phonepeInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) =>
    {

    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void startPgTransaction(context,amount) async {
    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          body, callbackUrl, checksum, {}, apiEndPoint, "");
      response
          .then((val)

      async
      {
        if (val != null) {
          String status = val['status'].toString();
          String error = val['error'].toString();

          if (status == 'SUCCESS') {
            result = "Flow complete - status : SUCCESS";

            await checkStatus(context,amount);
          } else {
            result =
            "Flow complete - status : $status and error $error";
          }
        } else {
          print("SLOW IN COMPLTEEE");
          result = "Flow Incomplete";
        }
      })
          .catchError((error) {
        handleError("error");
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError("error");
      handleError(error);
    }
  }

  void handleError(error) {
    result = {"error": error};
  }

  checkStatus(context,amount) async {
    try {
      String url =
          "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$transactionId"; //Test


      String concatenatedString =
          "/pg/v1/status/$merchantId/$transactionId$saltKey";

      var bytes = utf8.encode(concatenatedString);
      var digest = sha256.convert(bytes);
      String hashedString = digest.toString();

      //  combine with salt key
      String xVerify = "$hashedString###$saltIndex";

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "X-MERCHANT-ID": merchantId,
        "X-VERIFY": xVerify,
      };


      await http.get(Uri.parse(url), headers: headers).then((value) {
        Map<String, dynamic> res = jsonDecode(value.body);

        try {
          if (res["code"] == "PAYMENT_SUCCESS" &&
              res['data']['responseCode'] == "SUCCESS") {
            Fluttertoast.showToast(msg: res["message"]);
            WalletRequest().walletTopup(amount.toString(),);
            Navigator.pop(context);
            Navigator.pop(context);
          }else{
            Fluttertoast.showToast(msg:" Something went wrong");
            Navigator.pop(context);
            Navigator.pop(context);

          }
        } catch (e) {
          Fluttertoast.showToast(msg:" Something went wrong");
          Navigator.pop(context);
          Navigator.pop(context);

        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg:" Error");
    }
  }


}

