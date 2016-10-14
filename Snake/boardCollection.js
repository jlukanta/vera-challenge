var Board = require('./board');

function BoardCollection() {
  // FIXME: Currently server saves boards in an array because we assume that we won't have a lot 
  // of boards (say 100 max? or 1000? Still constant time). We may need to user a better data 
  // structure to quickly determine board with lowest participant count. If we are going to use
  // redis to support multiple processes/servers, we can use their sorted set feature.. 
  // However keep in mind that once we use redis, some things will run asychronously. Be careful!
  this.boards = [];
}

BoardCollection.prototype.createNewBoard = function() {
  var ID = this.generateID(7);
  return new Board(ID);
}

BoardCollection.prototype.removeBoardIfNoPlayers = function(boardToCheck) {
  if (boardToCheck.playersCount() == 0) {
    for (var i in this.boards) {
      var board = this.boards[i];
      if (boardToCheck.ID === board.ID) {
        this.boards.splice(i, 1);
        return;
      }
    }
  }
}

BoardCollection.prototype.assignBoardForPlayer = function() {
  var board = this.boardWithLowestPlayerCount();
  if (!board || board.playersCount() >= BoardCollection.MaxBoardSize()) {
    board = this.createNewBoard();
    this.boards.push(board);
  }
  return board;
}

BoardCollection.prototype.boardWithLowestPlayerCount = function() {
  if (this.boards.length === 0) {
    return null;
  }
  else {
    var minBoard = this.boards[0];
    var minCount = minBoard.playersCount();
    for (var i in this.boards) {
      var board = this.boards[i];
      var playersCount = board.playersCount();
      if (playersCount < minCount) {
        minBoard = board;
        minCount = playersCount;
      }
    }
    return minBoard;
  }
}

BoardCollection.prototype.generateID = function(length){
  // FIXME: I am hoping that this ID will be unique enough.. The possibility is low but probably not a good idea :(
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  for (var i = 0; i < length; i++) {
      text += possible.charAt(Math.floor(Math.random() * possible.length));
  }
  return text;
}

BoardCollection.MaxBoardSize = function() {
  return 10;
}

exports = module.exports = BoardCollection;