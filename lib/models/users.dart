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
}