import 'dart:async';

import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class StoreBehavior {
  // behavior subject
  final _nameStoreSubject = BehaviorSubject<String>();
  final _timeSlotStoreSubject = BehaviorSubject<String>();
  final _abilityToServeSubject = BehaviorSubject<String>();
  final _addressStoreSubject = BehaviorSubject<String>();
  final _imageStoreSubject = BehaviorSubject<String>();
  final _geomStoreSubject = BehaviorSubject<String>();
  final _submitStoreSubject = BehaviorSubject<bool>();

  // validation
  var nameStoreValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      sink.add(StoreValidation.validateName(name));
    }
  );

  var timeSlotValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (timeSlot, sink) {
      sink.add(StoreValidation.validateTimeSlot(timeSlot));
    }
  );

  var abilityToServeValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (ability, sink) {
      sink.add(StoreValidation.validateAbilityToServe(ability));
    }
  );

  var addressStoreValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (address, sink) {
      sink.add(StoreValidation.validateAddress(address));
    }
  );

  var imageStoreValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (image, sink) {
      sink.add(StoreValidation.validateImage(image));
    }
  );

  var geomStoreValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (geom, sink) {
      sink.add(StoreValidation.validateGeom(geom));
    }
  );

  // stream and sink
  Stream<String> get nameStoreStream => _nameStoreSubject.stream.transform(nameStoreValidation);
  Sink<String> get nameStoreSink => _nameStoreSubject.sink;

  Stream<String> get timeSlotStream => _timeSlotStoreSubject.stream.transform(timeSlotValidation);
  Sink<String> get timeSlotSink => _timeSlotStoreSubject.sink;

  Stream<String> get abilityToServeStream => _abilityToServeSubject.stream.transform(abilityToServeValidation);
  Sink<String> get abilityToServeSink => _abilityToServeSubject.sink;

  Stream<String> get addressStoreStream => _addressStoreSubject.stream.transform(addressStoreValidation);
  Sink<String> get addressStoreSink => _addressStoreSubject.sink;

  Stream<String> get imageStoreStream => _imageStoreSubject.stream.transform(imageStoreValidation);
  Sink<String> get imageStoreSink => _imageStoreSubject.sink;

  Stream<String> get geomStoreStream => _geomStoreSubject.stream.transform(geomStoreValidation);
  Sink<String> get geomStoreSink => _geomStoreSubject.sink;

  Stream<bool> get submitStoreStream => _submitStoreSubject.stream;
  Sink<bool> get submitStoreSink => _submitStoreSubject.sink;

  StoreBehavior() {
    Rx.combineLatest6(
      _nameStoreSubject,
      _timeSlotStoreSubject, 
      _abilityToServeSubject,
      _addressStoreSubject, 
      _imageStoreSubject,
      _geomStoreSubject,
        (storeName, timeSlot, ability, storeAddress, storeImage, storeGeom) {
      return StoreValidation.validateName(storeName) == null &&
          StoreValidation.validateTimeSlot(timeSlot) == null &&
          StoreValidation.validateAbilityToServe(ability) == null &&
          StoreValidation.validateAddress(storeAddress) == null &&
          StoreValidation.validateImage(storeImage) == null &&
          StoreValidation.validateGeom(storeGeom) == null;
    }).listen((enable) {
      _submitStoreSubject.add(enable);
    });
  }

  dispose() {
    _nameStoreSubject.close();
    _timeSlotStoreSubject.close();
    _abilityToServeSubject.close();
    _addressStoreSubject.close();
    _imageStoreSubject.close();
    _geomStoreSubject.close();
    _submitStoreSubject.close();
  }
}