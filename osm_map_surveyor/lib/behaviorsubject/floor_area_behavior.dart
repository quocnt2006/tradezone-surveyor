import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class FloorAreaBehavior {
  // behavior subject
  final _nameFloorAreaSubject = BehaviorSubject<String>();

  // validattion
  var nameFloorAreaValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      sink.add(FloorAreaValidation.validateName(name));
    }
  );

  // stream and sink
  Stream<String> get nameFloorAreaStream => _nameFloorAreaSubject.stream.transform(nameFloorAreaValidation);
  Sink<String> get nameFloorAreaSink => _nameFloorAreaSubject.sink;

  dispose() {
    _nameFloorAreaSubject.close();
  }
}
