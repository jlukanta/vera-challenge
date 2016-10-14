var PlayerData = require('./playerData');
var PointData = require('./pointData');

var __ = require('underscore');

function Board(id){
  this.ID = id;
  this.playerIDToInfo = {};
  this.apples = [];
}

// returns a dictionary of playerID and playerInfo
// playerInfo = {id : string, segments : [points], direction : int}
// segments is an array of points, points = {x : int, y : int}
Board.prototype.playersInfo = function() {
  return this.playerIDToInfo;
}

Board.prototype.updatePlayer = function(ID, segments, direction, isIdle) {
  var player;
  if (ID in this.playerIDToInfo) {
    player = this.playerIDToInfo[ID];
    player.segments = segments;
    player.direction = direction;
    player.isIdle = isIdle;
  }
  else {
    player = new PlayerData(ID, segments, direction);
    this.playerIDToInfo[ID] = player;
  }
  return player;
}

Board.prototype.removePlayer = function(ID) {
  if (ID in this.playerIDToInfo) {
    delete this.playerIDToInfo[ID];
  }
}

Board.prototype.playersCount = function() {
  return __.size(this.playerIDToInfo);
}

Board.prototype.addApple = function(x,y) {
  this.apples.push(new PointData(x,y));
}

Board.prototype.removeApple = function(x,y) {
  // FIXME: This is pretty bad if we have a lot of apples
  // but I am assuming we are going to have a small number of
  // apples for now. Probably worth thinking about the correct
  // data structure later?
  for (var i in this.apples) {
    var apple = this.apples[i];
    if (apple.x === x && apple.y === y) {
      this.apples.splice(i, 1);
      return;
    }
  }
}

exports = module.exports = Board;