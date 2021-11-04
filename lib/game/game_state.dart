// Determine which page should be rendered when the game is running.
enum GameState {
  // Show begin screen
  begin,
  // Show setting screen
  setting,
  // Show history score screen
  history,
  // Show game playing screen
  playing,
  // Show game playing screen and pause menu
  pause,
  // Show game over screen
  gameOver,
}
