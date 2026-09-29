import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/spaces_repository.dart';

@injectable
class CreateSpace {
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;

  final SpacesRepository repository;

  CreateSpace(this.repository);

  Future<Either<Failure, String>> call(CreateSpaceParams params) async {
    final name = params.name.trim();
    if (name.isEmpty || name.length > maxNameLength) {
      return const Left(ValidationFailure(
          'Space name must be between 1 and $maxNameLength characters'));
    }
    final description = params.description?.trim();
    if (description != null && description.length > maxDescriptionLength) {
      return const Left(ValidationFailure(
          'Description must be at most $maxDescriptionLength characters'));
    }
    return repository.createSpace(CreateSpaceParams(
      name: name,
      description: (description?.isEmpty ?? true) ? null : description,
      ownerUid: params.ownerUid,
      ownerDisplayName: params.ownerDisplayName,
      ownerEmail: params.ownerEmail,
      ownerPhotoUrl: params.ownerPhotoUrl,
    ));
  }
}
