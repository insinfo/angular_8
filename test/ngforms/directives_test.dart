
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:ngdart/src/dependencies/ngforms/ngforms.dart';
import 'package:ngdart/src/dependencies/ngforms/src/directives/shared.dart';
import 'dart:html' as html;

class DummyControlValueAccessor implements ControlValueAccessor<dynamic> {
  dynamic writtenValue;

  @override
  void writeValue(dynamic obj) {
    writtenValue = obj;
  }

  @override
  void registerOnChange(fn) {}
  @override
  void registerOnTouched(fn) {}
  @override
  void onDisabledChanged(bool isDisabled) {}
}

class CustomValidatorDirective implements Validator {
  @override
  Map<String, dynamic> validate(AbstractControl c) {
    return {'custom': true};
  }
}

Matcher throwsWith(String s) =>
    throwsA(predicate((e) => e.toString().contains(s)));

Future<void> flushMicrotasks() async => await Future.microtask(() => null);

html.InputElement createHtmlElement(){
  return html.InputElement();
}
void main() {
  group('Shared selectValueAccessor', () {
    late DefaultValueAccessor defaultAccessor;
    setUp(() {
      defaultAccessor = DefaultValueAccessor(createHtmlElement());
    });
    test('should throw when given an empty array', () {
      expect(() => selectValueAccessor([]),
          throwsWith('No valid value accessor for'));
    });
    test('should return the default value accessor when no other provided', () {
      expect(selectValueAccessor([defaultAccessor]), defaultAccessor);
    });
    test('should return checkbox accessor when provided', () {
      var checkboxAccessor = CheckboxControlValueAccessor(createHtmlElement());
      expect(selectValueAccessor([defaultAccessor, checkboxAccessor]),
          checkboxAccessor);
    });
    test('should return select accessor when provided', () {
      var selectAccessor = SelectControlValueAccessor(createHtmlElement());
      expect(selectValueAccessor([defaultAccessor, selectAccessor]),
          selectAccessor);
    });
    test('should throw when more than one build-in accessor is provided', () {
      var checkboxAccessor = CheckboxControlValueAccessor(createHtmlElement());
      var selectAccessor = SelectControlValueAccessor(createHtmlElement());
      expect(() => selectValueAccessor([checkboxAccessor, selectAccessor]),
          throwsWith('More than one built-in value accessor matches'));
    });
    test('should return custom accessor when provided', () {
      var customAccessor = MockValueAccessor();
      var checkboxAccessor = CheckboxControlValueAccessor(createHtmlElement());
      expect(
          selectValueAccessor(
              [defaultAccessor, customAccessor, checkboxAccessor]),
          customAccessor);
    });
    test('should throw when more than one custom accessor is provided', () {
      ControlValueAccessor<dynamic> customAccessor = MockValueAccessor();
      expect(() => selectValueAccessor([customAccessor, customAccessor]),
          throwsWith('More than one custom value accessor matches'));
    });
  });
  group('Shared composeValidators', () {
    setUp(() {
      DefaultValueAccessor(createHtmlElement());
    });
    test('should compose functions', () {
      Map<String, dynamic> dummy1(_) => {'dummy1': true};
      Map<String, dynamic> dummy2(_) => {'dummy2': true};
      var v = composeValidators([dummy1, dummy2]);
      expect(v!(Control('')), {'dummy1': true, 'dummy2': true});
    });
    test('should compose validator directives', () {
      Map<String, dynamic> dummy1(_) => {'dummy1': true};
      var v = composeValidators([dummy1, CustomValidatorDirective()]);
      expect(v!(Control('')), {'dummy1': true, 'custom': true});
    });
  });
}

class MockValueAccessor extends Mock implements ControlValueAccessor<dynamic> {}
