import '../../domain/entities/user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded(this.user);
}

class ProfileUpdated extends ProfileState {
  final User user;
  ProfileUpdated(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
