import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngdart/src/dependencies/ngforms/ngforms.dart';
import 'package:ngdart/src/dependencies/ngtest/angular_test.dart';

import 'accessor_test.template.dart' as ng;

void main() {
  group('accessor test', () {
    tearDown(disposeAnyRunningTest);

    test('should have error on invalid input', () async {
      NgTestFixture<AccessorTestComponent> fixture =
          await NgTestBed<AccessorTestComponent>(
                  ng.createAccessorTestComponentFactory())
              .create();

      await fixture.update((AccessorTestComponent c) {
        var model = c.model!;
        (model.valueAccessor as IntValueAccessor).onChange('aaa');

        expect(model.value, null);
        expect(model.control.rawValue, 'aaa');
        expect(model.control.errors!.values.single, 'aaa');
        expect(model.control.errors!.keys.single, 'int-error');
      });
    });

    test('shouldn\'t have error on valid input', () async {
      NgTestFixture<AccessorTestComponent> fixture =
          await NgTestBed<AccessorTestComponent>(
                  ng.createAccessorTestComponentFactory())
              .create();

      await fixture.update((AccessorTestComponent c) {
        var model = c.model!;
        (model.valueAccessor as IntValueAccessor).onChange('5');

        expect(c.value, 5);
        expect(model.value, 5);
        expect(model.control.rawValue, '5');
        expect(model.control.errors, null,
            reason: 'Valid value should not have an error');
      });
    });
  });
}

@Component(
  selector: 'accessor-test',
  template: '<input type="text" integer [(ngModel)]="value">',
  directives: [IntValueAccessor, NgModel],
)
class AccessorTestComponent {
  @ViewChild(NgModel)
  NgModel? model;
  int? value = 1;
}

typedef ChangeFunctionSimple = dynamic Function(dynamic value);

@Directive(
  selector: 'input[integer]',
  providers: [
    ExistingProvider.forToken(ngValueAccessor, IntValueAccessor),
    ExistingProvider.forToken(ngValidators, IntValueAccessor),
  ],
)
class IntValueAccessor implements ControlValueAccessor<dynamic>, Validator {
  final HtmlElement _elementRef;

  @HostListener('input')
  void onChangeBinding() => onChange(null);

  // ignore: prefer_function_declarations_over_variables
  ChangeFunctionSimple onChange = (_) {};

  @HostListener('blur')
  void touchHandler() {
    onTouched();
  }

  // ignore: prefer_function_declarations_over_variables
  TouchFunction onTouched = () {};

  IntValueAccessor(this._elementRef);

  @override
  void writeValue(dynamic value) {
    var normalizedValue = value!.toString();
    js_util.setProperty(_elementRef, 'value', normalizedValue);
  }

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    onChange = (input) {
      final value = input as String;
      final result = int.tryParse(value);
      fn(result, rawValue: value);
    };
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  @override
  Map<String, dynamic>? validate(AbstractControl c) {
    if (c is Control && c.value == null && c.rawValue != null) {
      // We couldn't parse the input there must have been an error
      return {'int-error': c.rawValue};
    }
    return null;
  }

  @override
  void onDisabledChanged(bool isDisabled) {}
}
