import 'package:async/async.dart' show StreamGroup;
import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/src/dependencies/ngrouter/ngrouter.dart';
import 'package:ngdart/src/dependencies/ngrouter/testing.dart';
import 'package:ngdart/src/dependencies/ngtest/angular_test.dart';

// ingore: uri_has_not_been_generated
import 'on_navigation_start_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  group('Router.onNavigationStart', () {
    test('fires on navigation', () async {
      final testBed = NgTestBed<TestComponent>(
        ng.createTestComponentFactory(),
      );
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emitsInOrder([
          '/destination', // Router.onNavigationStart,
          NavigationResult.success,
        ]),
      );
    });

    test("doesn't fire when navigation is prohibited", () async {
      final testBed = NgTestBed<TestComponent>(
        ng.createTestComponentFactory(),
      ).addInjector((i) => Injector.map({canNavigateToken: false}, i));
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emits(NavigationResult.blockedByGuard),
      );
    });

    test('fires when deactivation is prohibited', () async {
      final testBed = NgTestBed<TestComponent>(
        ng.createTestComponentFactory(),
      ).addInjector((i) => Injector.map({canDeactivateToken: false}, i));
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emitsInOrder([
          '/destination', // Router.onNavigationStart
          NavigationResult.blockedByGuard,
        ]),
      );
    });

    test('fires only once on redirect', () async {
      final testBed = NgTestBed<TestComponent>(
        ng.createTestComponentFactory(),
      );
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/redirection'),
        emitsInOrder([
          '/redirection', // Router.onNavigationStart
          NavigationResult.success,
        ]),
      );
    });
  });
}

Stream<dynamic> navigate(Router router, String path) => StreamGroup.merge([
      router.onNavigationStart,
      router.navigate(path).asStream(),
    ]);

const canDeactivateToken = OpaqueToken<bool>('canDeactivateToken');
const canNavigateToken = OpaqueToken<bool>('canNavigateToken');

@Component(
  selector: 'home',
  template: '',
)
class HomeComponent implements CanDeactivate, CanNavigate {
  final bool _canDeactivate;
  final bool _canNavigate;

  HomeComponent(
    @Optional() @Inject(canDeactivateToken) bool? canDeactivate,
    @Optional() @Inject(canNavigateToken) bool? canNavigate,
  )   : _canDeactivate = canDeactivate ?? true,
        _canNavigate = canNavigate ?? true;

  @override
  Future<bool> canDeactivate(_, __) => Future.value(_canDeactivate);

  @override
  Future<bool> canNavigate() => Future.value(_canNavigate);
}

@Component(
  selector: 'destination',
  template: '',
)
class DestinationComponent {}

@Component(
  selector: 'test',
  template: '<router-outlet [routes]="routes"></router-outlet>',
  directives: [RouterOutlet],
  providers: [routerProvidersTest],
)
class TestComponent {
  final Router router;
  final List<RouteDefinition> routes = [
    RouteDefinition(
      path: 'home',
      component: ng.createHomeComponentFactory(),
      useAsDefault: true,
    ),
    RouteDefinition(
      path: 'destination',
      component: ng.createDestinationComponentFactory(),
    ),
    RouteDefinition.redirect(
      path: 'redirection',
      redirectTo: 'destination',
    ),
  ];

  TestComponent(this.router);
}
