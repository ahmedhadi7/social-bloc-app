/*

profile state 
*/
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';

abstract class ProfileState {}

//initial state
class ProfileInitial extends ProfileState {}

//loading state
class ProfileLoading extends ProfileState {}

//loaded state
class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;

  ProfileLoaded({required this.profileUser});
}

//error state
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
