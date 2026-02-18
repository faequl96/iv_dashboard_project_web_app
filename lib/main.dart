// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:iv_dashboard_project_web_app/app.dart';
import 'package:iv_dashboard_project_web_app/routes/router.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy();

  ApiUrl.set('https://02eb-175-103-42-210.ngrok-free.app');

  NavigationService.init(router);

  await StorageService.init();

  runApp(const App());
}
