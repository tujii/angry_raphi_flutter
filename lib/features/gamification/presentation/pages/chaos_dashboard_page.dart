import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/network/network_info.dart';
import '../../data/datasources/gamification_remote_datasource.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../domain/usecases/add_hardware_fail.dart';
import '../../domain/usecases/generate_user_story.dart';
import '../../domain/usecases/get_user_chaos_points.dart';
import '../../domain/usecases/get_user_chaos_points_stream.dart';
import '../../domain/usecases/get_latest_story_stream.dart';
import '../bloc/gamification_bloc.dart';
import '../widgets/chaos_dashboard.dart';

/// Page that displays the chaos dashboard with BLoC provider
class ChaosDashboardPage extends StatelessWidget {
  const ChaosDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chaos Dashboard'),
        ),
        body: const Center(
          child: Text('Please login to view your Chaos Dashboard'),
        ),
      );
    }

    return BlocProvider(
      create: (context) {
        final firestore = FirebaseFirestore.instance;
        final connectivity = Connectivity();
        final networkInfo = NetworkInfoImpl(connectivity);
        final dataSource = GamificationRemoteDataSourceImpl(firestore);
        final repository = GamificationRepositoryImpl(
          remoteDataSource: dataSource,
          networkInfo: networkInfo,
        );

        return GamificationBloc(
          addHardwareFailUseCase: AddHardwareFail(repository),
          generateUserStoryUseCase: GenerateUserStory(repository),
          getUserChaosPointsUseCase: GetUserChaosPoints(repository),
          getUserChaosPointsStreamUseCase: GetUserChaosPointsStream(repository),
          getLatestStoryStreamUseCase: GetLatestStoryStream(repository),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chaos Dashboard'),
        ),
        body: SingleChildScrollView(
          child: ChaosDashboard(
            userId: currentUser.uid,
            userName: currentUser.displayName ?? 'User',
          ),
        ),
      ),
    );
  }
}
