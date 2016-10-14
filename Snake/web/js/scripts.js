/************************ POINT ***********************/

function Point(x,y) {
  this.x = x;
  this.y = y;
}

/*********************** PLAYER ***********************/

function Player(playerID, direction, snakeSegments, isIdle) {
  if (playerID) {
    this.ID = playerID;
  }
  this.direction = direction === null ? Player.Left() : direction;
  this.snakeSegments = snakeSegments === null ? [] : snakeSegments;
  if (isIdle == null) {
    isIdle = true;
  }
  this.isIdle = isIdle;
}

Player.prototype.resetSnakeSegments = function(headPosition){
  var segments = [headPosition];
  for (var i = 1; i < Player.OriginalSnakeLength(); i++) {
    var segment = new Point(headPosition.x + i, headPosition.y);
    segments.push(segment);
  }
  this.direction = Player.Left();
  this.snakeSegments = segments;
}

Player.prototype.advancePosition = function() {
  var firstSegment = new Point(this.snakeSegments[0].x, this.snakeSegments[0].y);
  switch(this.direction) {
    case Player.Up():
      firstSegment.y -= 1;
      break;
    case Player.Down():
      firstSegment.y += 1;
      break;
    case Player.Left():
      firstSegment.x -= 1;
      break;
    case Player.Right():
      firstSegment.x += 1;
      break;
  }
  this.snakeSegments.pop();
  this.snakeSegments.unshift(firstSegment);
}

Player.prototype.growSnake = function() {
  var lastIndex = this.snakeSegments.length - 1;
  if (lastIndex >= 0) {
    var lastSegment = new Point(this.snakeSegments[lastIndex].x, this.snakeSegments[lastIndex].y);
    // snake will grow on the next update coz the animation looks weird if I add a segment on the same cycle
    // it looks like it suddenly grow a tail... 
    this.snakeSegments.push(lastSegment);
  }
}

Player.prototype.setDirection = function(direction) {
  // FIXME: user can still go towards the opposite direction
  // eg. snake direction to the left, quickly tap down/up then left
  // result: snake dies because on next update the snake will hit itself.
  // Try to solve this problem later...
  switch(direction) {
    case Player.Up():
      if (this.direction === Player.Down()) return;
      break;
    case Player.Down():
      if (this.direction === Player.Up()) return;
      break;
    case Player.Left():
      if (this.direction === Player.Right()) return;
      break;
    case Player.Right():
      if (this.direction === Player.Left()) return;
      break;
  }
  this.direction = direction;
}

Player.Up = function() {
  return 0;
}
Player.Down = function() {
  return 1;
}
Player.Left = function() {
  return 2;
}
Player.Right = function() {
  return 3;
}
Player.OriginalSnakeLength = function() {
  return 4;
}

/************************ GAME ************************/

function Game() {
  this.playerIDToInfo = {};
  this.apples = []
}

Game.prototype.updatePlayer = function(player) {
  this.playerIDToInfo[player.ID] = player;
}

Game.prototype.removePlayer = function(ID) {
  if (ID in this.playerIDToInfo) {
    delete this.playerIDToInfo[ID];
  }
}

Game.prototype.removeApple = function(appleToRemove) {
  // FIXME: This is pretty bad if we have a lot of apples
  // but I am assuming we are going to have a small number of
  // apples for now. Probably worth thinking about the correct
  // data structure later?
  for (var i in this.apples) {
    var apple = this.apples[i];
    if (apple.x === appleToRemove.x && apple.y === appleToRemove.y) {
      this.apples.splice(i, 1);
      return;
    }
  }
}

Game.prototype.addApple = function(apple) {
  this.apples.push(apple);
}

Game.prototype.generateNewApple = function() {
  var applePoint = this.getFreePointInRadius(0,0);
  if (applePoint) {
    this.addApple(applePoint);
  }
  return applePoint;
}

Game.prototype.consumeApple = function(player) {
  var head = player.snakeSegments[0];
  for (var i in this.apples) {
    var apple = this.apples[i];
    if (this.isPointEqualsPoint(head, apple)) {
      this.apples.splice(i, 1);
      return apple;
    }
  }
  return null;
}

