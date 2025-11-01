part of 'sales_card_bloc.dart';

sealed class SalesCardEvent extends Equatable {
  const SalesCardEvent();

  @override
  List<Object> get props => [];
}

final class SalesCardStartedEvent extends SalesCardEvent{
  
}
