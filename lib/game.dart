import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage(this.title, {super.key});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class BlockUnit{
  int value;

  BlockUnit({this.value = 0});
}

class Coordinate{
  int row;
  int col;

  Coordinate({required this.row, required this.col});
}

  

const double BLOCK_SIZE = 40;
const int ITEM_EMPTY = 0;
const int ITEM_WHITE = 1;
const int ITEM_BLACK = 2;


class _MyHomePageState extends State<GamePage> {

  List<List<BlockUnit>> table = [];
  int currentTurn = ITEM_BLACK;
  int countItemWhite = 0;
  int countItemBlack = 0;
  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Color(0xfffbf9f3),
          child: Center(
            child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff34495e),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 6, color: Color(0xff2c3e50))),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildTable()
                )),
          )),
    );
  }

  List<Row> buildTable() {
    List<Row> listRow = [];
    for (int row = 0; row < 8; row++) {
      List<Widget> listCol = [];
      for (int col = 0; col < 8; col++) {
        listCol.add(buildBlockUnit(row, col));
      }
      Row rowWidget = Row(mainAxisSize: MainAxisSize.min, children: listCol);
      listRow.add(rowWidget);
    }
    return listRow;
  }

  Widget buildBlockUnit(int row, int col) {
    return GestureDetector(
        onTap: () {
          setState(() {
            pasteItemToTable(row, col, currentTurn);
          });
        }, child: Container(
      decoration: BoxDecoration(
        color: Color(0xff27ae60),
        borderRadius: BorderRadius.circular(2),
      ),
      width: BLOCK_SIZE,
      height: BLOCK_SIZE,
      margin: EdgeInsets.all(2),
      child: Center(child: buildItem(table[row][col])),
    ));
  }

  Widget buildItem(BlockUnit block){
    if(block.value == ITEM_BLACK){
      return Container(width: 30, height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black));
    }else if(block.value == ITEM_WHITE){
      return Container(width: 30, height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white));
    }
    return Container();
  }

   @override
  void initState() {
    initTable();
    initTableItems();
    super.initState();
  }

  void initTable() {
    table = [];
    for (int row = 0; row < 8; row++) {
      List<BlockUnit> list = [];
      for (int col = 0; col < 8; col++) {
        list.add(BlockUnit(value: ITEM_EMPTY));
      }
      table.add(list);
    }
  } 
  
  void initTableItems() {
    table[3][3].value = ITEM_WHITE;
    table[4][3].value = ITEM_BLACK;
    table[3][4].value = ITEM_BLACK;
    table[4][4].value = ITEM_WHITE;
  }

     bool pasteItemToTable(int row, int col, int item) {
    if (table[row][col].value == ITEM_EMPTY) {
      List<Coordinate> listCoordinate = [];
      listCoordinate.addAll(checkRight(row, col, item));
      listCoordinate.addAll(checkDown(row, col, item));
      listCoordinate.addAll(checkLeft(row, col, item));
      listCoordinate.addAll(checkUp(row, col, item));
      listCoordinate.addAll(checkUpLeft(row, col, item));
      listCoordinate.addAll(checkUpRight(row, col, item));
      listCoordinate.addAll(checkDownLeft(row, col, item));
      listCoordinate.addAll(checkDownRight(row, col, item));

      if (listCoordinate.isNotEmpty) {
        table[row][col].value = item;
        inverseItemFromList(listCoordinate);
        currentTurn = inverseItem(currentTurn);
        updateCountItem();
        return true;
      }
    }
    return false;
  }

  List<Coordinate> checkRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (col + 1 < 8) {
      for (int c = col + 1; c < 8; c++) {
        if (table[row][c].value == item) {
          return list;
        } else if (table[row][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: row, col: c));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (col - 1 >= 0) {
      for (int c = col - 1; c >= 0; c--) {
        if (table[row][c].value == item) {
          return list;
        } else if (table[row][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: row, col: c));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkDown(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8) {
      for (int r = row + 1; r < 8; r++) {
        if (table[r][col].value == item) {
          return list;
        } else if (table[r][col].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: col));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkUp(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0) {
      for (int r = row - 1; r >= 0; r--) {
        if (table[r][col].value == item) {
          return list;
        } else if (table[r][col].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: col));
        }
      }
    }
    return [];
  }

  List<Coordinate> checkUpLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0 && col - 1 >= 0) {
      int r = row - 1;
      int c = col - 1;
      while (r >= 0 && c >= 0) {
        if (table[r][c].value == item) {
          return list;
        } else if (table[r][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r--;
        c--;
      }
    }
    return [];
  }

  List<Coordinate> checkUpRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row - 1 >= 0 && col + 1 < 8) {
      int r = row - 1;
      int c = col + 1;
      while (r >= 0 && c < 8) {
        if (table[r][c].value == item) {
          return list;
        } else if (table[r][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r--;
        c++;
      }
    }
    return [];
  }

  List<Coordinate> checkDownLeft(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8 && col - 1 >= 0) {
      int r = row + 1;
      int c = col - 1;
      while (r < 8 && c >= 0) {
        if (table[r][c].value == item) {
          return list;
        } else if (table[r][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r++;
        c--;
      }
    }
    return [];
  }

  List<Coordinate> checkDownRight(int row, int col, int item) {
    List<Coordinate> list = [];
    if (row + 1 < 8 && col + 1 < 8) {
      int r = row + 1;
      int c = col + 1;
      while (r < 8 && c < 8) {
        if (table[r][c].value == item) {
          return list;
        } else if (table[r][c].value == ITEM_EMPTY) {
          return [];
        } else {
          list.add(Coordinate(row: r, col: c));
        }
        r++;
        c++;
      }
    }
    return [];
  }

  void inverseItemFromList(List<Coordinate> list) {
    for (Coordinate c in list) {
      table[c.row][c.col].value = inverseItem(table[c.row][c.col].value);
    }
  }

  int inverseItem(int item) {
    if (item == ITEM_WHITE) {
      return ITEM_BLACK;
    } else if (item == ITEM_BLACK) {
      return ITEM_WHITE;
    }
    return item;
  }

  void updateCountItem() {
    countItemBlack = 0;
    countItemWhite = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (table[row][col].value == ITEM_BLACK) {
          countItemBlack++;
        } else if (table[row][col].value == ITEM_WHITE) {
          countItemWhite++;
        }
      }
    }
  }

  void restart() {
    setState(() {
      countItemWhite = 0;
      countItemBlack = 0;
      currentTurn = ITEM_BLACK;
      initTable();
      initTableItems();
    });
  }

}