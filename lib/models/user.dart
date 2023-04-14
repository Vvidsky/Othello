class User{
  String? uid;
  String? email;
  String? username;
  DateTime? createdAt;

  User({required this.uid, required this.email, required this.username, required this.createdAt});

  User.fromJsonWithId(this.uid, Map<dynamic, dynamic> json) {
    email = json['email'];
    username = json['username'];
    createdAt = json['createdAt'];
  }
}