class Player {
  String? uid;
  String? username;
  int? color;

  Player({required this.uid, required this.username, required this.color});
  
  Player.fromJson(Map<dynamic, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    color = int.tryParse(json['color'].toString());
  }

  Player.fromJsonWithId(this.uid, Map<dynamic, dynamic> json) {
    username = json['username'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'color': color
  };
}