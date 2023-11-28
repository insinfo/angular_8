import 'package:analyzer/dart/element/element.dart';
import 'package:test/test.dart';
import 'package:ngdart/src/dependencies/ngcompiler/v1/angular_compiler.dart';

import '../src/resolve.dart';

void main() {
  group('should resolve', () {
    late LibraryElement testLib;

    setUpAll(() async {
      testLib = await resolveLibrary(r'''
        // class Directive2 {
        //   const Directive2();
        // }

        @Directive()
        class ADirective {}

        @Component()
        class AComponent {}

        @Injectable()
        class AnInjectable {}

        void hasInject(@Inject(#dep) List dep) {}

        void hasOptional(@Optional() List dep) {}

        void hasSelf(@Self() List dep) {}

        void hasSkipSelf(@SkipSelf() List dep) {}

        void hasHost(@Host() List dep) {}
      ''');

      print('testLib ');
    });

    test('@Directive', () {
      final aDirective = testLib.getClass('ADirective');
      print('aDirective: $aDirective');
      final res = $Directive.firstAnnotationOfExact(aDirective!);
      print('res: $res');
      expect(res, isNotNull);
    });

    // test('@Component', () {
    //   final aComponent = testLib.getClass('AComponent')!;
    //   expect($Component.firstAnnotationOfExact(aComponent), isNotNull);
    // });

    // test('@Injectable', () {
    //   final anInjectable = testLib.getClass('AnInjectable')!;
    //   expect($Injectable.firstAnnotationOfExact(anInjectable), isNotNull);
    // });

    // group('injection annotations', () {
    //   Element getParameterFrom(String name) =>
    //       testLib.definingCompilationUnit.functions
    //           .firstWhere((e) => e.name == name)
    //           .parameters
    //           .first;

    //   const {
    //     'hasHost': $Host,
    //     'hasInject': $Inject,
    //     'hasOptional': $Optional,
    //     'hasSelf': $Self,
    //     'hasSkipSelf': $SkipSelf,
    //   }.forEach((name, type) {
    //     test('of $type should find "$name"', () {
    //       final parameter = getParameterFrom(name);
    //       expect(type.firstAnnotationOfExact(parameter), isNotNull);
    //     });
    //   });
    // });
  });
}
