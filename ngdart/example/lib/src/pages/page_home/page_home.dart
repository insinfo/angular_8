import 'package:example/src/routes/my_routes.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';

@Component(
  selector: 'page-home',
  templateUrl: 'page_home.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
  exports: [
    MyRoutes,
  ],
)
class PageHome {}
