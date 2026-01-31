import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_profile_image.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadProfileImage uploadProfileImage;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadProfileImage,
  }) : super(ProfileInitial()) {
    
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await getProfile();
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      final prevState = state;
      emit(ProfileLoading());
      try {
        final user = await updateProfile(
          name: event.name,
          email: event.email,
          password: event.password,
          confirmPassword: event.confirmPassword,
        );
        emit(ProfileUpdated(user));
      } catch (e) {
        if (prevState is ProfileLoaded) emit(prevState);
        if (prevState is ProfileUpdated) emit(prevState);
        emit(ProfileError(e.toString()));
      }
    });

    on<UploadProfileImageEvent>((event, emit) async {
      final prevState = state;
      emit(ProfileLoading());
      try {
        final user = await uploadProfileImage(event.imagePath);
        // Keep _selectedImage as temporary preview
        emit(ProfileUpdated(user));
      } catch (e) {
        if (prevState is ProfileLoaded) emit(prevState);
        if (prevState is ProfileUpdated) emit(prevState);
        emit(ProfileError(e.toString()));
      }
    });
  }
}
