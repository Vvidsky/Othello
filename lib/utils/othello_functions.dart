import '../models/coordinate.dart';

const int ITEM_EMPTY = 0;
const int ITEM_WHITE = 1;
const int ITEM_BLACK = 2;
List<List<int>> table = [];
List<Coordinate> checkRight(int row, int col, int item) {
  List<Coordinate> list = [];
  if (col + 1 < 8) {
    for (int c = col + 1; c < 8; c++) {
      if (table[row][c] == item) {
        return list;
      } else if (table[row][c] == ITEM_EMPTY) {
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
      if (table[row][c] == item) {
        return list;
      } else if (table[row][c] == ITEM_EMPTY) {
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
      if (table[r][col] == item) {
        return list;
      } else if (table[r][col] == ITEM_EMPTY) {
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
      if (table[r][col] == item) {
        return list;
      } else if (table[r][col] == ITEM_EMPTY) {
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
      if (table[r][c] == item) {
        return list;
      } else if (table[r][c] == ITEM_EMPTY) {
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
      if (table[r][c] == item) {
        return list;
      } else if (table[r][c] == ITEM_EMPTY) {
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
      if (table[r][c] == item) {
        return list;
      } else if (table[r][c] == ITEM_EMPTY) {
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
      if (table[r][c] == item) {
        return list;
      } else if (table[r][c] == ITEM_EMPTY) {
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
