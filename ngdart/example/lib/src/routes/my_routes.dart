import 'package:ngrouter/angular_router.dart';

import 'package:example/src/pages/page1/page1.template.dart' as page1_template;
import 'package:example/src/pages/page2/page2.template.dart' as page2_template;

import 'route_paths.dart';

class MyRoutes {
  static final page1 = RouteDefinition(
    routePath: RoutePaths.page1,
    component: page1_template.Page1NgFactory,
  );

  static final page2 = RouteDefinition(
    routePath: RoutePaths.page2,
    component: page2_template.Page2NgFactory,
  );

  static final public = <RouteDefinition>[page1, page2];
}
