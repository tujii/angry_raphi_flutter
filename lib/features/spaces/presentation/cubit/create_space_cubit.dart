import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/create_space.dart';

abstract class CreateSpaceState extends Equatable {
  const CreateSpaceState();

  @override
  List<Object?> get props => [];
}

class CreateSpaceIdle extends CreateSpaceState {
  const CreateSpaceIdle();
}

class CreateSpaceSubmitting extends CreateSpaceState {
  const CreateSpaceSubmitting();
}

class CreateSpaceSuccess extends CreateSpaceState {
  final String spaceId;

  const CreateSpaceSuccess(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

class CreateSpaceFailure extends CreateSpaceState {
  final String message;

  const CreateSpaceFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateSpaceCubit extends Cubit<CreateSpaceState> {
  final CreateSpace _createSpace;

  CreateSpaceCubit(this._createSpace) : super(const CreateSpaceIdle());

  Future<void> submit(CreateSpaceParams params) async {
    if (state is CreateSpaceSubmitting) return;
    emit(const CreateSpaceSubmitting());
    final result = await _createSpace(params);
    emit(result.fold(
      (failure) => CreateSpaceFailure(failure.message),
      CreateSpaceSuccess.new,
    ));
  }
}
