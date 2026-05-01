class Member {
  final int id;
  String name, email, phone, gender, dob, address, initials;
  String weight, height, bloodType, note;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.address,
    required this.initials,
    this.weight = '',
    this.height = '',
    this.bloodType = '',
    this.note = '',
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String fullName = (json['name'] ?? '').toString();
    final parts = fullName.trim().split(' ');
    final initials = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    return Member(
      id: json['id'] ?? 0,
      name: fullName,
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      dob: (json['dob'] ?? json['dateOfBirth'] ?? '')
          .toString()
          .split('T')
          .first,
      address: (json['address'] ?? '').toString(),
      initials: initials,
      weight: (json['weight'] ?? '').toString(),
      height: (json['height'] ?? '').toString(),
      bloodType: (json['bloodType'] ?? '').toString(),
      note: (json['note'] ?? json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phone,
    'gender': gender,
    'dateOfBirth': dob.isEmpty ? null : dob,
    'address': address,
    'weight': weight,
    'height': height,
    'bloodType': bloodType,
    'note': note,
  };
}
