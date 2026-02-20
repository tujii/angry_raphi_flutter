import 'package:angry_raphi/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('NetworkInfoImpl', () {
    test('should return true when device is connected to wifi', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return true when device is connected to mobile data',
        () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return true when device is connected to ethernet', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return false when device has no connection', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, false);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should return true when device has multiple connections', () async {
      // arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test(
        'should return true when device has bluetooth connection (connected state)',
        () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });

    test('should handle VPN connections', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.vpn]);

      // act
      final result = await networkInfo.isConnected;

      // assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity());
    });
  });
}
