import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class BuildingBehavior {
  // behavior subject
  final _nameBuildingSubject = BehaviorSubject<String>();
  final _addressBuildingSubject = BehaviorSubject<String>();
  final _imageBuildingSubject = BehaviorSubject<String>();
  final _geomBuildingSubject = BehaviorSubject<String>();
  final _streetSegmentSubject = BehaviorSubject<String>();
  final _submitBuildingSubject = BehaviorSubject<bool>();

  // validation
  var nameBuildingValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      sink.add(BuildingValidation.validateName(name));
    }
  );

  var addressBuildingValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (address, sink) {
      sink.add(BuildingValidation.validateAddress(address));
    }
  );

  var imageBuildingValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (image, sink) {
      sink.add(BuildingValidation.validateImage(image));
    }
  );

  var geomBuildingValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (geom, sink) {
      sink.add(BuildingValidation.validateGeom(geom));
    }
  );

  var streetSegmentValidation = StreamTransformer<String, bool>.fromHandlers(
    handleData: (streetSegment, sink) {
      sink.add(BuildingValidation.validateStreetSegment(streetSegment));
    }
  );

  // stream and sink
  Stream<String> get nameBuildingStream => _nameBuildingSubject.stream.transform(nameBuildingValidation);
  Sink<String> get nameBuildingSink => _nameBuildingSubject.sink;

  Stream<String> get addressBuildingStream => _addressBuildingSubject.stream.transform(addressBuildingValidation);
  Sink<String> get addressBuildingSink => _addressBuildingSubject.sink;

  Stream<String> get imageBuildingStream => _imageBuildingSubject.stream.transform(imageBuildingValidation);
  Sink<String> get imageBuildingSink => _imageBuildingSubject.sink;

  Stream<String> get geomBuildingStream => _geomBuildingSubject.stream.transform(geomBuildingValidation);
  Sink<String> get geomBuildingSink => _geomBuildingSubject.sink;

  Stream<bool> get streetSegmentStream => _streetSegmentSubject.stream.transform(streetSegmentValidation);
  Sink<String> get streetSegmentSink => _streetSegmentSubject.sink;

  Stream<bool> get submitBuildingStream => _submitBuildingSubject.stream;
  Sink<bool> get submitBuildingSink => _submitBuildingSubject.sink;

  BuildingBehavior() {
    Rx.combineLatest5(
      _nameBuildingSubject,
      _addressBuildingSubject,
      _imageBuildingSubject,
      _geomBuildingSubject,
      _streetSegmentSubject,
        (buildingName, buildingAddress, imageBuilding, geomBuilding, streetsegment) {
          return BuildingValidation.validateName(buildingName) == null &&
            BuildingValidation.validateAddress(buildingAddress) == null &&
            BuildingValidation.validateImage(imageBuilding) == null &&
            BuildingValidation.validateGeom(geomBuilding) == null && 
            BuildingValidation.validateStreetSegment(streetsegment) == true;
        }
    ).listen(
      (enable) {
        _submitBuildingSubject.add(enable);
      }
    );
  }

  dispose() {
    _streetSegmentSubject.close();
    _nameBuildingSubject.close();
    _addressBuildingSubject.close();
    _imageBuildingSubject.close();
    _geomBuildingSubject.close();
    _submitBuildingSubject.close();
  }
}
