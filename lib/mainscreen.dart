import 'package:bucketlist_app/addbucketlist.dart';
import 'package:bucketlist_app/viewitems.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> bucketListData = [];
  bool isLoading = false;
  bool isError = false;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await Dio().get(
        "https://flutterapitest-73108-default-rtdb.firebaseio.com/bucketlist.json",
      );

      if (response.data is List) {
        bucketListData = response.data;
      } else {
        bucketListData = [];
      }

      isLoading = false;
      isError = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      isError = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Widget errorWidget({required String errorText}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning),
          Text(errorText),
          ElevatedButton(onPressed: getData, child: Text("Try again")),
        ],
      ),
    );
  }

  Widget ListDataWidget() {
    return ListView.builder(
      itemCount: bucketListData.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: (bucketListData[index] is Map)
              ? ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Viewitemsscreen(
                            title: bucketListData[index]['item'] ?? "",
                            image: bucketListData[index]['image'] ?? "",
                          );
                        },
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      bucketListData[index]?['image'] ?? "",
                    ),
                  ),
                  title: Text(bucketListData[index]?['item'] ?? ""),
                  trailing: Text(
                    bucketListData[index]?['cost'].toString() ?? "",
                  ),
                )
              : SizedBox(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Addbucketlistscreen();
              },
            ),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),

      appBar: AppBar(
        title: Text("Bucket list"),
        actions: [
          InkWell(
            onTap: getData,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : isError
            ? errorWidget(errorText: "Error connecting...")
            : bucketListData.length < 1
            ? Center(child: Text("No data Available"))
            : ListDataWidget(),
      ),
    );
  }
}
