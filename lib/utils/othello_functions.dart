const int itemEmpty = 0;
const int itemWhite = 1;
const int itemBlack = 2;
List<List<int>> table = [];

int checkWinner(int countItemBlack, int countItemWhite) {
  if (countItemBlack == countItemWhite) return -1;
  if (countItemBlack > countItemWhite) return itemBlack;
  if (countItemWhite > countItemBlack) return itemWhite;
  return itemEmpty;
}

int inverseItem(int item) {
  if (item == itemWhite) {
    return itemBlack;
  } else if (item == itemBlack) {
    return itemWhite;
  }
  return item;
}

  String convertColorCode(int code) {
    if (code == itemBlack) {
      return "Black";
    }
    if (code == itemWhite) {
      return "White";
    }
    return "None";
  }