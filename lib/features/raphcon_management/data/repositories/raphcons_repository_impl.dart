import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/raphcon_entity.dart';
import '../../domain/repositories/raphcons_repository.dart';
import '../datasources/raphcons_remote_datasource.dart';

@Injectable(as: RaphconsRepository)
class RaphconsRepositoryImpl implements RaphconsRepository {
  final RaphconsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RaphconsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RaphconEntity>>> getUserRaphcons(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final raphconModels = await remoteDataSource.getUserRaphcons(userId);
        return Right(raphconModels);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<RaphconEntity>>> getAllRaphcons() async {
    if (await networkInfo.isConnected) {
      try {
        final raphconModels = await remoteDataSource.getAllRaphcons();
        return Right(raphconModels);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addRaphcon(AddRaphconParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addRaphcon(
          params.userId,
          params.createdBy,
          params.comment,
          params.type,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteRaphcon(String raphconId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteRaphcon(raphconId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
