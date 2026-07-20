import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Viewitemsscreen extends StatefulWidget {
  String title;
  String image;
  int index;
  final VoidCallback? onDelete;
  Viewitemsscreen({
    super.key,
    required this.index,
    required this.title,
    required this.image,
    this.onDelete,
  });

  @override
  State<Viewitemsscreen> createState() => _ViewitemsscreenState();
}

class _ViewitemsscreenState extends State<Viewitemsscreen> {
  Future<void> deleteData() async {
    Navigator.pop(context);
    try {
      Response response = await Dio().delete(
        "https://flutterapitest-73108-default-rtdb.firebaseio.com/bucketlist/${widget.index}.json",
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onDelete?.call();
      }
    } catch (e) {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 1) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Delete the bucket data?"),
                      actions: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text("cancel"),
                        ),
                        InkWell(
                          onTap: deleteData,
                          child: Text("Confirm"),
                        ),
                      ],
                    );
                  },
                );
              }
              ;
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: 1, child: Text("delete")),
                PopupMenuItem(value: 2, child: Text("Mark as complete")),
              ];
            },
          ),
        ],
        title: Text("${widget.title}"),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.image),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
