import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'split/split.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => SplitterMainMenu());
      case '/split' :
        return MaterialPageRoute(builder: (context) => SplitMain());
      default:
        return MaterialPageRoute(builder: (context) => SplitterMainMenu());
    }
  }
}