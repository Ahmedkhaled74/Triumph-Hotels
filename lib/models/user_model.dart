class UserModel {
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? nationality;
  final String? avatar;

  UserModel({
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.nationality,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      nationality: json['nationality'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'nationality': nationality,
      'avatar': avatar,
    };
  }

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? nationality,
    String? avatar,
  }) {
    return UserModel(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      avatar: avatar ?? this.avatar,
    );
  }
}
