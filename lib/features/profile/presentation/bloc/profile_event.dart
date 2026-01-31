abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;
  final String? password;
  final String? confirmPassword;

  UpdateProfileEvent({
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword,
  });
}

class UploadProfileImageEvent extends ProfileEvent {
  final String imagePath;
  UploadProfileImageEvent(this.imagePath);
}
