import 'package:flutter/material.dart';

class Viewitemsscreen extends StatefulWidget {
  String title;
  String image;
  Viewitemsscreen({super.key, required this.title, required this.image});

  @override
  State<Viewitemsscreen> createState() => _ViewitemsscreenState();
}

class _ViewitemsscreenState extends State<Viewitemsscreen> {
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
                        InkWell(onTap: () {}, child: Text("Confirm")),
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
