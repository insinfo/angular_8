import 'package:example/src/app_component/app_component.dart';
import 'package:example/src/services/fake_service.dart';
import 'package:ngdart/angular.dart';
import 'package:example/src/app_component/app_component.template.dart' as ng;
import 'main.template.dart' as self;
import 'package:ngrouter/angular_router.dart';

final _fakePersonService =FakePersonService();
@GenerateInjector([
  routerProvidersHash,
  ClassProvider(FakePersonService),
 // FactoryProvider(FakePersonService, )
])
final InjectorFactory injector = self.injector$Injector;
void main() {
  runApp<AppComponent>(ng.AppComponentNgFactory, createInjector: injector);
}
