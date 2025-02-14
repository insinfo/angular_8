import 'package:ngdart/src/meta.dart';
import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/identifiers.dart';
import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/output/output_ast.dart' as o;
import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/view_type.dart';

import 'compile_view.dart';

void initStyleEncapsulation(CompileView view, o.ClassStmt viewClass) {
  // Only component views initialize styles; embedded views inherit them from
  // their parent, and host views have none.
  if (view.viewType == ViewType.component) {
    _ViewStyleLinker(view, viewClass).initStyleEncapsulation();
  }
}

class _ViewStyleLinker {
  static const _initComponentStyles = 'initComponentStyles';
  static const _debugClearComponentStyles = '_debugClearComponentStyles';
  static const _debugComponentUrl = '_debugComponentUrl';
  static const _componentStylesStatic = '_componentStyles';
  static const _componentStylesMember = 'componentStyles';

  final CompileView _view;
  final o.ClassStmt _class;

  const _ViewStyleLinker(this._view, this._class);

  bool get _hasScopedStyles =>
      _view.component.template!.encapsulation == ViewEncapsulation.emulated;

  o.ExternalExpr get _styleType => o.importExpr(_hasScopedStyles
      ? StyleEncapsulation.componentStylesScoped
      : StyleEncapsulation.componentStylesUnscoped);

  void initStyleEncapsulation() {
    // We need to call initComponentStyles() before we handle any constant
    // bindings, which may attempt to update styles in the constructor body.
    // As an easy hack to ensure this, we just insert this call at the beginning
    // of the constructor body.
    _class.constructorMethod!.body.insert(
      0,
      o.InvokeMemberMethodExpr(_initComponentStyles, const []).toStmt(),
    );
    _addStaticDebugUrlGetter();
    _addStaticComponentStylesField();
    _implementDebugClearComponentStyles();
    _implementInitComponentStyles();
  }

  void _addStaticDebugUrlGetter() {
    _class.getters.add(
      o.ClassGetter(
        _debugComponentUrl,
        [
          o.ReturnStatement(
            o.ConditionalExpr(
              o.importExpr(Runtime.isDevMode),
              o.literal(_view.component.type.moduleUrl),
              o.nullExpr,
            ),
          ),
        ],
        o.BuiltinType(
            o.BuiltinTypeName.stringName, [o.TypeModifier.nullableModifier]),
        [
          o.StmtModifier.staticStmt,
        ],
      ),
    );
  }

  static final _componentStyles = o.ClassField(
    _componentStylesStatic,
    outputType: o.importType(
      StyleEncapsulation.componentStyles,
      [],
      [o.TypeModifier.nullableModifier],
    ),
    modifiers: const [o.StmtModifier.staticStmt],
  );

  void _addStaticComponentStylesField() {
    _class.fields.add(_componentStyles);
  }

  void _implementDebugClearComponentStyles() {
    // Static._componentStyles = null
    final nullifyStaticComponentStyles =
        o.WriteStaticMemberExpr(_componentStylesStatic, o.nullExpr).toStmt();
    _class.methods.add(
      o.ClassMethod(
        _debugClearComponentStyles,
        const [],
        [
          nullifyStaticComponentStyles,
        ],
        o.voidType,
        const [o.StmtModifier.staticStmt],
      ),
    );
  }

  void _implementInitComponentStyles() {
    final staticCacheField = o.ReadStaticMemberExpr(_componentStylesStatic);

    // **NOTE**: It might tempting to try and minimize a lot of this by using
    // "static final", but Dart2JS emits much more defensive code in that case
    // in order to avoid eager instantiation.
    const localStylesVar = 'styles';

    // var styles = Static._componentStyles;
    final defineStyles = o.DeclareVarStmt(localStylesVar, staticCacheField);
    final readStyles = o.ReadVarExpr(localStylesVar);

    // if (styles == null) {
    //   Static._componentStyles = styles = ComponentStyles(...);
    //   if (isDevMode) {
    //      ComponentStyles.debugOnClear(_debugClearComponentStyles);
    //   }
    // }
    final ifStylesNullInit = o.IfStmt(
      readStyles.equals(o.nullExpr),
      [
        o.WriteStaticMemberExpr(
          _componentStylesStatic,
          o.WriteVarExpr(
            localStylesVar,
            _styleType.instantiate([
              _view.styles,
              o.ReadVarExpr(_debugComponentUrl),
            ]),
          ),
        ).toStmt(),
        o.IfStmt(
          o.importExpr(Runtime.isDevMode),
          [
            o.importExpr(StyleEncapsulation.componentStyles).callMethod(
              'debugOnClear',
              [o.ReadStaticMemberExpr(_debugClearComponentStyles)],
            ).toStmt(),
          ],
        ),
      ],
    );

    // this.componentStyles = styles;
    final assignMember = o.WriteClassMemberExpr(
      _componentStylesMember,
      readStyles,
    ).toStmt();

    _class.methods.add(
      o.ClassMethod(
        _initComponentStyles,
        const [],
        [
          defineStyles,
          ifStylesNullInit,
          assignMember,
        ],
      ),
    );
  }
}
