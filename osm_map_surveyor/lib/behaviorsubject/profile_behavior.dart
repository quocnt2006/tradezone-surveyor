import 'dart:async';

import 'package:osm_map_surveyor/utilities/validation.dart';
import 'package:rxdart/rxdart.dart';

class ProfileBehavior {
  // behavior subject
  final _fullnameSubject = BehaviorSubject<String>();
  final _phoneNumberSubject = BehaviorSubject<String>();
  final _submitSubject = BehaviorSubject<bool>();

  // validation
  var fullnameValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (fullname, sink) {
      sink.add(ProfileValidation.validateFullname(fullname));
    }
  );

  var phoneNumberValidation = StreamTransformer<String, String>.fromHandlers(
    handleData: (phoneNumber, sink) {
      sink.add(ProfileValidation.validatePhoneNumber(phoneNumber));
    }
  );

  // stream and sink
  Stream<String> get fullnameStream => _fullnameSubject.stream.transform(fullnameValidation);
  Sink<String> get fullnameSink => _fullnameSubject.sink;

  Stream<String> get phoneNumberStream => _phoneNumberSubject.stream.transform(phoneNumberValidation);
  Sink<String> get phoneNumberSink => _phoneNumberSubject.sink;

  Stream<bool> get submitStream => _submitSubject.stream;
  Sink<bool> get submitSink => _submitSubject.sink;

  ProfileBehavior() {
    Rx.combineLatest2(
      _fullnameSubject, 
      _phoneNumberSubject, 
        (fullname, phonenumber) {
          return ProfileValidation.validateFullname(fullname) == null &&
            ProfileValidation.validatePhoneNumber(phonenumber) == null;
        }
    ).listen(
      (enable) {
        _submitSubject.add(enable);
      }
    );
  }

  dispose() {
    _fullnameSubject.close();
    _phoneNumberSubject.close();
  }
}