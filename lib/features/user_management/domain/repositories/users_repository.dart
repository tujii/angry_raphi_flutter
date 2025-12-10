import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/person_entity.dart';

class AddPersonParams {
  final String name;
  final String? description;
  final File? imageFile;

  AddPersonParams({
    required this.name,
    this.description,
    this.imageFile,
  });
}

class UpdatePersonParams {
  final String id;
  final String? name;
  final String? description;
  final File? imageFile;

  UpdatePersonParams({
    required this.id,
    this.name,
    this.description,
    this.imageFile,
  });
}

abstract class UsersRepository {
  Stream<Either<Failure, List<PersonEntity>>> getAllPersons();
  Future<Either<Failure, PersonEntity>> getPersonById(String id);
  Future<Either<Failure, void>> addPerson(AddPersonParams params);
  Future<Either<Failure, void>> updatePerson(UpdatePersonParams params);
  Future<Either<Failure, void>> deletePerson(String id);
}
