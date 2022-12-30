import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  void contactsPressed() {
    emit(DashboardContacts());
  }

  void historyPressed() {
    emit(DashboardHistory());
  }

  void favoritesPressed() {
    emit(DashboardFavorites());
  }

  void searchPressed() {
    emit(DashboardSearch());
  }

  void addContactsPressed() {
    emit(DashboardAddContact());
  }
}
