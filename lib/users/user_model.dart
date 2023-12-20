import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String displayName;
  final String? bio;

  const UserModel(
      {required this.id, required this.displayName, required this.bio});

  @override
  List<Object?> get props => [id, displayName, bio];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      displayName: json['displayName'],
      bio: json['bio'],
    );
  }
}
