class Model
{
  final String id;
  final String name;
  final String avatar;
  final String birthdate;
  final String phone;
  final String address;

  Model({
    required this.id,
    required this.name,
    required this.avatar,
    required this.birthdate,
    required this.phone,
    required this.address,
});

  factory Model.fromJson(Map<String, dynamic> json)
  {
    return Model(id: json['id'],
        name: json['name'],
        avatar: json['avatar'],
        birthdate: json['birthdate'],
        phone: json['phone'],
        address: json['address']
    );
  }
}