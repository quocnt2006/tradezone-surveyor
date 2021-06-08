import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class StoreMapBehavior {
  // behavior object
  final _pointGeomSubject = BehaviorSubject<String>();
  final _checkPointGeomSubject = BehaviorSubject<String>();
  final _submitSubject = BehaviorSubject<bool>();

  // validattion
  var pointGeomValidation = StreamTransformer<String, bool>.fromHandlers(
    handleData: (pointGeom, sink) {
      sink.add(PointGeomValidation.validatePointGeom(pointGeom));
    }
  );

  var checkPointGeomValidation = StreamTransformer<String, bool>.fromHandlers(
    handleData: (checkPointsGeom, sink) {
      sink.add(PointGeomValidation.validateCheckPointsGeom(checkPointsGeom));
    }
  );

  // stream and sink
  Stream<bool> get pointGeomStream => _pointGeomSubject.stream.transform(pointGeomValidation);
  Sink<String> get pointGeomSink => _pointGeomSubject.sink;

  Stream<bool> get checkPointsGeomStream => _checkPointGeomSubject.stream.transform(checkPointGeomValidation);
  Sink<String> get checkPointsGeomSink => _checkPointGeomSubject.sink;

  Stream<bool> get submitStream => _submitSubject.stream;
  Sink<bool> get submitSink => _submitSubject.sink;

  StoreMapBehavior() {
    Rx.combineLatest2(
      _pointGeomSubject,
      _checkPointGeomSubject,
        (pointGeom, checkPointGeom) {
          return PointGeomValidation.validatePointGeom(pointGeom) == true &&
            PointGeomValidation.validatePointGeom(checkPointGeom) == true;
        }
    ).listen(
      (enable) {
        _submitSubject.add(enable);
      }
    );
  }

  dispose() {
    _pointGeomSubject.close();
    _checkPointGeomSubject.close();
    _submitSubject.close();
  }
}