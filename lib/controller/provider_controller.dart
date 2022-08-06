import 'dart:convert';

import 'package:barcodescanner/barcode_dbhelper.dart';
import 'package:barcodescanner/model/barcodescanner_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProviderController extends ChangeNotifier {
  String? updatedQty;
  Data? dataDetails;

  List<Map<String, dynamic>> listResult = [];
  ////////////////////////////////////////////////
  insertintoTableScanlog(String? _barcodeScanned, String? formattedDate,
      int count, int page_id, String type) async {
    print("enterd insertion section-----");
    var res = await BarcodeScanlogDB.instance.barcodeTimeStamp(
        _barcodeScanned, formattedDate, count, page_id, type, null);
    print("res----${res}");
    notifyListeners();
  }

  ////////////////////////////////////////////////
  getResultTableScanlog() async {
    print("entered fetching section---");
    listResult = await BarcodeScanlogDB.instance.queryAllRows();
    print("list reult from provider--${listResult}");
    notifyListeners();
  }

///////////////////////////////////////////////////
  deleteFromTableScanlog(int id) async {
    print("id --${id}");
    await BarcodeScanlogDB.instance.delete(id);
    listResult = await BarcodeScanlogDB.instance.queryAllRows();
    notifyListeners();
  }

  /////////////////////////////////////////
  updateTableScanLog(String updatedQty, int id) async {
    print("dfggf--$id---$updatedQty");
    if (updatedQty.isEmpty) {
      updatedQty = "1";
    }
    // print("null");
    var updatedQtyint = int.parse(updatedQty.toString());

    await BarcodeScanlogDB.instance.queryQtyUpdate(updatedQtyint, id);
    listResult = await BarcodeScanlogDB.instance.queryAllRows();
    print("after updation88${listResult}");
    notifyListeners();
  }

/////////////////////////////////////////////////
  deleteAllFromTableScanLog() async {
    await BarcodeScanlogDB.instance.deleteAllRowsTableScanLog();
    //  listResult.clear();
    listResult = await BarcodeScanlogDB.instance.queryAllRows();

    notifyListeners();
  }

  //////////////////////////////
  // setUpdatedQty(String value) {
  //   print('onSubmited $value');
  //   updatedQty = value;
  //   // notifyListeners();
  // }
  ///////////////////////////////////////////////////////////////////////////
  Future searchInTableScanLog(String barcode)async{
  bool search=  await BarcodeScanlogDB.instance.searchIn(barcode);
  print("search  ${search}");
  return search;
  notifyListeners();
  }
  /////////////////////////////////////////////////////////////////////////
  Future postData(String barcode, String? formattedDate, BuildContext context,
      int qty, int page_id, String type) async {
    try {
      Uri url = Uri.parse("https://aiwasilks.in/reports/check_barcode.php");
      Map<String, dynamic> body = {'barcode': barcode};

      http.Response response = await http.post(
        url,
        body: body,
      );
      var map = jsonDecode(response.body);
      print("from post data ${map}");
      BarcodeScannerModel barcodeModel = BarcodeScannerModel.fromJson(map);

      if (barcodeModel.data!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 143, 17, 8),
            duration: const Duration(seconds: 1),
            content: Text('Wrong code!!!!'),
            action: SnackBarAction(
              label: 'Dissmiss',
              textColor: Colors.yellow,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      for (var item in barcodeModel.data!) {
        dataDetails = Data(
            barcode: item.barcode,
            brand: item.brand,
            model: item.model,
            size: item.size,
            description: item.description,
            rate: item.rate,
            product: item.product);
        var res = await BarcodeScanlogDB.instance
            .barcodeTimeStamp(null, formattedDate, qty, 1, type, dataDetails);
      }
      return barcodeModel.data;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
