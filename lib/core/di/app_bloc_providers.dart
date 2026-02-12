import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iv_dashboard_project_web_app/pages/dashboard/cubit/invited_guest_form_cubit.dart';
import 'package:iv_project_core/iv_project_core.dart';
import 'package:iv_project_web_data/iv_project_web_data.dart';

class AppBlocProvider {
  AppBlocProvider._();

  static final dataProviders = <BlocProvider>[BlocProvider<InvitedGuestCubit>(create: (_) => InvitedGuestCubit())];

  static final uiAndCacheProviders = <BlocProvider>[BlocProvider<InvitedGuestFormCubit>(create: (_) => InvitedGuestFormCubit())];

  static final globalProviders = <BlocProvider>[BlocProvider<LocaleCubit>(lazy: false, create: (_) => LocaleCubit())];
}
