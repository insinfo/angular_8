import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import '../ast.dart';
import '../ast/attributes/attribute_ast_mixin.dart';
import '../exception_handler/exception_handler.dart';
import '../token/tokens.dart';
import 'reader.dart';

/// A recursive descent AST parser from a series of tokens.
class RecursiveAstParser {
  final NgTokenReversibleReader<Object> _reader;
  final SourceFile _source;
  final List<String> _voidElements;
  final List<String> _svgElements;
  final ExceptionHandler exceptionHandler;

  RecursiveAstParser(
    SourceFile sourceFile,
    Iterable<NgToken> tokens,
    this._voidElements,
    this._svgElements,
    this.exceptionHandler,
  )   : _reader = NgTokenReversibleReader<NgTokenType>(sourceFile, tokens),
        _source = sourceFile;

  /// Iterates through and returns the top-level AST nodes from the tokens.
  List<StandaloneTemplateAst> parse() {
    // Start with an empty list.
    var nodes = <StandaloneTemplateAst>[];
    NgToken? token;
    // Iterate through until and wait until EOF.
    //
    // Collects comments, elements, and text.
    //
    // Any other AST structure should be handled by the parseElement case.
    while ((token = _reader.next() as NgToken?) != null) {
      nodes.add(parseStandalone(token!)!);
    }

    // Return the collected nodes.
    return nodes;
  }

