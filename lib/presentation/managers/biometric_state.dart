part of 'biometric_bloc.dart';

@immutable
sealed class BiometricState {}

class BiometricInitial extends BiometricState {}

// TODO: Add missing state classes.
/*
  The needed state are:
  - State to indicate authentication is in progress.
  - State to indicate authentication is success.
  - State to indicate authentication is fail.
*/

class BiometricAuthInProgress extends BiometricState{}
class BiometricAuthInSuccess extends BiometricState{}
class BiometricAuthInFail extends BiometricState{
  BiometricAuthInFail({this.message});
  final String? message;
}


