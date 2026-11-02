import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';
import 'package:social_bloc/features/profile/domin/repos/profile_repo.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_state.dart';
import 'package:social_bloc/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  //fetch user profile using repo -> useful for loading single profile pages
  Future<void> fetchProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(profileUser: user));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  //return user profile given uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  //update user profile using repo
  Future<void> updateProfile({
    required String uid,
    String? newName,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilepath,
    String? imageWebExtension,
  }) async {
    emit(ProfileLoading());

    try {
      //fetch current user profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch current user profile update"));
        return;
      }

      //profile picture update
      String? imageDownloadUrl;

      //ensure there is an image
      if (imageWebBytes != null || imageMobilepath != null) {
        //for mobile
        if (imageMobilepath != null) {
          //upload
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilepath,
            uid,
          );
        }
        //for web
        else if (imageWebBytes != null) {
          //upload
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
            imageWebExtension,
          );
        }
        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload profile picture"));
        }
      }

      //update new profile
      final updatedProfile = currentUser.copyWith(
        newName: newName ?? currentUser.name,
        newbio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      //update in repo
      await profileRepo.updateProfile(updatedProfile);

      //refetch updated profile
      await fetchProfileUser(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  // toggle follow/unfollow user
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
      //refetch updated profile
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }
}
