class FamilyModel {
  final String id;
  final String createdBy; // user ID
  final int numMember;
  final DateTime dateCreate;

  FamilyModel({
    required this.id,
    required this.createdBy,
    required this.numMember,
    required this.dateCreate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'numMember': numMember,
      'dateCreate': dateCreate.toIso8601String(),
    };
  }

  factory FamilyModel.fromMap(Map<String, dynamic> map) {
    return FamilyModel(
      id: map['id'],
      createdBy: map['createdBy'],
      numMember: map['numMember'],
      dateCreate: DateTime.parse(map['dateCreate']),
    );
  }
}