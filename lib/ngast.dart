import '/src/dependencies/ngast/src/ast.dart';
import '/src/dependencies/ngast/src/exception_handler/exception_handler.dart';
import '/src/dependencies/ngast/src/parser.dart';

export '/src/dependencies/ngast/src/ast.dart'
    show
        AnnotationAst,
        AttributeAst,
        BananaAst,
        CloseElementAst,
        CommentAst,
        ContainerAst,
        ElementAst,
        EmbeddedContentAst,
        EmbeddedTemplateAst,
        EventAst,
        InterpolationAst,
        LetBindingAst,
        ParsedAnnotationAst,
        ParsedAttributeAst,
        ParsedBananaAst,
        ParsedCloseElementAst,
        ParsedDecoratorAst,
        ParsedEmbeddedContentAst,
        ParsedEventAst,
        ParsedInterpolationAst,
        ParsedElementAst,
        ParsedLetBindingAst,
        ParsedPropertyAst,
        ParsedReferenceAst,
        ParsedStarAst,
        PropertyAst,
        ReferenceAst,
        StandaloneTemplateAst,
        StarAst,
        SyntheticTemplateAst,
        TagOffsetInfo,
        TemplateAst,
        TextAst;
export '/src/dependencies/ngast/src/exception_handler/exception_handler.dart'
    show ExceptionHandler, RecoveringExceptionHandler, ThrowingExceptionHandler;
export '/src/dependencies/ngast/src/exception_handler/exception_handler.dart';
export '/src/dependencies/ngast/src/lexer.dart' show NgLexer;
export '/src/dependencies/ngast/src/parser.dart' show NgParser;
export '/src/dependencies/ngast/src/recovery_protocol/recovery_protocol.dart';
export '/src/dependencies/ngast/src/token/tokens.dart' show NgToken, NgTokenType, NgAttributeValueToken;
export '/src/dependencies/ngast/src/visitor.dart'
    show
        HumanizingTemplateAstVisitor,
        IdentityTemplateAstVisitor,
        MinimizeWhitespaceVisitor,
        TemplateAstVisitor,
        DesugarVisitor,
        RecursiveTemplateAstVisitor;

/// Returns [template] parsed as an abstract syntax tree.
///
/// If [desugar] is set, parsing will transform `*directive` and `[(banana)]`
/// notations into their explicit forms using `<template>` and `[value]="..."
/// (valueChanged)="..."` respectively.
List<TemplateAst> parse(
  String template, {
  required String sourceUrl,
  bool desugar = true,
  ExceptionHandler exceptionHandler = const ThrowingExceptionHandler(),
}) {
  return const NgParser().parse(
    template,
    sourceUrl: sourceUrl,
    exceptionHandler: exceptionHandler,
    desugar: desugar,
  );
}
