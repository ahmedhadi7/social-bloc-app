import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/search/domain/search_repo.dart';
import 'package:social_bloc/features/search/presentation/cubits/search_states.dart';

class SearchCubits extends Cubit<SearchStates> {
  final SearchRepo searchRepo;
  SearchCubits(this.searchRepo) : super(SearchInitial());

  Future<void> searchUser(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUsers(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
