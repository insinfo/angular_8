import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/src/dependencies/ngtest/angular_test.dart';

import 'bed_static_test.template.dart' as ng_generated;

void main() {
  test('should create a component with a ComponentFactory', () async {
    final testBed = NgTestBed<ExampleComp>(
      ng_generated.createExampleCompFactory(),
      rootInjector: mathInjector,
    );
    final NgTestFixture<ExampleComp> fixture = await testBed.create();
    expect(fixture.text, '0');
    await fixture.update((comp) => comp
      ..a = 1
      ..b = 2);
    expect(fixture.text, '3');
  });
}

@GenerateInjector([
  Provider(MathService),
])
final InjectorFactory mathInjector = ng_generated.mathInjector$Injector;

class MathService {
  num add(num a, num b) => a + b;
}

@Component(
  selector: 'example',
  template: '{{math.add(a, b)}}',
)
class ExampleComp {
  final MathService math;

  var a = 0;
  var b = 0;

  ExampleComp(this.math);
}
