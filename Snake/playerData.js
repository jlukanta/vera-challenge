function PlayerData(id, segments, direction, isIdle){
  this.ID = id;
  this.segments = segments;
  this.direction = direction;
  
  // User is idling when: (1) user just joined, assigned a board, but hasn't started playing
  //                      (2) user has lost but hasn't replayed the game
  // This flag is used to avoid issues when user is idling and server accidentally deletes the board because there is no other players.
  this.isIdle = isIdle;
}

exports = module.exports = PlayerData;