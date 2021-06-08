import 'dart:async';
import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class AnalysisBehavior {
  // behavior subject
  final _timeSlotSubject = BehaviorSubject<String>();
  final _primaryAgeSubject = BehaviorSubject<String>();
  final _potentialCustomerSubject = BehaviorSubject<String>();
  final _submitAnalysisSubject = BehaviorSubject<bool>();

  // validation
  var timeSlotValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (timeSlot, sink) {
      sink.add(AnalysisValidation.validateTimeSlot(timeSlot));
    }
  );

  var primaryAgeValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (primaryAge, sink) {
      sink.add(AnalysisValidation.validatePrimaryAge(primaryAge));
    }
  );

  var potentialCustomerValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (potentialCustomer, sink) {
      sink.add(AnalysisValidation.validatePotentialCustomer(potentialCustomer));
    }
  );

  Stream<String> get timeSlotStream => _timeSlotSubject.stream.transform(timeSlotValidation);
  Sink<String> get timeSlotSink => _timeSlotSubject.sink;

  Stream<String> get primaryAgeStream => _primaryAgeSubject.stream.transform(primaryAgeValidation);
  Sink<String> get primaryAgeSink => _primaryAgeSubject.sink;

  Stream<String> get potentialCustomerStream => _potentialCustomerSubject.stream.transform(potentialCustomerValidation);
  Sink<String> get potentialCustomerSink => _potentialCustomerSubject.sink;

  Stream<bool> get submitAnalysisStream => _submitAnalysisSubject.stream;
  Sink<bool> get submitAnalysisSink => _submitAnalysisSubject.sink;

  AnalysisBehavior() {
    Rx.combineLatest3(
      _timeSlotSubject,
      _primaryAgeSubject,
      _potentialCustomerSubject,
        (timeSlot, primaryAge, potentialCustomer) {
          return AnalysisValidation.validateTimeSlot(timeSlot) == null &&
            AnalysisValidation.validatePrimaryAge(primaryAge) == null &&
            AnalysisValidation.validatePotentialCustomer(potentialCustomer) == null;
        }
    ).listen(
      (enable) {
        _submitAnalysisSubject.add(enable);
      }
    );
  }

  dispose() {
    _timeSlotSubject.close();
    _primaryAgeSubject.close();
    _potentialCustomerSubject.close();
  }
}