Game.prototype.getFreePointInRadius = function(radiusX, radiusY) {
  // FIXME: What will happen if there is no free point?
  var tryCount = 0;
  var maxTryCount = Game.BoardSize()*Game.BoardSize();
  var maxNumber = Game.BoardSize() - 1;
  do {
    var x = Math.floor(Math.random() * maxNumber);
    var y = Math.floor(Math.random() * maxNumber);
    var point = new Point(x,y);
    if (this.isSafePointFromPlayers(point, radiusX, radiusY) &&
        this.isSafePointFromApples(point, radiusX, radiusY)) {
      return point;
    }
    tryCount++;
  } while (tryCount < maxTryCount);
  return null;
}

Game.prototype.isSafePointFromApples = function(point, radiusX, radiusY) {
  for (var i in this.apples) {
    var apple = this.apples[i];
    if (!this.isSafePointFromPoint(point, apple, radiusX, radiusY)) {
        return false;
    }
  }
  return true;
}

Game.prototype.isSafePointFromPlayers = function(point, radiusX, radiusY) {
  for (var playerID in this.playerIDToInfo) {
    var player = this.playerIDToInfo[playerID];
    if (!this.isSafePointFromPlayer(point, radiusX, radiusY, player)) {
      return false;
    }
  }
  return true;
}

Game.prototype.isSafePointFromPlayer = function(point, radiusX, radiusY, player) {
  for (var i in player.snakeSegments) {
    var segment = player.snakeSegments[i];
    if (!this.isSafePointFromPoint(point, segment, radiusX, radiusY)) {
        return false;
    }
  }
  return true;
}

Game.prototype.isSafePointFromPoint = function(point1, point2, radiusX, radiusY) {
  return Math.abs(point1.x - point2.x) > radiusX && Math.abs(point1.y - point2.y) > radiusY;
}

Game.prototype.isPointEqualsPoint = function(point1, point2) {
  return point1.x === point2.x && point1.y === point2.y;
}

// this method assumes player will die when its HEAD hits board edge or other players or if it hits itself I guess...
Game.prototype.playerLost = function(player) {
  return this.playerHitsBoardEdge(player) || this.playerHitsItself(player) || this.playerHitsOtherPlayers(player);
}

Game.prototype.playerHitsBoardEdge = function(player) {
  var head = player.snakeSegments[0];
  return head.x < 0 || head.x >= Game.BoardSize() ||
         head.y < 0 || head.y >= Game.BoardSize();
}

Game.prototype.playerHitsItself = function(player) {
  var head = player.snakeSegments[0];
  var segmentCount = player.snakeSegments.length;
  return this.headHitsPlayer(head, player, false);
}

Game.prototype.playerHitsOtherPlayers = function(player) {
  var player1Head = player.snakeSegments[0];
  for (var playerID in this.playerIDToInfo) {
    if (player.ID !== playerID) {
      var otherPlayer = this.playerIDToInfo[playerID];
      if (this.headHitsPlayer(player1Head, otherPlayer, true)) {
        return true;
      }
    }
  }
  return false;
}

Game.prototype.headHitsPlayer = function(head, player, shouldCheckHead) {
  var segmentCount = player.snakeSegments.length;
  var i = shouldCheckHead ? 0 : 1;
  for (i; i < segmentCount; i++) {
    var segment = player.snakeSegments[i];
    if (this.isPointEqualsPoint(head, segment)) {
      return true;
    }
  }
  return false;
}

Game.prototype.resetGameData = function() {
  this.playerIDToInfo = {}; // remove all players
  this.apples = []; // remove all apples
}

Game.GameLoopInterval = function() {
  return 200; //ms
}
Game.NewAppleInterval = function() {
  return 10000; //ms
}
Game.BoardSize = function() {
  return 100;
}

/****************** REAL TIME ENGINE ******************/
function RealTimeEngine(){
  this.socket;
  this.boardID;
  this.connectedListener;
  this.initialDataListener;
  this.playerChangeListener;
  this.removePlayerListener;
  this.connectionLostListener;
  this.newAppleListener;
  this.eatenAppleListener;
}

RealTimeEngine.prototype.isConnected = function() {
  return this.socket.connected;
}

