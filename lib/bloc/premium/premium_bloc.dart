import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class PremiumEvent {}

class ActivatePremiumEvent extends PremiumEvent {}

class DeactivatePremiumEvent extends PremiumEvent {}

class CheckPremiumStatusEvent extends PremiumEvent {}

// State
class PremiumState {
  final bool isPremium;
  final DateTime? premiumActivatedAt;

  const PremiumState({
    this.isPremium = false,
    this.premiumActivatedAt,
  });

  PremiumState copyWith({
    bool? isPremium,
    DateTime? premiumActivatedAt,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      premiumActivatedAt: premiumActivatedAt ?? this.premiumActivatedAt,
    );
  }
}

// Bloc
class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  PremiumBloc() : super(const PremiumState()) {
    on<CheckPremiumStatusEvent>(_onCheckPremiumStatus);
    on<ActivatePremiumEvent>(_onActivatePremium);
    on<DeactivatePremiumEvent>(_onDeactivatePremium);
  }

  void _onCheckPremiumStatus(CheckPremiumStatusEvent event, Emitter<PremiumState> emit) {
    // Check premium status logic here
  }

  void _onActivatePremium(ActivatePremiumEvent event, Emitter<PremiumState> emit) {
    emit(state.copyWith(
      isPremium: true,
      premiumActivatedAt: DateTime.now(),
    ));
  }

  void _onDeactivatePremium(DeactivatePremiumEvent event, Emitter<PremiumState> emit) {
    emit(state.copyWith(
      isPremium: false,
      premiumActivatedAt: null,
    ));
  }
}
