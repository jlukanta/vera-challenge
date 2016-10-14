var BoardCollection = require('./boardCollection');
var Board = require('./board');
var PointData = require('./pointData');

var http = require('http');
var express = require('express');
var app = module.exports.app = express();
var server = http.createServer(app);
var io = require('socket.io').listen(server);

app.get('/js/:scriptname', function(req, res){
  var scriptname = req.params.scriptname;
  res.sendFile(__dirname + '/web/js/' + scriptname);
});

app.get('/css/:cssname', function (req, res) {
  var cssname = req.params.cssname;
  res.sendFile(__dirname + '/web/css/' + cssname);
});

app.get('/', function (req, res) {
  res.sendFile(__dirname + '/web/index.html');
});

server.listen(3000);

var boardCollection = new BoardCollection();

io.on('connection', function (socket) {
  var playerID = socket.id;
  var board = boardCollection.assignBoardForPlayer();
  var boardID = board.ID;
  board.updatePlayer(playerID, null, null, true); // temporarily assign idle user to board
  
  socket.join(boardID);
  socket.emit('initialData', { players : board.playerIDToInfo, boardID : boardID, apples : board.apples });
  
  socket.on('updatePlayer', function(data) {
    if ("ID" in data && "segments" in data && "direction" in data && "isIdle" in data) {
      var playerData = board.updatePlayer(data.ID, data.segments, data.direction, data.isIdle);
      socket.broadcast.to(boardID).emit('updatePlayer', playerData);
    }
  });
  socket.on('newApple', function(data) {
    board.addApple(data.x, data.y);
    socket.broadcast.to(boardID).emit('newApple', { x : data.x, y : data.y });
  });
  socket.on('eatenApple', function(data) {
    board.removeApple(data.x, data.y);
    socket.broadcast.to(boardID).emit('eatenApple', { x : data.x, y : data.y });
  });
  socket.on('disconnect', function(data) {
    board.removePlayer(playerID);
    socket.broadcast.to(boardID).emit('removePlayer', { ID : playerID });
    boardCollection.removeBoardIfNoPlayers(board);
  });
});