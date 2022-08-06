import 'dart:async';
import 'dart:io';
import 'package:barcodescanner/components/shareFile.dart';
import 'package:barcodescanner/controller/provider_controller.dart';
import 'package:barcodescanner/screen/tableList.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:barcodescanner/barcode_dbhelper.dart';
import 'package:barcodescanner/screen/barcode_scan_scree.dart';
import 'package:barcodescanner/screen/createDir.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';

class BarcodeScanner extends StatefulWidget {
  // List<Map<String, dynamic>> queryresult;
  String type;
  // String? companyName;
  BarcodeScanner({
    required this.type,
    //  required this.queryresult
  });
  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  // List columnNames=[];
  TextEditingController _controllertext = TextEditingController();
  List<String> filepaths = [];
  String text = '';
  File? csvReslt;
  var updatedQty;
  ShareFilePgm shareFilePgm = ShareFilePgm();
  // late String attachment;
  late String appDocumentsPath;
  List<Map<String, dynamic>> data = [];
  late List<List<dynamic>> scan1;
  late List<List<dynamic>> scanResult;
  File? file;
//  final buffer = StringBuffer();
  CreateDir createdir = CreateDir();
  var flag = 0;
  // BarcodeScannerController barcodeController = BarcodeScannerController();
  StreamController<bool> controller = StreamController();
  String barcode = "No Data";
  // List<Map<String,dynamic>> queryresult;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scan1 = List<List<dynamic>>.empty(growable: true);
    var res = Provider.of<ProviderController>(context, listen: false)
        .getResultTableScanlog();
    // print("res-****${res}");
    // queryresult=await BarcodeScanlogDB.instance.queryAllRows();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: FutureBuilder<List<Map<String, dynamic>>>(
              future: BarcodeScanlogDB.instance.getCompanyDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                //  return Text(snapshot.data);
                return Text(snapshot.data![0]["company_name"]);
              }),

          // title: Text(widget.companyName != null ? widget.companyName.toString():"scanner"),
          actions: [
            // IconButton(
            //     onPressed: () {
            //       controller.add(true);
            //     },
            //     icon: Icon(Icons.refresh)),
            IconButton(
              onPressed: () async {
                List<Map<String, dynamic>> list =
                    await BarcodeScanlogDB.instance.getListOfTables();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TableList(list: list)),
                );
              },
              icon: Icon(Icons.table_bar),
            ),
            IconButton(
              onPressed: () {
                _showDialog(context, "all", 0);
              },
              icon: Icon(Icons.delete),
            ),
            // IconButton(
            //   onPressed: () {
            //    Provider.of<ProviderController>(context, listen: false).updateTableScanLog(updatedQty);
            //     // _showDialog(context);
            //   },
            //   icon: Icon(Icons.done),
            // ),
            PopupMenuButton(
              color: Color.fromARGB(255, 241, 235, 235),
              elevation: 20,
              enabled: true,
              onSelected: (value) async {
                // await createFolderInAppDocDir("csv");
                // print("attachment:${attachment}");
                // // print("attachment path:${attachment.path}");

                // setState(() {
                //   filepaths.add(attachment);
                // });

                shareFilePgm.onShareCsv(context, scan1, widget.type);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Share csv"),
                  value: "first",
                ),
              ],
            ),
            // PopupMenuButton(
            //   color: Color.fromARGB(255, 241, 235, 235),
            //   elevation: 20,
            //   enabled: true,
            //   onSelected: (value) async {
            //     attachment = await createFolderInAppDocDir("csv");
            //     final Email email = Email(
            //       body: 'Barcode result',
            //       subject: 'Barcode',
            //       // recipients: ['anugrahaamal9594@gmail.com'],
            //       attachmentPaths: ['${attachment}'],
            //       isHTML: false,
            //     );
            //     await FlutterEmailSender.send(email);
            //   },
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: Text("Share to mail"),
            //       value: "first",
            //     ),
            //   ],
            // ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BarcodeScannerScreen(
                            strcontroller: controller,
                            type: widget.type,
                          )),
                );
              },
              child: Icon(Icons.scanner),
            ),
          ],
        ),
        body: Consumer<ProviderController>(
          builder: (context, value, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                alignment:
                    widget.type == "Free Scan" || widget.type == "API Scan"
                        ? Alignment.center
                        : null,
                child: DataTable(
                  columnSpacing:
                      widget.type == "Free Scan" || widget.type == "API Scan"
                          ? 40
                          : 30,
                  columns: [
                    // DataColumn(label: Text("id")),
                    DataColumn(label: Text("barcode")),
                    DataColumn(label: Text("time")),
                    if (widget.type == "Free Scan with quantity" ||
                        widget.type == "API Scan with quantity")
                      DataColumn(label: Text("qty")),
                    DataColumn(label: Text("")),
                    // DataColumn(label: Text("")),

                    // DataColumn(label: Text("id")),
                  ],
                  rows: value.listResult
                      .map(
                        (e) => DataRow(cells: [
                          // DataCell(Text(e["id"].toString())),
                          DataCell(Text(e["barcode"].toString())),
                          DataCell(Text(e["time"].toString())),
                          // DataCell(TextField()),
                          // if (widget.type == "Free Scan" ||
                          //     widget.type == "API Scan")
                          //   DataCell(Text(e["qty"].toString())),

                          if (widget.type == "Free Scan with quantity" ||
                              widget.type == "API Scan with quantity")
                            DataCell(
                                TextFormField(
                                  // controller: _controllertext,
                                  // initialValue: "${e["qty"]}",
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: "1"),
                                  // onChanged: (value) {
                                  //   Provider.of<ProviderController>(context,
                                  //           listen: false)
                                  //       .setUpdatedQty(value);
                                  // },
                                  onFieldSubmitted: (val) {
                                    Provider.of<ProviderController>(context,
                                            listen: false)
                                        .updateTableScanLog(val, e["id"]);
                                    // Provider.of<ProviderController>(context,
                                    //         listen: false)
                                    //     .setUpdatedQty(val);
                                    // print('onSubmited $val');
                                  },
                                ),
                                showEditIcon: true),

                          DataCell(Container(
                            // width: 5,
                            child: IconButton(
                                onPressed: () {
                                  _showDialog(context, "single", e["id"]);
                                },
                                icon: Icon(Icons.delete)),
                          )),
                          // DataCell(Container(
                          //   // width: 5,
                          //   child: IconButton(
                          //       onPressed: () {
                          //         print("edit clicked");
                          //         updatedQty=Provider.of<ProviderController>(context,
                          //                 listen: false).updatedQty;
                          //         print('updatedQty $updatedQty');

                          //         Provider.of<ProviderController>(context,
                          //                 listen: false)
                          //             .updateTableScanLog(updatedQty,e["id"]);
                          //       },
                          //       icon: Icon(Icons.done),
                          //       color: Colors.green,
                          //       ),
                          // )),
                          // DataCell(TextField())
                        ]),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ));
  }

  //////////////////////////////////////////////////
  void _showDialog(BuildContext context, String type, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Are u sure! u want to delete?"),
          actions: <Widget>[
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('cancel')),
            ElevatedButton(
              child: new Text("OK"),
              onPressed: () {
                if (type == "all") {
                  Provider.of<ProviderController>(context, listen: false)
                      .deleteAllFromTableScanLog();
                } else if (type == "single") {
                  Provider.of<ProviderController>(context, listen: false)
                      .deleteFromTableScanlog(id);
                }

                // BarcodeScanlogDB.instance.deleteAllRows();
                // controller.add(true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ///////////////////////////////////////////////////////
  // Future<List<List>> getData() async {
  //   scan1.clear();
  //   print("after clear ----${scan1.length}");
  //   data = await BarcodeScanlogDB.instance.queryAllRows();
  //   // columnNames = await BarcodeScanlogDB.instance.getColumnnames();
  //   List<String> columnNames = ["Barcode", "Time"];
  //   scan1.add(columnNames);
  //   for (var i = 0; i < data.length; i++) {
  //     List<dynamic> row = List.empty(growable: true);
  //     row.add('${data[i]["barcode"]}');
  //     row.add('${data[i]["time"]}');
  //     scan1.add(row);
  //   }
  //   print("scan1 length--${scan1.length}");
  //   return scan1;
  // }

//////////////////////////////////////////////////////////////////
  // Future createFolderInAppDocDir(String folderName) async {
  //   String filePath;
  //   //Get this App Document Directory
  //   scanResult = await getData();
  //   final directory = await getExternalStorageDirectory();

  //   final Directory _appDocDir = await getApplicationDocumentsDirectory();
  //   if (await directory!.exists()) {
  //     appDocumentsPath = directory.path;
  //   } else {
  //     final Directory _appDocDirNewFolder =
  //         await directory.create(recursive: true);
  //     appDocumentsPath = _appDocDirNewFolder.path;
  //   }
  //   String csv =
  //       ListToCsvConverter(fieldDelimiter: ",", eol: "\n").convert(scanResult);
  //   File file =
  //       await File('${appDocumentsPath}/democopy.csv').create(recursive: true);
  //   // buffer.write(csv);
  //   // file.writeAsString(buffer.toString());
  //   file.writeAsString(csv);
  //   final contents = await file.readAsString();
  //   print("file content----${contents}");
  //   csvReslt = File('${directory.path}/democopy.csv');
  // }

  /////////////////////////////////////////////////////////////////////
  // void _onShareCsv(BuildContext context) async {
  //   filepaths.clear();
  //   print("after clear filepath length---${filepaths.length}");
  //   final box = context.findRenderObject() as RenderBox?;
  //   await createFolderInAppDocDir("csv");
  //   Directory? directory = await getExternalStorageDirectory();
  //   setState(() {
  //     filepaths.add(csvReslt!.path);
  //   });
  //   print("filepaths  length---${filepaths.length}");

  //   if (filepaths.isNotEmpty) {
  //     await Share.shareFiles(filepaths,
  //         text: null,
  //         subject: null,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   } else {
  //     await Share.share(text,
  //         subject: null,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   }
  // }
}
