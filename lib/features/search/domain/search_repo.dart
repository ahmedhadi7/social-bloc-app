import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> searchUsers (String query);
}