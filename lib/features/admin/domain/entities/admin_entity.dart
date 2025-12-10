import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool isActive;

  const AdminEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.isActive,
  });

  @override
  List<Object> get props => [
        id,
        email,
        displayName,
        createdAt,
        isActive,
      ];
}
