class RoomData {
  String? id;
  List<dynamic>? board;
  int? currentTurn;

  RoomData({required this.id, required this.board, required this.currentTurn});

  RoomData.fromJsonWithId(this.id, Map<dynamic, dynamic> json) {
    board = json['board'];
    currentTurn = int.tryParse(json['currentTurn'].toString());
  }

  RoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    board = json['board'];
    currentTurn = json['currentTurn'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'board': this.board,
      'currentTurn': this.currentTurn,
    };
  }
}
