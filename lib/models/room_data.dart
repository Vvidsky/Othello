class RoomData {
  String? id;
  List<dynamic>? board;
  int? currentTurn;
  int? numPossibleMoves;

  RoomData({required this.id, required this.board, required this.currentTurn, required this.numPossibleMoves});

  RoomData.fromJsonWithId(this.id, Map<dynamic, dynamic> json) {
    board = json['board'];
    currentTurn = int.tryParse(json['currentTurn'].toString());
    numPossibleMoves = int.tryParse(json['numPossibleMoves'].toString());
  }

  RoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    board = json['board'];
    currentTurn = json['currentTurn'];
    numPossibleMoves = json['numPossibleMoves'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'board': board,
      'currentTurn': currentTurn,
      'numPossibleMoves': numPossibleMoves,
    };
  }
}
