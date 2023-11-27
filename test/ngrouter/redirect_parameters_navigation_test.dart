import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/src/dependencies/ngrouter/ngrouter.dart';
import 'package:ngdart/src/dependencies/ngrouter/testing.dart';
import 'package:ngdart/src/dependencies/ngtest/angular_test.dart';

import 'redirect_parameters_navigation_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('redirect should preserve parameters', () async {
    final urlChanges = await redirect('/from/1');
    expect(urlChanges, ['/to/1']);
  });

  test('redirect should discard extra parameters', () async {
    final urlChanges = await redirect('/from/1/2');
    expect(urlChanges, ['/to/1']);
  });
}

/// Performs a navigation that should be redirected.
/// Returns any URL changes that occurred due to navigation.
Future<List<String>> redirect(String from) async {
  final testBed =
      NgTestBed<TestRedirectComponent>(ng.createTestRedirectComponentFactory())
          .addInjector(injector);
  final testFixture = await testBed.create();
  final urlChanges = testFixture.assertOnlyInstance.locationStrategy.urlChanges;
  final router = testFixture.assertOnlyInstance.router;
  final result = await router.navigate(from);
  expect(result, NavigationResult.success);
  return urlChanges;
}

@GenerateInjector(routerProvidersTest)
InjectorFactory injector = ng.injector$Injector;

@Component(selector: 'to', template: '')
class ToComponent {}

@Component(
  selector: 'test',
  template: '<router-outlet [routes]="routes"></router-outlet>',
  directives: [RouterOutlet],
)
class TestRedirectComponent {
  static final routes = [
    RouteDefinition(path: '/to/:id', component: ng.createToComponentFactory()),
    RouteDefinition.redirect(path: '/from/:id', redirectTo: '/to/:id'),
    RouteDefinition.redirect(path: '/from/:id/:id2', redirectTo: '/to/:id'),
  ];

  final MockLocationStrategy locationStrategy;
  final Router router;

  TestRedirectComponent(
    @Inject(LocationStrategy) this.locationStrategy,
    this.router,
  );
}
