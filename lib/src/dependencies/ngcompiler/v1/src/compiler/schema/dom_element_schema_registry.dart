import 'package:ngdart/src/dependencies/ngcompiler/v1/src/compiler/security.dart';

import 'element_schema_registry.dart' show ElementSchemaRegistry;

const _boolean = 'boolean';
const _number = 'number';
const _string = 'string';
const _object = 'object';

/// This array represents the DOM schema. It encodes inheritance, properties, and events.
///
/// ## Overview
///
/// Each line represents one kind of element. The `element_inheritance` and properties are joined
/// using `element_inheritance|properties` syntax.
///
/// ## Element Inheritance
///
/// The `element_inheritance` can be further subdivided as `element1,element2,...^parentElement`.
/// Here the individual elements are separated by `,` (commas). Every element in the list
/// has identical properties.
///
/// An `element` may inherit additional properties from `parentElement` If no `^parentElement` is
/// specified then `""` (blank) element is assumed.
///
/// NOTE: The blank element inherits from root `*` element, the super element of all elements.
///
/// NOTE an element prefix such as `@svg:` has no special meaning to the schema.
///
/// ## Properties
///
/// Each element has a set of properties separated by `,` (commas). Each property can be prefixed
/// by a special character designating its type:
///
/// - (no prefix): property is a string.
/// - `*`: property represents an event.
/// - `!`: property is a boolean.
/// - `#`: property is a number.
/// - `%`: property is an object.
///
/// ## Query
///
/// The class creates an internal representation of html elements and attributes
/// which allows to easily answer the query of if a given property exist on a
/// given element.
///
/// NOTE: We don't yet support querying for types or events.
/// NOTE: This schema is auto extracted from `schema_extractor.ts` located in the test folder.
const List<String> _schema = [
  '*|%classList,className,id,innerHTML,*beforecopy,*beforecut,*beforepaste,*copy,*cut,*paste,*search,*selectstart,*webkitfullscreenchange,*webkitfullscreenerror,*wheel,outerHTML,#scrollLeft,#scrollTop,role',
  '^*|accessKey,autocapitalize,!autofocus,contentEditable,dir,!draggable,enterkeyhint,!hidden,innerText,inputmode,is,itemid,itemprop,itemref,!itemscope,itemtype,lang,nonce,*abort,*autocomplete,*autocompleteerror,*beforecopy,*beforecut,*beforepaste,*blur,*cancel,*canplay,*canplaythrough,*change,*click,*close,*contextmenu,*copy,*cuechange,*cut,*dblclick,*drag,*dragend,*dragenter,*dragleave,*dragover,*dragstart,*drop,*durationchange,*emptied,*ended,*error,*focus,*input,*invalid,*keydown,*keypress,*keyup,*load,*loadeddata,*loadedmetadata,*loadstart,*message,*mousedown,*mouseenter,*mouseleave,*mousemove,*mouseout,*mouseover,*mouseup,*mousewheel,*mozfullscreenchange,*mozfullscreenerror,*mozpointerlockchange,*mozpointerlockerror,*paste,*pause,*play,*playing,*progress,*ratechange,*reset,*resize,*scroll,*search,*seeked,*seeking,*select,*selectstart,*show,*stalled,*submit,*suspend,*timeupdate,*toggle,*volumechange,*waiting,*webglcontextcreationerror,*webglcontextlost,*webglcontextrestored,*webkitfullscreenchange,*webkitfullscreenerror,*wheel,outerText,!spellcheck,%style,#tabIndex,title,!translate',
  'media|!autoplay,!controls,%controlsList,%crossOrigin,#currentTime,!defaultMuted,#defaultPlaybackRate,!disableRemotePlayback,!loop,!muted,*encrypted,#playbackRate,preload,src,#volume',
  '@svg:^*|*abort,*autocomplete,*autocompleteerror,*blur,*cancel,*canplay,*canplaythrough,*change,*click,*close,*contextmenu,*cuechange,*dblclick,*drag,*dragend,*dragenter,*dragleave,*dragover,*dragstart,*drop,*durationchange,*emptied,*ended,*error,*focus,*input,*invalid,*keydown,*keypress,*keyup,*load,*loadeddata,*loadedmetadata,*loadstart,*mousedown,*mouseenter,*mouseleave,*mousemove,*mouseout,*mouseover,*mouseup,*mousewheel,*pause,*play,*playing,*progress,*ratechange,*reset,*resize,*scroll,*seeked,*seeking,*select,*show,*stalled,*submit,*suspend,*timeupdate,*toggle,*volumechange,*waiting,%style,#tabIndex',
  '@svg:graphics^@svg:|',
  '@svg:animation^@svg:|*begin,*end,*repeat',
  '@svg:geometry^@svg:|',
  '@svg:componentTransferFunction^@svg:|',
  '@svg:gradient^@svg:|',
  '@svg:textContent^@svg:graphics|',
  '@svg:textPositioning^@svg:textContent|',
  'a|charset,coords,download,hash,host,hostname,href,hreflang,name,password,pathname,ping,port,protocol,rel,rev,search,shape,target,text,type,username',
  'area|alt,coords,hash,host,hostname,href,!noHref,password,pathname,ping,port,protocol,search,shape,target,username',
  'audio^media|',
  'br|clear',
  'base|href,target',
  'body|aLink,background,bgColor,link,*beforeunload,*blur,*error,*focus,*hashchange,*languagechange,*load,*message,*offline,*online,*pagehide,*pageshow,*popstate,*rejectionhandled,*resize,*scroll,*storage,*unhandledrejection,*unload,text,vLink',
  'button|!disabled,formAction,formEnctype,formMethod,!formNoValidate,formTarget,name,type,value',
  'canvas|#height,#width',
  'content|select',
  'dl|!compact',
  'datalist|',
  'details|!open',
  'dialog|!open,returnValue',
  'dir|!compact',
  'div|align',
  'embed|align,height,name,src,type,width',
  'fieldset|!disabled,name',
  'font|color,face,size',
  'form|acceptCharset,action,autocomplete,encoding,enctype,method,name,!noValidate,target',
  'frame|frameBorder,longDesc,marginHeight,marginWidth,name,!noResize,scrolling,src',
  'frameset|cols,*beforeunload,*blur,*error,*focus,*hashchange,*languagechange,*load,*message,*offline,*online,*pagehide,*pageshow,*popstate,*rejectionhandled,*resize,*scroll,*storage,*unhandledrejection,*unload,rows',
  'hr|align,color,!noShade,size,width',
  'head|',
  'h1,h2,h3,h4,h5,h6|align',
  'html|version',
  'iframe|align,allow,!allowFullscreen,frameBorder,height,longDesc,marginHeight,marginWidth,name,%sandbox,scrolling,src,srcdoc,width',
  'img|align,alt,border,%crossOrigin,#height,#hspace,!isMap,longDesc,lowsrc,name,sizes,src,srcset,useMap,#vspace,#width',
  'input|accept,align,alt,autocomplete,!checked,!defaultChecked,defaultValue,dirName,!disabled,%files,formAction,formEnctype,formMethod,!formNoValidate,formTarget,#height,!incremental,!indeterminate,max,#maxLength,min,#minLength,!multiple,name,pattern,placeholder,!readOnly,!required,selectionDirection,#selectionEnd,#selectionStart,#size,src,step,type,useMap,value,%valueAsDate,#valueAsNumber,#width',
  'keygen|challenge,!disabled,keytype,name',
  'li|type,#value',
  'label|htmlFor',
  'legend|align',
  'link|as,charset,%crossOrigin,!disabled,href,hreflang,integrity,media,rel,%relList,rev,%sizes,target,type',
  'map|name',
  'marquee|behavior,bgColor,direction,height,#hspace,#loop,#scrollAmount,#scrollDelay,!trueSpeed,#vspace,width',
  'menu|!compact',
  'meta|content,httpEquiv,name,scheme',
  'meter|#high,#low,#max,#min,#optimum,#value',
  'ins,del|cite,dateTime',
  'ol|!compact,!reversed,#start,type',
  'object|align,archive,border,code,codeBase,codeType,data,!declare,height,#hspace,name,standby,type,useMap,#vspace,width',
  'optgroup|!disabled,label',
  'option|!defaultSelected,!disabled,label,!selected,text,value',
  'output|defaultValue,%htmlFor,name,value',
  'p|align',
  'param|name,type,value,valueType',
  'picture|',
  'pre|#width',
  'progress|#max,#value',
  'q,blockquote,cite|',
  'script|!async,charset,%crossOrigin,!defer,event,htmlFor,integrity,src,text,type',
  'select|!disabled,#length,!multiple,name,!required,#selectedIndex,#size,value',
  'shadow|',
  'source|media,sizes,src,srcset,type',
  'span|',
  'style|!disabled,media,type',
  'caption|align',
  'th,td|abbr,align,axis,bgColor,ch,chOff,#colSpan,headers,height,!noWrap,#rowSpan,scope,vAlign,width',
  'col,colgroup|align,ch,chOff,#span,vAlign,width',
  'table|align,bgColor,border,%caption,cellPadding,cellSpacing,frame,rules,summary,%tFoot,%tHead,width',
  'tr|align,bgColor,ch,chOff,vAlign',
  'tfoot,thead,tbody|align,ch,chOff,vAlign',
  'template|',
  'textarea|#cols,defaultValue,dirName,!disabled,#maxLength,#minLength,name,placeholder,!readOnly,!required,#rows,selectionDirection,#selectionEnd,#selectionStart,value,wrap',
  'title|text',
  'track|!default,kind,label,src,srclang',
  'ul|!compact,type',
  'unknown|',
  'video^media|!disablePictureInPicture,#height,poster,#width',
  '@svg:a^@svg:graphics|',
  '@svg:animate^@svg:animation|',
  '@svg:animateMotion^@svg:animation|',
  '@svg:animateTransform^@svg:animation|',
  '@svg:circle^@svg:geometry|',
  '@svg:clipPath^@svg:graphics|',
  '@svg:cursor^@svg:|',
  '@svg:defs^@svg:graphics|',
  '@svg:desc^@svg:|',
  '@svg:discard^@svg:|',
  '@svg:ellipse^@svg:geometry|',
  '@svg:feBlend^@svg:|',
  '@svg:feColorMatrix^@svg:|',
  '@svg:feComponentTransfer^@svg:|',
  '@svg:feComposite^@svg:|',
  '@svg:feConvolveMatrix^@svg:|',
  '@svg:feDiffuseLighting^@svg:|',
  '@svg:feDisplacementMap^@svg:|',
  '@svg:feDistantLight^@svg:|',
  '@svg:feDropShadow^@svg:|',
  '@svg:feFlood^@svg:|',
  '@svg:feFuncA^@svg:componentTransferFunction|',
  '@svg:feFuncB^@svg:componentTransferFunction|',
  '@svg:feFuncG^@svg:componentTransferFunction|',
  '@svg:feFuncR^@svg:componentTransferFunction|',
  '@svg:feGaussianBlur^@svg:|',
  '@svg:feImage^@svg:|',
  '@svg:feMerge^@svg:|',
  '@svg:feMergeNode^@svg:|',
  '@svg:feMorphology^@svg:|',
  '@svg:feOffset^@svg:|',
  '@svg:fePointLight^@svg:|',
  '@svg:feSpecularLighting^@svg:|',
  '@svg:feSpotLight^@svg:|',
  '@svg:feTile^@svg:|',
  '@svg:feTurbulence^@svg:|',
  '@svg:filter^@svg:|',
  '@svg:foreignObject^@svg:graphics|',
  '@svg:g^@svg:graphics|',
  '@svg:image^@svg:graphics|',
  '@svg:line^@svg:geometry|',
  '@svg:linearGradient^@svg:gradient|',
  '@svg:mpath^@svg:|',
  '@svg:marker^@svg:|',
  '@svg:mask^@svg:|',
  '@svg:metadata^@svg:|',
  '@svg:path^@svg:geometry|',
  '@svg:pattern^@svg:|',
  '@svg:polygon^@svg:geometry|',
  '@svg:polyline^@svg:geometry|',
  '@svg:radialGradient^@svg:gradient|',
  '@svg:rect^@svg:geometry|',
  '@svg:svg^@svg:graphics|#currentScale,#zoomAndPan',
  '@svg:script^@svg:|type',
  '@svg:set^@svg:animation|',
  '@svg:stop^@svg:|',
  '@svg:style^@svg:|!disabled,media,title,type',
  '@svg:switch^@svg:graphics|',
  '@svg:symbol^@svg:|',
  '@svg:tspan^@svg:textPositioning|',
  '@svg:text^@svg:textPositioning|',
  '@svg:textPath^@svg:textContent|',
  '@svg:title^@svg:|',
  '@svg:use^@svg:graphics|',
  '@svg:view^@svg:|#zoomAndPan'
];