RealTimeEngine.prototype.connect = function() {
  var rtEngine = this;
  rtEngine.socket = io.connect('http://localhost:3000');
  rtEngine.socket.on('connect', function(data){
    if (rtEngine.connectedListener) {
      var userID = rtEngine.socket.id;
      rtEngine.connectedListener(userID);
    }
  });
  rtEngine.socket.on('initialData', function (initialData) {
    rtEngine.boardID = initialData.boardID;
    
    if (rtEngine.initialDataListener) {
      var playersDataDict = initialData.players;
      var apples = initialData.apples;
      var playersIDToObject = rtEngine._playersDataToObjects(playersDataDict);
      rtEngine.initialDataListener(playersIDToObject, apples);
    }
  });
  rtEngine.socket.on('updatePlayer', function(playerData){
    if (rtEngine.playerChangeListener) {
      var playerObject = rtEngine._playerDataToObject(playerData);
      if (playerObject) {
        rtEngine.playerChangeListener(playerObject);
      }
    }
  });
  rtEngine.socket.on('removePlayer', function(data){
    if (rtEngine.removePlayerListener && "ID" in data) {
      var ID = data.ID;
      rtEngine.removePlayerListener(ID);
    }
  });
  rtEngine.socket.on('newApple', function(data){
    if (rtEngine.newAppleListener) {
      var apple = new Point(data.x, data.y);
      rtEngine.newAppleListener(apple);
    }
  });
  rtEngine.socket.on('eatenApple', function(data){
    if (rtEngine.eatenAppleListener) {
      var apple = new Point(data.x, data.y);
      rtEngine.eatenAppleListener(apple);
    }
  });
  rtEngine.socket.on('disconnect', function(data){
    if (rtEngine.connectionLostListener) {
      rtEngine.connectionLostListener();
    }
  })
}

RealTimeEngine.prototype.updatePlayerData = function(player) {
  this.socket.emit('updatePlayer', { boardID : this.boardID, ID : player.ID, segments : player.snakeSegments, direction : player.direction, isIdle : player.isIdle });
}

RealTimeEngine.prototype.notifyNewApple = function(apple) {
  this.socket.emit('newApple', { x : apple.x, y : apple.y });
}

RealTimeEngine.prototype.notifyAppleEaten = function(apple) {
  this.socket.emit('eatenApple', { x : apple.x, y : apple.y });
}

// returns a dictionary of playerID -> playerData
RealTimeEngine.prototype._playersDataToObjects = function(playersDataDict) {
  var playerIDToObject = {};
  for (var playerID in playersDataDict) {
    var playerData = playersDataDict[playerID];
    var playerObj = this._playerDataToObject(playerData);
    if (playerObj) {
      playerIDToObject[playerID] = playerObj;
    }
  }
  return playerIDToObject;
}

// returns Player Object
RealTimeEngine.prototype._playerDataToObject = function(playerData) {
  if (playerData && "ID" in playerData && "segments" in playerData && "direction" in playerData && "isIdle") {
    var id = playerData.ID;
    var segments = playerData.segments;
    var direction = playerData.direction;
    var isIdle = playerData.isIdle;
    var player = new Player(id, direction, segments, isIdle);
    return player;
  }
  return null;
}

/******************** MAIN METHODS ********************/

function onLoadScript() {
  var game = new Game();
  var player = new Player(null, null, null, true);
  var realTimeEngine = new RealTimeEngine();

  // set up listeners
  $(this).keydown(function(e){
    listenKeyboardInput(e, player);
  });
  listenPlayButton(game, player, realTimeEngine);
  listenReconnectButton();
  listenRealTimeEngine(game, player, realTimeEngine);
  
  // let's get connected
  realTimeEngine.connect();
}

/****************** MAIN GAME LOGIC *******************/

function kickStartGame(game, player, realTimeEngine) {
  // hides user lost notification
  showUserLostNotification(false);
  
  // start up game
  // FIXME: This is a hack! I am trying to allocate the head where I can place some segments on the right side of the current head.
  // It shouldn't be done this way!! :(
  var radiusX = Math.ceil(Player.OriginalSnakeLength()/2);
  var radiusY = 0;
  var headPosition = game.getFreePointInRadius(radiusX, radiusY);
  headPosition.x -= radiusX;
  player.resetSnakeSegments(headPosition);
  player.isIdle = false;
  game.updatePlayer(player);

  // start game loop
  gameLoop(game, player, realTimeEngine, Game.NewAppleInterval()/2);
}

