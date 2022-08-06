import 'package:barcodescanner/barcode_dbhelper.dart';
import 'package:barcodescanner/components/color_theme.dart';
import 'package:barcodescanner/screen/barcode_scanner.dart';
import 'package:flutter/material.dart';

class BarcodeType extends StatefulWidget {
  const BarcodeType({Key? key}) : super(key: key);

  @override
  State<BarcodeType> createState() => _BarcodeTypeState();
}

class _BarcodeTypeState extends State<BarcodeType> {
  List<String> types = [
    "Free Scan",
    "Free Scan with quantity",
    "API Scan",
    "API Scan with quantity"
  ];
  int? tappedIndex;
  late List<Map<String,dynamic>> queryresult;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Scan Type"),),
        body: ListView.builder(
            itemCount: types.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: tappedIndex == index
                        ? ColorThemeComponent.color1
                        : ColorThemeComponent.color2,
                  ),
                  child: ListTile(
                    onTap: () async{
                      setState(() {
                        tappedIndex = index;
                      });
                      // queryresult=await BarcodeScanlogDB.instance.queryAllRows();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarcodeScanner(type: types[index],
                        // queryresult: queryresult,
                        )),
                      );
                    },
                    title: Text(
                      types[index],
                      style: TextStyle(
                          // fontFamily: "fantasy",
                          fontSize: 20,
                          color:
                              tappedIndex == index ? ColorThemeComponent.color3 : ColorThemeComponent.color4),
                    ),
                  ),
                ),
              );
            })));
  }
}