// TODO(b/165123682): case insensitive for attributes.
const Map<String, String> _attrToPropMap = {
  'class': 'className',
  'innerHtml': 'innerHTML',
  'readonly': 'readOnly',
  'tabindex': 'tabIndex'
};

const Map<String, String> _propToAttrMap = {
  'className': 'class',
  'htmlFor': 'for',
};

class DomElementSchemaRegistry extends ElementSchemaRegistry {
  var schema = <String, Map<String, String>>{};
  var eventSchema = <String, Set<String>>{};
  var attributeSchema = <String, Set<String>>{};
  DomElementSchemaRegistry() {
    for (var encodedType in _schema) {
      var parts = encodedType.split('|');
      var properties = parts[1].split(',');
      var typeParts = ('${parts[0]}^').split('^');
      var typeName = typeParts[0];
      var type = <String, String>{};
      var attributes = <String>{};
      var events = <String>{};
      var tags = typeName.split(',');
      for (var tag in tags) {
        schema[tag] = type;
        attributeSchema[tag] = attributes;
        eventSchema[tag] = events;
      }
      var superType = schema[typeParts[1]];
      superType?.forEach((k, v) => type[k] = v);
      var superAttributes = attributeSchema[typeParts[1]];
      superAttributes?.forEach((item) => attributes.add(item));
      var superEvents = eventSchema[typeParts[1]];
      superEvents?.forEach((item) => events.add(item));
      for (var property in properties) {
        if (property.isEmpty) continue;
        if (property.startsWith('*')) {
          events.add(property.substring(1).toLowerCase());
        }
        if (property.startsWith('!')) {
          type[property.substring(1)] = _boolean;
          attributes.add(_toAttribute(property.substring(1)));
        } else if (property.startsWith('#')) {
          type[property.substring(1)] = _number;
          attributes.add(_toAttribute(property.substring(1)));
        } else if (property.startsWith('%')) {
          type[property.substring(1)] = _object;
          attributes.add(_toAttribute(property.substring(1)));
        } else {
          type[property] = _string;
          attributes.add(_toAttribute(property));
        }
      }
    }
  }

