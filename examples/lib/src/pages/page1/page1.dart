import 'package:example/src/models/person.dart';
import 'package:example/src/routes/my_routes.dart';
import 'package:example/src/services/fake_service.dart';
import 'package:ngdart/angular.dart';

import 'package:ngdart/ngforms.dart';
import 'package:ngdart/ngrouter.dart';

@Component(
  selector: 'page1',
  templateUrl: 'page1.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
)
class Page1 {
  final FakePersonService _service;
  final Router _router;

  Person person = Person.getNew();

  Page1(this._service, this._router);

  void save() {
    _service.add(person);
    _router.navigate(MyRoutes.page2.toUrl());
  }
}
