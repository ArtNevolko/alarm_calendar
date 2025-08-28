import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Language Events
abstract class LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final Locale locale;
  ChangeLanguageEvent(this.locale);
}

class LoadLanguageEvent extends LanguageEvent {}

// Language State
class LanguageState {
  final Locale locale;

  const LanguageState({required this.locale});

  LanguageState copyWith({Locale? locale}) {
    return LanguageState(locale: locale ?? this.locale);
  }
}

// Language Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState(locale: Locale('ru'))) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<LoadLanguageEvent>(_onLoadLanguage);
  }

  void _onChangeLanguage(
      ChangeLanguageEvent event, Emitter<LanguageState> emit) async {
    emit(state.copyWith(locale: event.locale));
  }

  void _onLoadLanguage(
      LoadLanguageEvent event, Emitter<LanguageState> emit) async {
    emit(state.copyWith(locale: const Locale('ru')));
  }
}
