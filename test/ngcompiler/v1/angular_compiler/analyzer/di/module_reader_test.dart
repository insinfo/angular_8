import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:test/test.dart';
import 'package:ngdart/src/dependencies/ngcompiler/v1/angular_compiler.dart';

import '../../src/resolve.dart';

void main() {
  group('ModuleReader', () {
    const reader = ModuleReader();

    late ClassElement $Example;
    late ClassElement $Dependency;
    late DartObject $listModule;
    late DartObject $newModuleA;
    late DartObject $newModuleB;
    late DartObject $newModuleC;

    setUpAll(() async {
      final testLib = await resolveLibrary(r'''
        // @dart=2.9
        @listModule
        @newModuleA
        @newModuleB
        @newModuleC
        @Injectable()
        class Example {}

        class ExamplePrime extends Example {}

        class Dependency {}

        const listModule = const [
          Example,
          newModuleA,
        ];

        const newModuleA = const Module(
          provide: const [
            Dependency
          ],
        );

        const newModuleB = const Module(
          include: const [
            newModuleA,
          ],

          provide: const [
            Example,
          ],
        );

        const newModuleC = const Module(
          include: const [
            newModuleB,
          ],

          provide: const [
            const Provider(Example, useClass: ExamplePrime),
          ],
        );
      ''');
      $Example = testLib.getClass('Example')!;
      $Dependency = testLib.getClass('Dependency')!;
      $listModule = $Example.metadata.first.computeConstantValue()!;
      $newModuleA = $Example.metadata[1].computeConstantValue()!;
      $newModuleB = $Example.metadata[2].computeConstantValue()!;
      $newModuleC = $Example.metadata[3].computeConstantValue()!;
    });

    group('should parse module', () {
      test('from a list (implicit module)', () {
        expect(
          reader.parseModule($listModule),
          ModuleElement(provide: [
            UseClassProviderElement(
              TypeTokenElement(linkTypeOf($Example.thisType)),
              null,
              linkTypeOf($Example.thisType),
              dependencies: DependencyInvocation(
                $Example.unnamedConstructor!,
                const [],
              ),
            )
          ], include: [
            ModuleElement(
              provide: [
                UseClassProviderElement(
                  TypeTokenElement(linkTypeOf($Dependency.thisType)),
                  null,
                  linkTypeOf($Dependency.thisType),
                  dependencies: DependencyInvocation(
                    $Dependency.unnamedConstructor!,
                    const [],
                  ),
                )
              ],
              include: [],
            )
          ]),
        );
      });

      group('using the new "Module" syntax', () {
        test('with just "provide"', () {
          expect(
            reader.parseModule($newModuleA),
            ModuleElement(
              provide: [
                UseClassProviderElement(
                  TypeTokenElement(linkTypeOf($Dependency.thisType)),
                  null,
                  linkTypeOf($Dependency.thisType),
                  dependencies: DependencyInvocation(
                    $Dependency.unnamedConstructor!,
                    const [],
                  ),
                )
              ],
              include: [],
            ),
          );
        });

        test('with both "provide" and "include"', () {
          final module = reader.parseModule($newModuleB);

          // Purposefully not de-duplicated, tooling might want to know.
          expect(
            module,
            ModuleElement(
              provide: [
                UseClassProviderElement(
                  TypeTokenElement(linkTypeOf($Example.thisType)),
                  null,
                  linkTypeOf($Example.thisType),
                  dependencies: DependencyInvocation(
                    $Example.unnamedConstructor!,
                    const [],
                  ),
                )
              ],
              include: [
                ModuleElement(
                  provide: [
                    UseClassProviderElement(
                      TypeTokenElement(linkTypeOf($Dependency.thisType)),
                      null,
                      linkTypeOf($Dependency.thisType),
                      dependencies: DependencyInvocation(
                        $Dependency.unnamedConstructor!,
                        const [],
                      ),
                    )
                  ],
                  include: [],
                )
              ],
            ),
          );
        });
      });

      test('should deduplicate Providers with matching tokens', () {
        final module = reader.parseModule($newModuleC);
        final providers = module.flatten();

        expect(providers, hasLength(3));
        expect(reader.deduplicateProviders(providers), hasLength(2));
      });
    });
  });

  group('ModuleReader.extractProviderObjects', () {
    // These are tests for functionality used by the view compiler.
    final extractProviderObjects = const ModuleReader().extractProviderObjects;
    String extractProviderStrings(DartObject value) {
      final result = extractProviderObjects(value);
      return result.map((o) {
        var value = o.toTypeValue();
        if (value != null) {
          return value.name;
        }
        return o.getField('token')!.toTypeValue()!.name;
      }).join(', ');
    }

    late DartObject aListOfProviders;
    late DartObject aModuleOfProviders;
    late DartObject nestedListsAndModules;

    setUpAll(() async {
      final testLib = await resolveLibrary(r'''
        // @dart=2.9
        @aListOfProviders
        @aModuleOfProviders
        @nestedListsAndModules
        class Example {}

        const aListOfProviders = const [
          A,
          const Provider(B),
          const Provider(C, useClass: C),
        ];

        const aModuleOfProviders = const Module(
          include: const [_aSubModule],
          provide: const [
            const Provider(A),
            const Provider(B),
          ],
        );

        const _aSubModule = const Module(
          provide: const [
            const Provider(C),
          ],
        );

        const nestedListsAndModules = const [
          const [
            aListOfProviders,
            const [
              aModuleOfProviders,
            ],
          ],
        ];

        class A {}
        class B {}
        class C {}
      ''');
      final testObjects = List<DartObject>.from(testLib
          .getClass('Example')!
          .metadata
          .map((e) => e.computeConstantValue()));
      aListOfProviders = testObjects[0];
      aModuleOfProviders = testObjects[1];
      nestedListsAndModules = testObjects[2];
    });

    test('should read a list of providers', () {
      expect(
        extractProviderStrings(aListOfProviders),
        'A, B, C',
      );
    });

    test('should read a module of providers', () {
      expect(
        extractProviderStrings(aModuleOfProviders),
        'C, A, B',
      );
    });

    test('should read a combination of lists and modules', () {
      expect(
        extractProviderStrings(nestedListsAndModules),
        'A, B, C, C, A, B',
      );
    });
  });
}
