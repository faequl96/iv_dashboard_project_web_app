// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:iv_dashboard_project_web_app/app.dart';
import 'package:iv_dashboard_project_web_app/routes/router.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();

  ApiUrl.set('https://995590782763.ngrok-free.app');

  NavigationService.init(router);

  runApp(const App());
}