  @override
  bool hasProperty(String tagName, String propName) {
    var elementProperties = schema[tagName.toLowerCase()] ?? schema['unknown']!;
    return elementProperties[propName] != null;
  }

  @override
  bool hasAttribute(String tagName, String attributeName) {
    var elementAttributes =
        attributeSchema[tagName.toLowerCase()] ?? attributeSchema['unknown']!;
    return elementAttributes.contains(attributeName.toLowerCase());
  }

  @override
  bool hasEvent(String tagName, String eventName) {
    var elementEvents =
        eventSchema[tagName.toLowerCase()] ?? eventSchema['unknown']!;
    return elementEvents.contains(eventName.toLowerCase());
  }

  String _toAttribute(String propertyName) =>
      (_propToAttrMap[propertyName] ?? propertyName).toLowerCase();

  static final Map<String, TemplateSecurityContext> _securitySchema = {};

  void _registerSecuritySchema(
      TemplateSecurityContext context, List<String> schemaElements) {
    var itemCount = schemaElements.length;
    for (var i = 0; i < itemCount; i++) {
      _securitySchema[schemaElements[i]] = context;
    }
  }

  void _initializeSecuritySchema() {
    _registerSecuritySchema(TemplateSecurityContext.html,
        ['iframe|srcdoc', '*|innerHTML', '*|outerHTML']);
    _registerSecuritySchema(TemplateSecurityContext.style, ['*|style']);
    _registerSecuritySchema(TemplateSecurityContext.url, [
      '*|formAction',
      'area|href',
      'area|ping',
      'audio|src',
      'a|href',
      'a|ping',
      'blockquote|cite',
      'body|background',
      'del|cite',
      'form|action',
      'img|src',
      'img|srcset',
      'input|src',
      'ins|cite',
      'q|cite',
      'source|src',
      'source|srcset',
      'video|poster',
      'video|src'
    ]);
    _registerSecuritySchema(TemplateSecurityContext.resourceUrl, [
      'applet|code',
      'applet|codebase',
      'base|href',
      'embed|src',
      'frame|src',
      'head|profile',
      'html|manifest',
      'iframe|src',
      'link|href',
      'media|src',
      'object|codebase',
      'object|data',
      'script|src',
      'track|src'
    ]);
  }

  /// [securityContext] returns the security context for the given property on
  /// the given DOM tag.
  ///
  /// Tag and property name are statically known and cannot change at runtime,
  /// i.e. it is not possible to bind a value into a changing attribute or
  /// tag name.
  ///
  /// The filtering is allow-list based. All attributes in the schema above
  /// are assumed to have the 'NONE' security context, i.e. that they are safe
  /// inert string values. Only specific well known attack vectors are assigned
  /// their appropriate context.
  @override
  TemplateSecurityContext securityContext(String tagName, String propName) {
    if (_securitySchema.isEmpty) {
      _initializeSecuritySchema();
    }
    var key = '$tagName|$propName';
    return _securitySchema[key] ??
        _securitySchema['*|$propName'] ??
        TemplateSecurityContext.none;
  }

  @override
  String getMappedPropName(String propName) {
    var mappedPropName = _attrToPropMap[propName];
    return mappedPropName ?? propName;
  }
}
