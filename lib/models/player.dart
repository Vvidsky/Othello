class Player {
  String? uid;
  String? username;
  int? color;

  Player({required this.uid, required this.username, required this.color});

  Player.fromJsonWithId(this.uid, Map<dynamic, dynamic> json) {
    username = json['username'];
    color = json['color'];
  }

  Map toJson() => {
    'uid': uid,
    'username': username,
    'color': color
  };
}