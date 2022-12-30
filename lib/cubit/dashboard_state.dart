part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardFavorites extends DashboardState {}

class DashboardContacts extends DashboardState {}

class DashboardHistory extends DashboardState {}

class DashboardSearch extends DashboardState {}

class DashboardAddContact extends DashboardState {}
