import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../countries/domain/repositories/recent_search_repository.dart';
import '../../../favorites/domain/favorites_repository.dart';
import '../../domain/repositories/auth_repository.dart';

class AccountState extends Equatable {
  const AccountState({this.isBusy = false, this.isDone = false, this.message});

  final bool isBusy;
  final bool isDone;
  final String? message;

  @override
  List<Object?> get props => [isBusy, isDone, message];
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._auth, this._favorites, this._recentSearches)
    : super(const AccountState());

  final AuthRepository _auth;
  final FavoritesRepository _favorites;
  final RecentSearchRepository _recentSearches;

  Future<void> signOut() async {
    emit(const AccountState(isBusy: true));
    await _auth.signOut();
    await _clearLocalData();
    if (!isClosed) {
      emit(const AccountState(isDone: true, message: 'Signed out'));
    }
  }

  Future<void> deleteAccount({String? password}) async {
    emit(const AccountState(isBusy: true));
    final result = await _auth.deleteAccount(password: password);
    if (isClosed) return;

    switch (result) {
      case Success():
        await _clearLocalData();
        if (!isClosed) {
          emit(
            const AccountState(
              isDone: true,
              message: 'Your account has been deleted',
            ),
          );
        }
      case Err(:final failure):
        emit(AccountState(message: failure.message));
    }
  }

  Future<void> _clearLocalData() async {
    await _favorites.clear();
    await _recentSearches.clear();
  }
}
