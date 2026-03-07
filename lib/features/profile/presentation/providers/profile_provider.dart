import 'package:flutter/material.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_profile_image.dart';
import '../../domain/entities/user.dart';

enum ProfileStatus { initial, loading, loaded, updating, updated, uploading, error }

class ProfileProvider extends ChangeNotifier {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadProfileImage uploadProfileImage;

  ProfileStatus _status = ProfileStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _successMessage;

  ProfileProvider({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadProfileImage,
  });

  // Getters
  ProfileStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isUploading => _status == ProfileStatus.uploading;

  // Get profile
  Future<void> fetchProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await getProfile();
      _status = ProfileStatus.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = ProfileStatus.error;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? password,
    String? confirmPassword,
  }) async {
    _status = ProfileStatus.updating;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      _user = await updateProfile(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _status = ProfileStatus.updated;
      _successMessage = 'Profile updated successfully';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = ProfileStatus.error;
      notifyListeners();
    }
  }

  // Upload profile image
  Future<void> uploadImage(String imagePath) async {
    _status = ProfileStatus.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await uploadProfileImage(imagePath);
      _status = ProfileStatus.updated;
      _successMessage = 'Image uploaded successfully';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = ProfileStatus.error;
      notifyListeners();
    }
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