function gameLoop(game, player, realTimeEngine, timeoutUntilNewApple) {
  if (realTimeEngine.isConnected()) {
    player.advancePosition();
    var eatenApple = game.consumeApple(player);
    if (eatenApple) {
      player.growSnake();
      realTimeEngine.notifyAppleEaten(eatenApple);
    }
    
    if (timeoutUntilNewApple <= 0) {
      var applePoint = game.generateNewApple();
      if (applePoint) {
        realTimeEngine.notifyNewApple(applePoint);
      }
    }
    timeoutUntilNewApple -= Game.GameLoopInterval();
    
    render(game, player); 

    if (game.playerLost(player)) {
      player.isIdle = true;
      realTimeEngine.updatePlayerData(player);
      showUserLostNotification(true);
    }
    else {
      realTimeEngine.updatePlayerData(player);
      setTimeout(function(){
        timeoutUntilNewApple = timeoutUntilNewApple < 0 ? Game.NewAppleInterval() : timeoutUntilNewApple;
        gameLoop(game, player, realTimeEngine, timeoutUntilNewApple);
      }, Game.GameLoopInterval());
    }
  }
}

/*********************** RENDER ***********************/

function render(game, currentPlayer) {
  var boardCanvas = document.getElementById("gameBoardCanvas");
  var context = boardCanvas.getContext("2d");
  var canvasSize = boardCanvas.width;
  var tileSize = canvasSize / Game.BoardSize();
  
  context.save();
  
  // clear rect
  context.fillStyle = "black";
  context.fillRect(0,0,canvasSize,canvasSize)
  
  // render other things on board
  renderApples(context, game, tileSize);
  
  // render snakes
  renderSnakes(context, currentPlayer, game, tileSize);
  
  context.restore();
}

function renderSnakes(context, currentPlayer, game, tileSize) {
  for (var playerID in game.playerIDToInfo) {
    var player = game.playerIDToInfo[playerID];
    if (!player.isIdle) {
      var color = "#555555";
      if (player.ID === currentPlayer.ID) {
        color = "#00FFFF";
      }
      renderSnake(context, player, tileSize, color); 
    }
  }
}

function renderSnake(context, player, tileSize, color) {
  context.fillStyle = color;
  var snakeSegments = player.snakeSegments;
  for (var i in snakeSegments) {
    var segment = snakeSegments[i];
    renderPoint(context, segment, tileSize);
  }
}

function renderApples(context, game, tileSize) {
  context.fillStyle = "#FF0000";
  for (var i in game.apples) {
    var apple = game.apples[i];
    renderPoint(context, apple, tileSize);
  }
}

function renderPoint(context, point, tileSize) {
  context.fillRect(point.x*tileSize, point.y*tileSize, tileSize, tileSize);
}

/********************* LISTENERS **********************/

function listenRealTimeEngine(game, player, realTimeEngine) {
  realTimeEngine.connectedListener = function(userID){
    game.resetGameData();
    player.ID = userID;
    showDisconnectedNotification(false);
  };
  realTimeEngine.initialDataListener = function(playerIDToObject, apples) {
    game.playerIDToInfo = playerIDToObject; // update other players information
    game.apples = apples; // update apples location
    kickStartGame(game, player, realTimeEngine);
  };
  realTimeEngine.playerChangeListener = function(player) {
    game.updatePlayer(player);
  }
  realTimeEngine.removePlayerListener = function(ID) {
    game.removePlayer(ID);
  }
  realTimeEngine.newAppleListener = function(apple) {
    game.addApple(apple);
  }
  realTimeEngine.eatenAppleListener = function(apple) {
    game.removeApple(apple);
  }
  realTimeEngine.connectionLostListener = function() {
    game.resetGameData();
    showUserLostNotification(false);
    showDisconnectedNotification(true);
  }
}

function listenKeyboardInput(e, player) {
  if (player) {
    switch (e.keyCode) {
      case 38:
        player.setDirection(Player.Up());
        break;
      case 40:
        player.setDirection(Player.Down());
        break;
      case 37:
        player.setDirection(Player.Left());
        break;
      case 39:
        player.setDirection(Player.Right());
        break;
    }
  }
}

function listenPlayButton(game, player, realTimeEngine){
  $("#playButton").click(function(){
    if (player) {
      kickStartGame(game, player, realTimeEngine);
    }
  });
}

function showUserLostNotification(showNotif){
  var displayStyle = showNotif ? "block" : "none";
  document.getElementById("userLostDiv").style.display = displayStyle;
}

function listenReconnectButton() {
  $("#reconnectButton").click(function(){
    if (!realTimeEngine.isConnected) {
      realTimeEngine.connect(); 
    }
  });
}

function showDisconnectedNotification(showNotif){
  var displayStyle = showNotif ? "block" : "none";
  document.getElementById("disconnectedDiv").style.display = displayStyle;
}