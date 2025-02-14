import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/expression_parser/ast.dart' as ast;
import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/ir/model.dart' as ir;

bool isInterpolation(ir.BindingSource? source) =>
    source is ir.BoundExpression && source.expression.ast is ast.Interpolation;
