library source_gen;

import 'dart:mirrors';

import 'package:analyzer/src/generated/element.dart';
import 'utils.dart';
import 'dart:async';

abstract class Generator {
  const Generator();

  Future<String> generate(Element element);
}

abstract class GeneratorForAnnotation<T> extends Generator {
  const GeneratorForAnnotation();

  @override
  Future<String> generate(Element element) {
    var matchingAnnotations =
        element.metadata.where((md) => matchAnnotation(T, md)).toList();

    if (matchingAnnotations.isEmpty) {
      return null;
    } else if (matchingAnnotations.length > 1) {
      throw 'cannot have more than one matching annotation';
    }

    // now we need to create the instance!
    var classMirror = reflectClass(T);

    // TODO: actually construct the annotation from analyzer arguments
    // var matchingAnnotation = matchingAnnotations.single;
    var annotationInstance =
        classMirror.newInstance(const Symbol(''), []).reflectee as T;

    return generateForAnnotatedElement(element, annotationInstance);
  }

  Future<String> generateForAnnotatedElement(Element element, T annotation);
}

class InvalidGenerationSourceError {
  final String message;
  final String todo;

  InvalidGenerationSourceError(this.message, {String todo})
      : this.todo = todo == null ? '' : todo;
}
