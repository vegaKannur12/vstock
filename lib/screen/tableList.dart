import 'package:barcodescanner/barcode_dbhelper.dart';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableList extends StatefulWidget {
  final List<Map<String, dynamic>> list;
  TableList({required this.list});

  @override
  State<TableList> createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List Of tables")),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: ((context, index) {
          return ListTile(
            title: Text(widget.list[index]["name"]),
            onTap: () async {
              List<Map<String, dynamic>> list = await BarcodeScanlogDB.instance
                  .getTableData(widget.list[index]["name"]);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TableContent(
                          tableName: widget.list[index]["name"],
                          list: list,
                        )),
              );
            },
          );
        }),
      ),
    );
  }
}

/////////////////////////////////////////////
class TableContent extends StatefulWidget {
  String tableName;
  List<Map<String, dynamic>> list;
  TableContent({required this.tableName, required this.list});

  @override
  State<TableContent> createState() => _TableContentState();
}

class _TableContentState extends State<TableContent> {
  String searchkey = "";
  bool isSearch = false;
  String hinttext = "";
  List<Map<String, dynamic>>? newList = [];

  onChangedValue(String value) {
    newList!.clear();

    print("value inside function ---${value}");
    setState(() {
      searchkey = value;
      if (value.isEmpty) {
        isSearch = false;
      } else {
        isSearch = true;
        if (widget.tableName == "tableScanLog") {
          newList = widget.list
              .where((cat) =>
                  cat["barcode"].toUpperCase().contains(value.toUpperCase()))
              .toList();
        } else if (widget.tableName == "tableRegistration") {
          newList = widget.list
              .where((cat) => cat["company_name"]
                  .toUpperCase()
                  .contains(value.toUpperCase()))
              .toList();
        }
      }
    });
    print("new list---${newList}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.tableName == "tableScanLog") {
      hinttext = "search with barcode";
    } else if (widget.tableName == "tableRegistration") {
      hinttext = "search with company name";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Table Content---${widget.tableName}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 60,
              child: TextField(
                onChanged: (value) {
                  onChangedValue(value);
                },
                decoration: InputDecoration(
                  hintText: hinttext,
                  prefixIcon: Icon(Icons.search),
                  // suffix: ElevatedButton(child: Text("search"),
                  // onPressed: (){

                  // },)
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: isSearch ? newList!.length : widget.list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(isSearch
                      ? newList![index].toString()
                      : widget.list[index].toString()),
                );
              },
            ),
          ),
        ],
      ),
      // body:
      // SingleChildScrollView(

      // scrollDirection: Axis.horizontal,
      // child: DataTable(
      //   columns: [
      //     DataColumn(label: Text("id")),
      //     DataColumn(label: Text("barcode")),
      //     DataColumn(label: Text("time")),
      //     DataColumn(label: Text("qty")),
      //     DataColumn(label: Text("")),

      //     // DataColumn(label: Text("id")),
      //   ],
      //   rows: widget.list
      //       .map(
      //         (e) => DataRow(cells: [
      //           DataCell(Text(e["id"].toString())),
      //           DataCell(Text(e["barcode"].toString())),
      //           DataCell(Text(e["time"].toString())),
      //           DataCell(TextField()),
      //           // DataCell(Text(e["qty"].toString())),
      //           DataCell(Icon(Icons.delete)),
      //           // DataCell(TextField())

      //         ]),
      //       )
      //       .toList(),
      // ),
      // ),
    );
  }
}
