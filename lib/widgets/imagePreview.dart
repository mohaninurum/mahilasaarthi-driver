import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
   ImagePreview({super.key,required this.uri});
String uri;
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
     return new Scaffold(
      body: new Image.network(
        widget.uri,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
