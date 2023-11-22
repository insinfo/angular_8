import 'package:example/src/pages/page_home/page_home.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'app',
  templateUrl: 'app_component.html',
  directives: [
    PageHome,
  ],
)
class AppComponent {}
