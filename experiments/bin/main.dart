import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/experiments.dart';
import 'package:build_test/build_test.dart';
import 'package:package_config/package_config.dart';
import 'package:source_gen/source_gen.dart';

const angular = 'package:ngdart/angular.dart';

/// A custom package resolver for Angular sources.
///
/// This is needed to resolve sources that import Angular.
final packageConfigFuture = Platform
            .environment['ANGULAR_PACKAGE_CONFIG_PATH'] !=
        null
    ? loadPackageConfigUri(
        Uri.base.resolve(Platform.environment['ANGULAR_PACKAGE_CONFIG_PATH']!))
    : Isolate.packageConfig.then((uri) => loadPackageConfigUri(uri!));

/// Resolves [source] code as-if it is implemented with an AngularDart import.
///
/// Returns the resolved library as `package:test_lib/test_lib.dart`.
Future<LibraryElement> resolveLibrary(String source) async {
  final packageConfig = await packageConfigFuture;
  return withEnabledExperiments(
    () => resolveSource(
      '''
      library _test;
      import '$angular';\n\n$source
    ''',
      (resolver) async => (await resolver.findLibraryByName('_test'))!,
      inputId: AssetId('test_lib', 'lib/test_lib.dart'),
      packageConfig: packageConfig,
    ),
    ['non-nullable'],
  );
}

/// Resolves [source] code as-if it is implemented with an AngularDart import.
///
/// Returns first `class` in the file, or by [name] if given.
Future<ClassElement?> resolveClass(
  String source, [
  String? name,
]) async {
  final library = await resolveLibrary(source);
  return name != null
      ? library.getClass(name)
      : library.definingCompilationUnit.classes.first;
}

/// Most metadata is now in this sub-directory.
const _compilerMetadata = 'package:ngdart/src/meta';
const _directives = '$_compilerMetadata/directives.dart';
const _diArguments = '$_compilerMetadata/di_arguments.dart';
const _diGeneratedInjector = '$_compilerMetadata/di_generate_injector.dart';
const _diModules = '$_compilerMetadata/di_modules.dart';
const _diProviders = '$_compilerMetadata/di_providers.dart';
const _diTokens = '$_compilerMetadata/di_tokens.dart';
const _lifecycleHooks = '$_compilerMetadata/lifecycle_hooks.dart';
const _typed = '$_compilerMetadata/typed.dart';
const _changeDetectionLink = '$_compilerMetadata/change_detection_link.dart';

// Class metadata.
const $Directive = TypeChecker.fromUrl('$_directives#Directive');
const $Component = TypeChecker.fromUrl('$_directives#Component');
const $Injectable = TypeChecker.fromUrl('$_diArguments#Injectable');

void main(List<String> args) async {

  print('_directives $_directives ');
  final LibraryElement testLib = await resolveLibrary(r'''
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

  final aDirective = testLib.getClass('ADirective');
  print('aDirective: $aDirective');
  final res = $Directive.firstAnnotationOfExact(aDirective!);
  print('res: $res');
}
