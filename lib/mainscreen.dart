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

  String searchQuery = "";
  String sortBy = "none";
  int? minCost;
  int? maxCost;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minCostController = TextEditingController();
  final TextEditingController maxCostController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    minCostController.dispose();
    maxCostController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
      searchQuery = "";
      sortBy = "none";
      minCost = null;
      maxCost = null;
      isSearching = false;
      searchController.clear();
      minCostController.clear();
      maxCostController.clear();
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

  List<dynamic> get filteredData {
    final data = bucketListData.where((item) {
      if (item is! Map) return false;
      final name = (item['item'] ?? "").toString().toLowerCase();
      final cost = item['cost'] ?? 0;
      if (searchQuery.isNotEmpty &&
          !name.contains(searchQuery.toLowerCase())) {
        return false;
      }
      if (minCost != null && cost < minCost!) return false;
      if (maxCost != null && cost > maxCost!) return false;
      return true;
    }).toList();

    if (sortBy == "asc") {
      data.sort((a, b) => (a['cost'] ?? 0).compareTo(b['cost'] ?? 0));
    } else if (sortBy == "desc") {
      data.sort((a, b) => (b['cost'] ?? 0).compareTo(a['cost'] ?? 0));
    }

    return data;
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

  Widget listDataWidget() {
    final list = filteredData;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        final item = list[index];
        if (item is! Map) return SizedBox();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Viewitemsscreen(
                      index: index,
                      title: item['item'] ?? "",
                      image: item['image'] ?? "",
                      onDelete: getData,
                    );
                  },
                ),
              );
            },
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(item['image'] ?? ""),
            ),
            title: Text(item['item'] ?? ""),
            trailing: Text((item['cost'] ?? 0).toString()),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Sort by cost"),
                  DropdownButton<String>(
                    value: sortBy,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: "none", child: Text("None")),
                      DropdownMenuItem(
                        value: "asc",
                        child: Text("Cost: Low to High"),
                      ),
                      DropdownMenuItem(
                        value: "desc",
                        child: Text("Cost: High to Low"),
                      ),
                    ],
                    onChanged: (value) {
                      setSheetState(() => sortBy = value ?? "none");
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: minCostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Min cost",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      minCost = int.tryParse(value);
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: maxCostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Max cost",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      maxCost = int.tryParse(value);
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            sortBy = "none";
                            minCostController.clear();
                            maxCostController.clear();
                          });
                          setState(() {
                            sortBy = "none";
                            minCost = null;
                            maxCost = null;
                          });
                        },
                        child: Text("Clear"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text("Done"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        searchQuery.isNotEmpty ||
        sortBy != "none" ||
        minCost != null ||
        maxCost != null;
    final filteredList = filteredData;

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
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search items...",
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              )
            : Text("Bucket list"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = "";
                  searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: hasActiveFilters ? Colors.yellow : null,
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: getData),
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
            : bucketListData.isEmpty
            ? Center(child: Text("No data Available"))
            : filteredList.isEmpty
            ? Center(child: Text("No items match your filters"))
            : listDataWidget(),
      ),
    );
  }
}
