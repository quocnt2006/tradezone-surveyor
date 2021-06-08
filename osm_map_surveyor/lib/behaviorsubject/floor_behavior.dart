import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class FloorBehavior {
  // behavior object
  final _nameSubject = BehaviorSubject<String>();

  // validattion
  var nameValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      sink.add(FloorValidation.validateName(name));
    }
  );

  // stream and sink
  Stream<String> get nameStream => _nameSubject.stream.transform(nameValidation);
  Sink<String> get nameSink => _nameSubject.sink;

  dispose() {
    _nameSubject.close();
  }
}
