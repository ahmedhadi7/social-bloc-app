/*
profile repository

*/
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<void> updateProfile(ProfileUser profileUser);
  Future<void> toggleFollow(String currentUid, String targetUid);
}