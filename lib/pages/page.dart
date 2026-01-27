import 'package:flutter/material.dart';

class Page extends StatelessWidget {
  const Page({super.key, required this.content});

  final Widget content;

  @override
  Widget build(_) => Scaffold(resizeToAvoidBottomInset: false, body: Overlay.wrap(child: content));
}