  /// Parses and returns a [CloseElementAst].
  CloseElementAst parseCloseElement(NgToken beginToken) {
    var nameToken = _reader.next()!;
    if (_voidElements.contains(nameToken.lexeme)) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.voidElementInCloseTag,
        nameToken.offset,
        nameToken.length,
      ));
    }

    while (_reader.peekType() == NgTokenType.whitespace) {
      _reader.next();
    }
    var closeElementEnd = _reader.next();
    return CloseElementAst.parsed(
      _source,
      beginToken,
      nameToken as NgToken,
      closeElementEnd as NgToken,
    );
  }

  /// Parses and returns a comment beginning at the token provided.
  CommentAst parseComment(NgToken beginToken) {
    NgToken valueToken;
    if (_reader.peekType() == NgTokenType.commentEnd) {
      valueToken = NgToken.commentValue(_reader.peek()!.offset, '');
    } else {
      valueToken = _reader.next() as NgToken;
    }
    var endToken = _reader.next();
    return CommentAst.parsed(
      _source,
      beginToken,
      valueToken,
      endToken as NgToken,
    );
  }

  /// Parses and returns an `<ng-container>` AST.
  ContainerAst parseContainer(
    NgToken beginToken,
    NgToken nameToken,
    List<String> tagStack,
  ) {
    final annotations = <AnnotationAst>[];
    final childNodes = <StandaloneTemplateAst>[];
    final stars = <StarAst>[];

    while (_reader.peekType() == NgTokenType.beforeElementDecorator) {
      final nextToken = _reader.next();
      final decorator = parseDecorator(nextToken as NgToken);
      if (decorator is AnnotationAst) {
        annotations.add(decorator);
      } else if (decorator is StarAst) {
        _addStarAst(decorator, stars);
      } else {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.invalidDecoratorInNgContainer,
          decorator.beginToken!.offset,
          decorator.endToken!.end - decorator.beginToken!.offset,
        ));
      }
    }

    final endToken = _parseOpenElementEnd();
    final closeComplement = _parseCloseElement(
        beginToken, nameToken, endToken, childNodes, tagStack);

    return ContainerAst.parsed(
      _source,
      beginToken,
      endToken,
      closeComplement,
      annotations: annotations,
      childNodes: childNodes,
      stars: stars,
    );
  }

  /// Parses and returns a template AST beginning at the token provided.
  /// No desugaring of any kind occurs here.
  TemplateAst parseDecorator(NgToken beginToken) {
    // The first token is the decorator/name.
    NgToken? prefixToken;
    NgToken? decoratorToken;
    NgToken? suffixToken;

    var peekType = _reader.peekType();
    if (peekType == NgTokenType.bananaPrefix ||
        peekType == NgTokenType.eventPrefix ||
        peekType == NgTokenType.propertyPrefix) {
      prefixToken = _reader.next() as NgToken;
      decoratorToken = _reader.next() as NgToken;
      suffixToken = _reader.next() as NgToken;
    } else if (peekType == NgTokenType.referencePrefix ||
        peekType == NgTokenType.templatePrefix ||
        peekType == NgTokenType.annotationPrefix) {
      prefixToken = _reader.next() as NgToken;
      decoratorToken = _reader.next() as NgToken;
    } else {
      decoratorToken = _reader.next() as NgToken;
    }

    NgAttributeValueToken? valueToken;
    NgToken? equalSignToken;

    if (_reader.peekTypeIgnoringType(NgTokenType.whitespace) ==
        NgTokenType.beforeElementDecoratorValue) {
      _consumeWhitespaces();
      equalSignToken = _reader.next() as NgToken;
      _consumeWhitespaces();
      valueToken = _reader.next() as NgAttributeValueToken;
    }

    if (prefixToken != null) {
      var prefixType = prefixToken.type;

      if (prefixType == NgTokenType.bananaPrefix) {
        return BananaAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.eventPrefix) {
        // Disabling: event names can be as long as keyup.ctrl.shift.alt.mod.+
        // Should this be limited to 6 then? Or should it be left open?
        //if (decoratorToken.lexeme.split('.').length > 2) {
        //  exceptionHandler.handle(new AngularParserException(
        //    NgParserWarningCode.EVENT_NAME_TOO_MANY_FIXES,
        //    decoratorToken.offset,
        //    decoratorToken.length,
        //  ));
        //}

        return EventAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.propertyPrefix) {
        if (decoratorToken.lexeme.split('.').length > 3) {
          exceptionHandler.handle(AngularParserException(
            ParserErrorCode.propertyNameTooManyFixes,
            decoratorToken.offset,
            decoratorToken.length,
          ));
        }

        return PropertyAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.referencePrefix) {
        return ReferenceAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.templatePrefix) {
        return StarAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.annotationPrefix) {
        return AnnotationAst.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      }
    }

    // At this point, it is a TextAttribute, but handle cases
    // with 'on-' and 'bind-' prefix.
    if (decoratorToken.lexeme.startsWith('on-')) {
      var onToken = NgToken.onPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'on-'.length,
        decoratorToken.lexeme.substring('on-'.length),
      );
      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.elementDecoratorAfterPrefix,
          onToken.offset,
          onToken.length,
        ));
      }
      return EventAst.parsed(
        _source,
        onToken,
        decoratorToken,
        null,
        valueToken,
        equalSignToken,
      );
    }
    if (decoratorToken.lexeme.startsWith('bind-')) {
      var bindToken = NgToken.bindPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'bind-'.length,
        decoratorToken.lexeme.substring('bind-'.length),
      );
      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.elementDecoratorAfterPrefix,
          bindToken.offset,
          bindToken.length,
        ));
      }
      return PropertyAst.parsed(
        _source,
        bindToken,
        decoratorToken,
        null,
        valueToken,
        equalSignToken,
      );
    }
    if (decoratorToken.lexeme.startsWith('let-')) {
      var letToken = NgToken.letPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'let-'.length,
        decoratorToken.lexeme.substring('let-'.length),
      );
      return LetBindingAst.parsed(
        _source,
        letToken,
        decoratorToken,
        valueToken,
        equalSignToken,
      );
    }

    List<InterpolationAst>? parsedMustaches;
    if (valueToken != null) {
      parsedMustaches =
          _parseMustacheInPlainAttributeValue(valueToken.innerValue!);
    }
    return AttributeAst.parsed(
      _source,
      decoratorToken,
      valueToken,
      equalSignToken,
      parsedMustaches,
    );
  }

  /// Returns a DOM element AST starting at the provided token.
  ///
  /// It's possible the element will end up not being an [ElementAst].
  StandaloneTemplateAst parseElement(
      NgToken beginToken, List<String> tagStack) {
    var isTemplateElement = false;

    // Parse the element identifier.
    var nameToken = _reader.next()!;
    if (nameToken.lexeme == 'ng-container') {
      return parseContainer(beginToken, nameToken as NgToken, tagStack);
    } else if (nameToken.lexeme == 'ng-content') {
      return parseEmbeddedContent(beginToken, nameToken as NgToken);
    } else if (nameToken.lexeme.toLowerCase() == 'template') {
      isTemplateElement = true;
    }
    var isVoidElement = _voidElements.contains(nameToken.lexeme);
    // TODO(alorenzen): Add better namespace handling.
    var isSvgElement =
        _svgElements.contains(nameToken.lexeme.replaceAll('svg:', ''));

    // Start collecting decorators.
    var attributes = <AttributeAst>[];
    var childNodes = <StandaloneTemplateAst>[];
    var events = <EventAst>[];
    var properties = <PropertyAst>[];
    var references = <ReferenceAst>[];
    var bananas = <BananaAst>[];
    var stars = <StarAst>[];
    var annotations = <AnnotationAst>[];
    var letBindings = <LetBindingAst>[];
    NgToken nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = _reader.next() as NgToken;
      if (nextToken.type == NgTokenType.beforeElementDecorator) {
        var decoratorAst = parseDecorator(nextToken);
        if (decoratorAst is AttributeAst) {
          attributes.add(decoratorAst);
        } else if (decoratorAst is LetBindingAst) {
          if (!isTemplateElement) {
            // 'let-' binding can only exist in <template>.
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.invalidLetBindingInNoTemplate,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else if (decoratorAst.name.isEmpty) {
            var letToken = (decoratorAst as ParsedLetBindingAst).prefixToken;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.elementDecoratorAfterPrefix,
              letToken.offset,
              letToken.length,
            ));
          } else {
            letBindings.add(decoratorAst);
          }
        } else if (decoratorAst is StarAst) {
          if (isTemplateElement) {
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.invalidDecoratorInTemplate,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else {
            if (stars.isNotEmpty) {
              exceptionHandler.handle(AngularParserException(
                ParserErrorCode.duplicateStarDirective,
                decoratorAst.beginToken!.offset,
                decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
              ));
            } else {
              stars.add(decoratorAst);
            }
          }
        } else if (decoratorAst is AnnotationAst) {
          annotations.add(decoratorAst);
        } else if (decoratorAst is EventAst) {
          events.add(decoratorAst);
        } else if (decoratorAst is PropertyAst) {
          properties.add(decoratorAst);
        } else if (decoratorAst is BananaAst) {
          if (isTemplateElement) {
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.invalidDecoratorInTemplate,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else {
            bananas.add(decoratorAst);
          }
        } else if (decoratorAst is ReferenceAst) {
          references.add(decoratorAst);
        } else {
          throw StateError('Invalid decorator AST: $decoratorAst');
        }
      }
    } while (nextToken.type != NgTokenType.openElementEnd &&
        nextToken.type != NgTokenType.openElementEndVoid);

    if (!isVoidElement &&
        !isSvgElement &&
        nextToken.type == NgTokenType.openElementEndVoid) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.nonVoidElementUsingVoidEnd,
        nextToken.offset,
        nextToken.length,
      ));
      nextToken = NgToken.generateErrorSynthetic(
        nextToken.offset,
        NgTokenType.openElementEnd,
      );
    }
    var endToken = nextToken;
    CloseElementAst? closeElementAst;

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != NgTokenType.openElementEndVoid) {
      closeElementAst = _parseCloseElement(
        beginToken,
        nameToken as NgToken,
        endToken,
        childNodes,
        tagStack,
      );
    }

    if (isTemplateElement) {
      return EmbeddedTemplateAst.parsed(
        _source,
        beginToken,
        endToken,
        closeComplement: closeElementAst,
        annotations: annotations,
        attributes: attributes,
        childNodes: childNodes,
        events: events,
        properties: properties,
        references: references,
        letBindings: letBindings,
      );
    } else {
      return ElementAst.parsed(
        _source,
        beginToken,
        nameToken as NgToken,
        endToken,
        annotations: annotations,
        attributes: attributes,
        childNodes: childNodes,
        events: events,
        properties: properties,
        references: references,
        bananas: bananas,
        stars: stars,
        closeComplement: closeElementAst,
      );
    }
  }

  /// Returns and parses an embedded content directive/transclusions.
  EmbeddedContentAst parseEmbeddedContent(
      NgToken beginToken, NgToken elementIdentifierToken) {
    NgToken endToken;
    AttributeAst? selectAttribute, ngProjectAsAttribute;
    ReferenceAst? reference;
    var selectAttributeFound = false;
    var ngProjectAsAttributeFound = false;
    var referenceAttributeFound = false;
    CloseElementAst closeElementAst;

    // Ensure that ng-content has only 'select', 'ngProjectAs' and a reference,
    // if any. Also catch for multiple ones; if multiple, accept the first one
    // seen.
    while (_reader.peekType() == NgTokenType.beforeElementDecorator) {
      final nextToken = _reader.next();
      final decorator = parseDecorator(nextToken as NgToken);
      final startOffset = decorator.beginToken!.offset;
      final endOffset = decorator.endToken!.end;
      if (decorator is AttributeAst && decorator.name == 'select') {
        if (selectAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.duplicateSelectDecorator,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          selectAttributeFound = true;
          selectAttribute = decorator;
        }
      } else if (decorator is AttributeAst && decorator.name == 'ngProjectAs') {
        if (ngProjectAsAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.duplicateProjectAsDecorator,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          ngProjectAsAttributeFound = true;
          ngProjectAsAttribute = decorator;
        }
      } else if (decorator is ReferenceAst) {
        if (referenceAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.duplicateReferenceDecorator,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          referenceAttributeFound = true;
          reference = decorator;
          if (reference.identifier != null) {
            var e = AngularParserException(
              ParserErrorCode.referenceIdentifierFound,
              startOffset,
              endOffset - startOffset,
            );
            exceptionHandler.handle(e);
          }
        }
      } else {
        var e = AngularParserException(
          ParserErrorCode.invalidDecoratorInNgContent,
          decorator.beginToken!.offset,
          decorator.endToken!.end - decorator.beginToken!.offset,
        );
        exceptionHandler.handle(e);
      }
    }

    endToken = _parseOpenElementEnd();

    // Skip whitespace after <ng-content>.
    if (_reader.peekType() == NgTokenType.text) {
      final textToken = _reader.next();
      final text = parseText(textToken as NgToken);
      if (text.value.trim().isNotEmpty) {
        _reader.putBack(textToken);
      }
    }

    // Ensure closing </ng-content> exists.
    if (_reader.peekType() != NgTokenType.closeElementStart) {
      var e = AngularParserException(
        ParserErrorCode.ngContentMustCLoseImmediately,
        beginToken.offset,
        endToken.end - beginToken.offset,
      );
      exceptionHandler.handle(e);
      closeElementAst = CloseElementAst('ng-content');
    } else {
      var closeElementStart = _reader.next();
      var closeElementName = _reader.peek()!.lexeme;

      if (closeElementName != 'ng-content') {
        var e = AngularParserException(
          ParserErrorCode.ngContentMustCLoseImmediately,
          beginToken.offset,
          endToken.end - beginToken.offset,
        );
        exceptionHandler.handle(e);
        _reader.putBack(closeElementStart!);
        closeElementAst = CloseElementAst('ng-content');
      } else {
        closeElementAst = parseCloseElement(closeElementStart as NgToken);
      }
    }
    return EmbeddedContentAst.parsed(
      _source,
      beginToken,
      elementIdentifierToken,
      endToken,
      closeElementAst,
      selectAttribute,
      ngProjectAsAttribute,
      reference,
    );
  }

  /// Helper function that, given a plain attribute value,
  /// parses it and generates a list of [InterpolationAst].
  /// Upon mustache errors, either throws or recovers based on
  /// [ExceptionHandler] used.
  List<InterpolationAst> _parseMustacheInPlainAttributeValue(
      NgToken innerValue) {
    var text = innerValue.lexeme;
    var absoluteTextOffset = innerValue.offset;
    var tokens = RegExp(r'({{)|(}})');
    var mustaches = <InterpolationAst>[];
    int? seenOpenMustache;

    var scanner = StringScanner(text);
    while (!scanner.isDone) {
      var position = scanner.position;
      var match = tokens.firstMatch(scanner.rest);
      if (match != null) {
        var matchPosition = position + match.start;

        if (match.group(1) != null) {
          // '{{' found.
          if (seenOpenMustache == null) {
            seenOpenMustache = matchPosition;
          } else {
            // Second '{{' found before '}}' closes it.
            var firstMustacheBegin = absoluteTextOffset + seenOpenMustache;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.unterminatedMustache,
              firstMustacheBegin,
              '{{'.length,
            ));

            mustaches.add(InterpolationAst.parsed(
              _source,
              NgToken.interpolationStart(firstMustacheBegin),
              NgToken.interpolationValue(
                  firstMustacheBegin + '{{'.length,
                  text.substring(
                      seenOpenMustache + '{{'.length, matchPosition)),
              NgToken.generateErrorSynthetic(absoluteTextOffset + matchPosition,
                  NgTokenType.interpolationEnd),
            ));
            seenOpenMustache = matchPosition;
          }
        }

        if (match.group(2) != null) {
          if (seenOpenMustache != null) {
            var mustacheBegin = absoluteTextOffset + seenOpenMustache;
            var mustacheEnd = absoluteTextOffset + matchPosition;
            mustaches.add(InterpolationAst.parsed(
              _source,
              NgToken.interpolationStart(mustacheBegin),
              NgToken.interpolationValue(
                  mustacheBegin + '{{'.length,
                  text.substring(
                      seenOpenMustache + '{{'.length, matchPosition)),
              NgToken.interpolationEnd(mustacheEnd),
            ));
            seenOpenMustache = null;
          } else {
            // Found '}}' before any '{{'
            var mustacheBegin = absoluteTextOffset + position;
            var mustacheEnd = absoluteTextOffset + matchPosition;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.unopenedMustache,
              mustacheEnd,
              '}}'.length,
            ));
            mustaches.add(InterpolationAst.parsed(
              _source,
              NgToken.generateErrorSynthetic(
                  mustacheBegin, NgTokenType.interpolationStart),
              NgToken.interpolationValue(
                  mustacheBegin, text.substring(position, matchPosition)),
              NgToken.interpolationEnd(mustacheEnd),
            ));
          }
        }
        scanner.position += match.end;
      } else {
        scanner.position += scanner.rest.length;
      }
    }
    // Dangling '{{' and hit end of value-text
    if (seenOpenMustache != null) {
      var mustacheBegin = absoluteTextOffset + seenOpenMustache;
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.unterminatedMustache,
        mustacheBegin,
        '{{'.length,
      ));
      mustaches.add(InterpolationAst.parsed(
        _source,
        NgToken.interpolationStart(mustacheBegin),
        NgToken.interpolationValue(mustacheBegin + '{{'.length,
            text.substring(seenOpenMustache + '{{'.length, text.length)),
        NgToken.generateErrorSynthetic(
            absoluteTextOffset + text.length, NgTokenType.interpolationEnd),
      ));
    }
    return mustaches;
  }

  /// Returns and parses an interpolation AST.
  InterpolationAst parseInterpolation(NgToken beginToken) {
    var valueToken = _reader.next();
    var endToken = _reader.next();
    return InterpolationAst.parsed(
      _source,
      beginToken,
      valueToken as NgToken,
      endToken as NgToken,
    );
  }

  /// Returns and parses a top-level AST structure.
  StandaloneTemplateAst? parseStandalone(
    NgToken token, [
    List<String>? tagStack,
  ]) {
    tagStack ??= [];
    switch (token.type) {
      case NgTokenType.commentStart:
        return parseComment(token);
      case NgTokenType.openElementStart:
        return parseElement(token, tagStack);
      case NgTokenType.interpolationStart:
        return parseInterpolation(token);
      case NgTokenType.text:
        return parseText(token);
      // Dangling close tag. If error recovery is enabled, returns
      // a synthetic open with the dangling close. If not enabled,
      // simply throws error.
      case NgTokenType.closeElementStart:
        var danglingCloseIdentifier = _reader.peek()!.lexeme;
        var closeComplement = parseCloseElement(token);
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.danglingCloseElement,
          closeComplement.beginToken!.offset,
          closeComplement.endToken!.end - closeComplement.beginToken!.offset,
        ));
        if (danglingCloseIdentifier == 'ng-content') {
          var synthOpenElement = EmbeddedContentAst();
          synthOpenElement.closeComplement = closeComplement;
          return synthOpenElement;
        } else {
          var synthOpenElement =
              ElementAst(danglingCloseIdentifier, closeComplement);
          return synthOpenElement;
        }
      default:
        // Simply throw error here; should never hit.
        if (exceptionHandler is RecoveringExceptionHandler) {
          // Throw an error here - this should never hit in recovery mode
          // unless something went really wrong. If so, FIX IT ASAP!
          throw Exception('Non-standalone starting token found!');
        }
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.expectedStandalone,
          token.offset,
          token.length,
        ));
        return null;
    }
  }

  /// Adds [starAst] to [starAsts] if empty, otherwise produces an error.
  void _addStarAst(StarAst starAst, List<StarAst> starAsts) {
    if (starAsts.isEmpty) {
      starAsts.add(starAst);
    } else {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.duplicateStarDirective,
        starAst.beginToken!.offset,
        starAst.beginToken!.end - starAst.beginToken!.offset,
      ));
    }
  }

  /// Parses child nodes until the closing tag, which is then returned.
  ///
  /// Child nodes are appended to [childNodes].
  CloseElementAst _parseCloseElement(
    NgToken beginToken,
    NgToken nameToken,
    NgToken endToken,
    List<StandaloneTemplateAst> childNodes,
    List<String> tagStack,
  ) {
    tagStack.add(nameToken.lexeme);
    var closingTagFound = false;
    late CloseElementAst closeElementAst;
    while (!closingTagFound) {
      final nextToken = _reader.next();
      if (nextToken == null) {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.cannotFindMatchingClose,
          beginToken.offset,
          endToken.end - beginToken.offset,
        ));
        closeElementAst = CloseElementAst(nameToken.lexeme);
        closingTagFound = true;
      } else if (nextToken.type == NgTokenType.closeElementStart) {
        var closeNameToken = _reader.peek()!;
        var closeIdentifier = closeNameToken.lexeme;
        if (closeIdentifier != nameToken.lexeme) {
          // Found a closing tag, but not matching current [ElementAst].
          // Generate initial error code; could be dangling or unmatching.
          if (tagStack.contains(closeIdentifier)) {
            // If the closing tag is in the seen [ElementAst] stack,
            // leave it alone. Instead create a synthetic close.
            _reader.putBack(nextToken);
            closeElementAst = CloseElementAst(nameToken.lexeme);
            closingTagFound = true;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.cannotFindMatchingClose,
              beginToken.offset,
              endToken.end - beginToken.offset,
            ));
          } else {
            // If the closing tag is not in the stack, create a synthetic
            // [ElementAst] to pair the dangling close and add as child.
            var closeComplement = parseCloseElement(nextToken as NgToken);
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.danglingCloseElement,
              closeComplement.beginToken!.offset,
              closeComplement.endToken!.end -
                  closeComplement.beginToken!.offset,
            ));
            if (closeIdentifier == 'ng-container') {
              var synthContainer = ContainerAst();
              synthContainer.closeComplement = closeComplement;
              childNodes.add(synthContainer);
            } else if (closeIdentifier == 'ng-content') {
              var synthContent = EmbeddedContentAst();
              synthContent.closeComplement = closeComplement;
              childNodes.add(synthContent);
            } else if (closeIdentifier == 'template') {
              var synthTemplate = EmbeddedTemplateAst();
              synthTemplate.closeComplement = closeComplement;
              childNodes.add(synthTemplate);
            } else {
              var synthOpenElement =
                  ElementAst(closeNameToken.lexeme, closeComplement);
              childNodes.add(synthOpenElement);
            }
          }
        } else {
          closeElementAst = parseCloseElement(nextToken as NgToken);
          closingTagFound = true;
        }
      } else {
        var childAst = parseStandalone(nextToken as NgToken, tagStack)!;
        childNodes.add(childAst);
      }
    }
    tagStack.removeLast();
    return closeElementAst;
  }

  /// Ensures open element ends with `>` and not `/>`.
  NgToken _parseOpenElementEnd() {
    _consumeWhitespaces();
    final endToken = _reader.next()!;
    if (endToken.type == NgTokenType.openElementEndVoid) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.nonVoidElementUsingVoidEnd,
        endToken.offset,
        endToken.length,
      ));
      return NgToken.generateErrorSynthetic(
        endToken.offset,
        NgTokenType.openElementEnd,
      );
    }
    return endToken as NgToken;
  }

  void _consumeWhitespaces() {
    while (_reader.peekType() != null &&
        _reader.peekType() == NgTokenType.whitespace) {
      _reader.next();
    }
  }

  /// Returns and parses a text AST.
  TextAst parseText(NgToken token) => TextAst.parsed(_source, token);
}
