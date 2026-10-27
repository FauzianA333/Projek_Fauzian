class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  /// Membuat UserModel dari JSON response reqres.in.
  /// Nilai default dipakai karena response POST/PUT tidak selalu
  /// mengembalikan semua field (mis. avatar).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      email: (json['email'] ?? '') as String,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      avatar: (json['avatar'] ?? '') as String,
    );
  }

  /// Dipakai saat mengirim data (POST/PUT).
  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      };

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}