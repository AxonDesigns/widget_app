import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return ListView.builder(
          controller: scrollController,
          itemCount: 100,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Item $index"),
            );
          },
        );
      },
    );
  }
}
