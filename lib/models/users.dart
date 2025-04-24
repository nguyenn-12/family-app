class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime dob;
  final String pass;
  final String avatar;
  final String familyCode;
  final String gender;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.dob,
    required this.pass,
    required this.avatar,
    required this.familyCode,
    required this.gender,
  });
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? dob,
    String? pass,
    String? avatar,
    String? familyCode,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      pass: pass ?? this.pass,
      avatar: avatar ?? this.avatar,
      familyCode: familyCode ?? this.familyCode,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'dob': dob.toIso8601String(),
      'pass': pass,
      'avatar': avatar,
      'familyCode': familyCode,
      'gender': gender,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      dob: DateTime.parse(map['dob']),
      pass: map['pass'] ?? '', // Nếu đăng nhập GG thì có thể không có pass
      avatar: map['avatar'] ?? '',
      familyCode: map['familyCode'] ?? '',
      gender: map['gender'] ?? 'Other',
    );
  }


}