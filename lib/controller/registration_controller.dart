import 'dart:convert';
import 'package:barcodescanner/barcode_dbhelper.dart';
import 'package:barcodescanner/model/registration_model.dart';
import 'package:barcodescanner/screen/exterDir.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationController extends ChangeNotifier {
  ExternalDir externalDir = ExternalDir();
  String? comName;
  bool isLoading=false;
  Future<RegistrationModel?> postRegistration(
      String fingerprints,
      String company_code, String device_id, String app_id) async {
    try {
      print("divuxe-----$device_id");
      isLoading=true;
      notifyListeners();
      Uri url = Uri.parse("http://trafiqerp.in/ydx/send_regkey");
      Map<String, dynamic> body = {
        'company_code': company_code,
        // 'fcode': fingerprints,
        // 'deviceinfo': device_id,
        'device_id': device_id,
        'app_id': app_id,
      };
      http.Response response = await http.post(
        url,
        body: body,
      );
       isLoading=false;
      notifyListeners();
      var map = jsonDecode(response.body);
      print("from post data ${map}");
      print('user id------------${map["UserId"]}');
      RegistrationModel regModel = RegistrationModel.fromJson(map);
      comName=regModel.companyName;
      print("com---$comName");
      notifyListeners();

      // int uid = int.parse(map["UserId"].toString());
      // String fp=regModel.fp;
      //       await externalDir.fileWrite(fp!);

      var result = await BarcodeScanlogDB.instance.insertRegistrationDetails(
          company_code,
          device_id,
          "free to scan",
          regModel);
      // return regModel;
      notifyListeners();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
