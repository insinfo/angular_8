import 'package:example/src/models/person.dart';
import 'package:example/src/services/fake_service.dart';
import 'package:ngdart/angular.dart';

import 'package:ngdart/ngrouter.dart';

@Component(
  selector: 'page2',
  templateUrl: 'page2.html',
  directives: [
    coreDirectives,
  ],
)
class Page2 implements OnInit, OnActivate {
  final FakePersonService _service;

  List<Person> people = [];

  Page2(this._service);

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState? previous, RouterState current) {
    people = _service.getAll();
  }
}
