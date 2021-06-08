import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class BuildingMapBehavior {
  // behavior object
  final _pointsGeomSubject = BehaviorSubject<String>();
  final _checkPointsGeomSubject = BehaviorSubject<String>();
  final _submitSubject = BehaviorSubject<bool>();

  // validattion
  var pointsGeomValidation = StreamTransformer<String, bool>.fromHandlers(
    handleData: (pointsGeom, sink) {
      sink.add(PointsGeomValidation.validatePointsGeom(pointsGeom));
    }
  );

  var checkPointsGeomValidation = StreamTransformer<String, bool>.fromHandlers(
    handleData: (checkPointsGeom, sink) {
      sink.add(PointsGeomValidation.validateCheckPointsGeom(checkPointsGeom));
    }
  );

  // stream and sink
  Stream<bool> get pointsGeomStream => _pointsGeomSubject.stream.transform(pointsGeomValidation);
  Sink<String> get pointsGeomSink => _pointsGeomSubject.sink;

  Stream<bool> get checkPointsGeomStream => _checkPointsGeomSubject.stream.transform(checkPointsGeomValidation);
  Sink<String> get checkPointsGeomSink => _checkPointsGeomSubject.sink;

  Stream<bool> get submitStream => _submitSubject.stream;
  Sink<bool> get submitSink => _submitSubject.sink;

  BuildingMapBehavior() {
    Rx.combineLatest2(
      _pointsGeomSubject,
      _checkPointsGeomSubject,
        (pointsGeom, checkPointsGeom) {
          return PointsGeomValidation.validatePointsGeom(pointsGeom) == true &&
            PointsGeomValidation.validatePointsGeom(checkPointsGeom) == true;
        }
    ).listen(
      (enable) {
        _submitSubject.add(enable);
      }
    );
  }

  dispose() {
    _pointsGeomSubject.close();
    _checkPointsGeomSubject.close();
    _submitSubject.close();
  }
}
