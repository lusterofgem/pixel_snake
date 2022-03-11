import "dart:math";
import "dart:ui";

import "package:flame/flame.dart";
import "package:flame/game.dart";
import "package:flame/input.dart";
import "package:flame/sprite.dart";
import "package:flutter/material.dart" as material;
import "package:flutter/services.dart";
import "package:flutter/widgets.dart" as widgets;

import "game/colorball.dart";
import "game/direction.dart";
import "game/food.dart";
import "game/history_record.dart";
import "game/snake_game.dart";
// import "game/snake_unit.dart";
import "ui/animations.dart";
import "ui/button.dart";

class PixelSnake with Loadable, Game, PanDetector, TapDetector, KeyboardEvents{
  static Image? _logoImage;
  static Image? _settingBackgroundImage;
  static Image? _historyBackgroundImage;
  static Image? _gameOverBackgroundImage;
  static Image? _volumeImage;
  static Image? _speedImage;
  static Image? _foodImage;
  static Image? _checkboxImage;
  static Image? _checkImage;
  static Image? _horizontalDragBarImage;
  static Image? _horizontalDragBarCalibrateImage;
  static Image? _horizontalDragBarHandleImage;
  static Image? _stageImage;
  static Image? _scoreImage;
  static Image? _numberInfImage;
  static Image? _numberUnknownImage;
  static final List<Image> _gameOverImages = [];
  static final List<Image> _numberImages = [];

  // The snake game
  final SnakeGame _snakeGame = SnakeGame(mapSize: Vector2(30, 30));

  // Screen size, update in onGameResize(Size).
  Vector2? _screenSize;

  // Running state of the game.
  GameState _gameState = GameState.begin;

  // Map of Map of Button, example: _buttons[GameState.begin]["start"]
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  final Map<GameState, Map<String, Button>> _buttons = { for (var value in GameState.values) value : {} };

  // Map of Map of BaseAnimation, example: _animations["start"]
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  final Map<GameState, Map<String, BaseAnimation>> _animations = { for (var value in GameState.values) value : {} };

  // The current tapping button name
  String? _tappingButtonName;

  // The current playing animation
  BaseAnimation? _playingAnimation;

  // How many time do snake forward once
  static double _snakeForwardTime = 0.35;
  // The timer to forward the snake
  double _snakeForwardTimer = 0;

  // The volume
  static double _volume = 0.5;

  // Enabled food for the snake game
  static List<bool> enabledFood = [true, true, true, true, true];

  // Colorballs in start screen
  final List<Colorball> _colorballs = [];
  // Colorball spawn rate (0.0 ~ 1.0)
  final double _colorballSpawnRate = 0.8;
  // Speed of colorballs
  final Vector2 _colorballVelocity = Vector2(0.5, 1);

  // Size of setting background stripe
  final Vector2 _settingBackgroundStripeSize = Vector2(5, 5);
  // Setting background stripe margin
  final Vector2 _settingBackgroundStripeMargin = Vector2(5, 5);
  // Move speed of setting background stripe margin
  final Vector2 _settingBackgroundStripeVelocity = Vector2(0.2, 0.1);
  // Offset of the first setting background stripe, it is dynamic
  Vector2 _settingBackgroundStripeOffset = Vector2(0, 0);

  // Size of history background stripe
  final Vector2 _historyBackgroundStripeSize = Vector2(5, 5);
  // History background stripe margin
  final Vector2 _historyBackgroundStripeMargin = Vector2(5, 5);
  // Move speed of history background stripe margin
  final Vector2 _historyBackgroundStripeVelocity = Vector2(-0.2, -0.1);
  // Offset of the first history background stripe, it is dynamic
  Vector2 _historyBackgroundStripeOffset = Vector2(0, 0);

  // Size of game over background stripe
  final Vector2 _gameOverBackgroundStripeSize = Vector2(5, 5);
  // Game over background stripe margin
  final Vector2 _gameOverBackgroundStripeMargin = Vector2(5, 5);
  // Move speed of game over background stripe margin
  final Vector2 _gameOverBackgroundStripeVelocity = Vector2(-0.075, -0.05);
  // Offset of the first game over background stripe, it is dynamic
  Vector2 _gameOverBackgroundStripeOffset = Vector2(0, 0);

  // After some frames, image index will change
  int _gameOverImageFrame = 0;
  // The quantity of game over image
  final int _gameOverImageCount = 3;
  // How many frames to change image index
  final int _gameOverImageChangeFrame = 20;

  // The name of dragging bar
  String _draggingBarName = "";

  // The history score
  List<HistoryRecord> historyRecords = [HistoryRecord(), HistoryRecord(), HistoryRecord(),];

  /// Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user tap down on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    // If animation is playing, ignore tap down event
    if(_playingAnimation != null) {
      return;
    }

    if(_screenSize == null) {
      material.debugPrint("onTapDown(): Error! _screenSize is null");
      return;
    }

    final x = _toRelativeX(info.eventPosition.game.x);
    final y = _toRelativeY(info.eventPosition.game.y);

    // Check if click position is on button
    _buttons[_gameState]!.forEach(
      (key, value) => {
        if(value.isOnButton(x, y)) {
          material.debugPrint("$key button tap down"), //debug
          value.tapDown(),
          _tappingButtonName = key,
        }
      }
    );
  }

  /// Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user tap up on the screen.
  /// Tap up on button is considered as successful button click.
  @override
  void onTapUp(TapUpInfo info) {

    if(_screenSize == null) {
      material.debugPrint("onTapUp(): Error! _screenSize is null");
      return;
    }

    final x = _toRelativeX(info.eventPosition.game.x);
    final y = _toRelativeY(info.eventPosition.game.y);
    material.debugPrint("Tap up on ($x, $y)"); //debug

    final tappingButton = _buttons[_gameState]![_tappingButtonName];
    if(tappingButton != null) {
      material.debugPrint("$_tappingButtonName button tapped"); //debug

      // Set the playing animation name to tapping button name if the animation exist.
      // For example: begin screen "start" button click, playing animation will be set to "start",
      // it will not conflict with gameOver screen "start" button because the game state is different.
      final animationName = _tappingButtonName;
      final playingAnimation = _animations[_gameState]![animationName];
      if(playingAnimation != null) {
        _playingAnimation = playingAnimation;
      }

      // Reset the tapping button
      tappingButton.tapUp();
      _tappingButtonName = null;
    }


    if(_gameState == GameState.setting) {
      if(info.eventPosition.game.x >= _toAbsoluteX(30.3) &&
         info.eventPosition.game.x <= _toAbsoluteX(47.2) &&
         info.eventPosition.game.y >= _toAbsoluteY(69) &&
         info.eventPosition.game.y <= _toAbsoluteY(76.3)) {
        // check food0 checkbox
        material.debugPrint("check food0");

        bool isFood0LastChecked = true;
        for(int i = 0; i < 5; ++i) {
          if(i != 0 && enabledFood[i]) {
            isFood0LastChecked = false;
          }
        }
        if(!isFood0LastChecked || !enabledFood[0]) {
          enabledFood[0] = !enabledFood[0];
        }
      }
      if(info.eventPosition.game.x >= _toAbsoluteX(50.4) &&
         info.eventPosition.game.x <= _toAbsoluteX(67.7) &&
         info.eventPosition.game.y >= _toAbsoluteY(69.2) &&
         info.eventPosition.game.y <= _toAbsoluteY(76.4)) {
        // check food1 checkbox
        material.debugPrint("check food1");

        bool isFood1LastChecked = true;
        for(int i = 0; i < 5; ++i) {
          if(i != 1 && enabledFood[i]) {
            isFood1LastChecked = false;
          }
        }
        if(!isFood1LastChecked || !enabledFood[1]) {
          enabledFood[1] = !enabledFood[1];
        }
      }

      if(info.eventPosition.game.x >= _toAbsoluteX(70.4) &&
         info.eventPosition.game.x <= _toAbsoluteX(86) &&
         info.eventPosition.game.y >= _toAbsoluteY(69.2) &&
         info.eventPosition.game.y <= _toAbsoluteY(76.9)) {
        // check food2 checkbox
        material.debugPrint("check food2");

        bool isFood2LastChecked = true;
        for(int i = 0; i < 5; ++i) {
          if(i != 2 && enabledFood[i]) {
            isFood2LastChecked = false;
          }
        }
        if(!isFood2LastChecked || !enabledFood[2]) {
          enabledFood[2] = !enabledFood[2];
        }
      }

      if(info.eventPosition.game.x >= _toAbsoluteX(30) &&
         info.eventPosition.game.x <= _toAbsoluteX(45.5) &&
         info.eventPosition.game.y >= _toAbsoluteY(84.7) &&
         info.eventPosition.game.y <= _toAbsoluteY(91.8)) {
        // check food3 checkbox
        material.debugPrint("check food3");

        bool isFood3LastChecked = true;
        for(int i = 0; i < 5; ++i) {
          if(i != 3 && enabledFood[i]) {
            isFood3LastChecked = false;
          }
        }
        if(!isFood3LastChecked || !enabledFood[3]) {
          enabledFood[3] = !enabledFood[3];
        }
      }

      if(info.eventPosition.game.x >= _toAbsoluteX(50.6) &&
         info.eventPosition.game.x <= _toAbsoluteX(66.4) &&
         info.eventPosition.game.y >= _toAbsoluteY(84.7) &&
         info.eventPosition.game.y <= _toAbsoluteY(91.7)) {
        // check food4 checkbox
        material.debugPrint("check food4");

        bool isFood4LastChecked = true;
        for(int i = 0; i < 5; ++i) {
          if(i != 4 && enabledFood[i]) {
            isFood4LastChecked = false;
          }
        }
        if(!isFood4LastChecked || !enabledFood[4]) {
          enabledFood[4] = !enabledFood[4];
        }
      }
    }
  }

  /// Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user tap canceled on the screen.
  @override
  void onTapCancel() {
    final tappingButton = _buttons[_gameState]![_tappingButtonName];
    if(tappingButton != null) {
      tappingButton.tapUp();
      _tappingButtonName = null;
    }
  }

  /// Override from PanDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user start to drag on the screen.
  @override
  void onPanStart(DragStartInfo info) {
      material.debugPrint("onPanStart");
      // print(info.eventPosition.game);
      if(_gameState == GameState.setting) {
        // volume bar is dragging
        if(info.eventPosition.game.x >= _toAbsoluteX(30) &&
           info.eventPosition.game.x <= _toAbsoluteX(90) &&
           info.eventPosition.game.y >= _toAbsoluteY(30) &&
           info.eventPosition.game.y <= _toAbsoluteY(35)) {
          _draggingBarName = "volume";
        }
        // speed bar is dragging
        if(info.eventPosition.game.x >= _toAbsoluteX(30) &&
           info.eventPosition.game.x <= _toAbsoluteX(90) &&
           info.eventPosition.game.y >= _toAbsoluteY(50) &&
           info.eventPosition.game.y <= _toAbsoluteY(55)) {
          _draggingBarName = "speed";
        }
      }
  }

  /// Override from PanDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user dragging on the screen.
  @override
  void onPanUpdate(DragUpdateInfo info) {

    if(_draggingBarName == "volume") {
      if(_toRelativeX(info.eventPosition.game.x) <= 30) {
        _volume = 0.0;
      }
      else if(_toRelativeX(info.eventPosition.game.x) >= 90) {
        _volume = 1.0;
      }
      else {
        _volume = (_toRelativeX(info.eventPosition.game.x) - 30) / 0.6 / 100;
      }
      material.debugPrint("volume: " + _volume.toString());
    }
    else if(_draggingBarName == "speed") {
      if(_toRelativeX(info.eventPosition.game.x) <= 30) {
        _snakeForwardTime = -((30 - 30) / 60 - 0.2 - 1) / 2;
      }
      else if(_toRelativeX(info.eventPosition.game.x) >= 90) {
        _snakeForwardTime = -((90 - 30) / 60 - 0.2 - 1) / 2;
      }
      else {
        _snakeForwardTime = -((_toRelativeX(info.eventPosition.game.x) - 30) / 60 - 0.2 - 1) / 2;
      }
      material.debugPrint("speed: " + _snakeForwardTime.toString());
    }
  }

  /// Override from PanDetector. (flame/lib/src/gestures/detectors.dart)
  /// Triggered when the user stop dragging on the screen.
  @override
  void onPanEnd(DragEndInfo info) {
    // Release dragging bar
    material.debugPrint("onPanEnd");
    _draggingBarName = "";

    // if the game is playing & it is not a click
    if(_gameState == GameState.playing && (info.velocity.x != 0 || info.velocity.y != 0)) {
      // East or West
      if(info.velocity.x.abs() > info.velocity.y.abs()) {
        // East
        if(info.velocity.x > 0) {
          _snakeGame.turnSnake(Direction.east);
        }
        // West
        else {
          _snakeGame.turnSnake(Direction.west);
        }
      }
      // North or South
      else {
        // North
        if(info.velocity.y > 0) {
          _snakeGame.turnSnake(Direction.south);
        }
        // South
        else {
          _snakeGame.turnSnake(Direction.north);
        }
      }
    }
  }

  /// Override from KeyBoardEvents. (flame/lib/src/game/mixins/keyboard.dart)
  /// Triggered when the user input from keyboard.
  @override
  widgets.KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // The playing animation will block any key event
    if(_playingAnimation != null) {
      return widgets.KeyEventResult.ignored;
    }

    if(event is RawKeyDownEvent) {
      // If game is playing
      if(_gameState == GameState.playing) {
        // Snake turn north
        if(keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
          _snakeGame.turnSnake(Direction.north);
        }
        // Snake turn east
        if(keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
          _snakeGame.turnSnake(Direction.east);
        }
        // Snake turn south
        if(keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
          _snakeGame.turnSnake(Direction.south);
        }
        // Snake turn west
        if(keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
          _snakeGame.turnSnake(Direction.west);
        }
        if(keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[_gameState]!["pause"];
        }
      }
      // If game is pause
      else if(_gameState == GameState.pause) {
        // Unpause the game
        if(keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[_gameState]!["back"];
        }
      }

      return widgets.KeyEventResult.handled;
    }

    // The key is not handled
    return widgets.KeyEventResult.ignored;
  }

  /// Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
  /// Load recources like image, audio, etc.
  @override
  Future<void> onLoad() async {
    _logoImage = await Flame.images.load("logo.png");
    _settingBackgroundImage = await Flame.images.load("settingBackground.png");
    _historyBackgroundImage = await Flame.images.load("historyBackground.png");
    _gameOverBackgroundImage = await Flame.images.load("gameOverBackground.png");
    _volumeImage = await Flame.images.load("volume.png");
    _speedImage = await Flame.images.load("speed.png");
    _foodImage = await Flame.images.load("food.png");
    _checkboxImage = await Flame.images.load("checkbox.png");
    _checkImage = await Flame.images.load("check.png");
    _horizontalDragBarImage = await Flame.images.load("horizontalDragBar.png");
    _horizontalDragBarCalibrateImage = await Flame.images.load("horizontalDragBarCalibrate.png");
    _horizontalDragBarHandleImage = await Flame.images.load("horizontalDragBarHandle.png");
    _stageImage = await Flame.images.load("stage.png");
    _scoreImage = await Flame.images.load("score.png");
    _numberInfImage = await Flame.images.load("number/numberInf.png");
    _numberUnknownImage = await Flame.images.load("number/numberUnknown.png");
    for(int i = 0; i < _gameOverImageCount; ++i) {
      _gameOverImages.add(await Flame.images.load("gameOver$i.png"));
    }

    for(int i = 0; i <= 9; ++i) {
      _numberImages.add(await Flame.images.load("number/number$i.png"));
    }

    SnakeGame.loadResource();
    Colorball.loadResource();

    // start button
    _buttons[GameState.begin]!["start"] = Button(
      center: const Offset(50, 87.5),
      size: const Size(60, 15),
      color: const Color(0xFF66FF99),
      downColor: const Color(0xFF52EB85),
      image: await Flame.images.load("start.png"),
      imageWidthRatio: 0.25,
    );

    // setting button
    _buttons[GameState.begin]!["setting"] = Button(
      center: const Offset(32.5, 68.75),
      size: const Size(25, 12.5),
      color: const Color(0XFF9999FF),
      downColor: const Color(0XFF7B7BE1),
      image: await Flame.images.load("setting.png"),
    );

    // history button
    _buttons[GameState.begin]!["history"] = Button(
      center: const Offset(67.5, 68.75),
      size: const Size(25, 12.5),
      color: const Color(0xFFCC69EB),
      downColor: const Color(0xFFAB69D0),
      image: await Flame.images.load("history.png"),
    );

    // Load buttons in setting page
    // back button
    _buttons[GameState.setting]!["back"] = Button(
      center: const Offset(12.5, 8.75),
      size: const Size(15, 7.5),
      color: const Color(0xFFFFFF66),
      downColor: const Color(0xFFE1E148),
      image: await Flame.images.load("back.png"),
    );

    // Load buttons in history page
    // back button
    _buttons[GameState.history]!["back"] = Button(
      center: const Offset(12.5, 8.75),
      size: const Size(15, 7.5),
      color: const Color(0xFFFFFF66),
      downColor: const Color(0xFFE1E148),
      image: await Flame.images.load("back.png"),
    );

    // Load buttons in playing page
    // pause button
    _buttons[GameState.playing]!["pause"] = Button(
      center: const Offset(6, 5),
      size: const Size(10, 7),
      color: const Color(0xFFEEFF77),
      downColor: const Color(0xFFD0E159),
      image: await Flame.images.load("pause.png"),
    );

    // Load buttons in pause page
    // back button
    _buttons[GameState.pause]!["back"] = Button(
      center: const Offset(82, 23),
      size: const Size(10, 7),
      color: const Color(0xFFFFC481),
      downColor: const Color(0xFFE1A663),
      image: await Flame.images.load("back.png"),
    );

    _buttons[GameState.gameOver]!["home"] = Button(
      center: const Offset(30, 80),
      size: const Size(25, 12.5),
      color: const Color(0xFFFFFF66),
      downColor: const Color(0xFFE1E148),
      image: await Flame.images.load("home.png"),
      imageWidthRatio: 1.0
    );

    _buttons[GameState.gameOver]!["retry"] = Button(
      center: const Offset(70, 80),
      size: const Size(25, 12.5),
      color: const Color(0xFF66FF99),
      downColor: const Color(0xFF52EB85),
      image: await Flame.images.load("retry.png"),
    );

    // Load animations in begin page
    // start animation
    _animations[GameState.begin]!["start"] = BeginStartAnimation()..loadResource();
    // setting animation
    _animations[GameState.begin]!["setting"] = BeginSettingAnimation()..loadResource();
    // history animation
    _animations[GameState.begin]!["history"] = BeginHistoryAnimation()..loadResource();


    // Load animations in setting page
    // back animation
    _animations[GameState.setting]!["back"] = SettingBackAnimation()..loadResource();

    // Load animations in history page
    // back animation
    _animations[GameState.history]!["back"] = HistoryBackAnimation()..loadResource();

    // Load animations in playing page
    // pause animation
    _animations[GameState.playing]!["pause"] = PlayingPauseAnimation()..loadResource();
    _animations[GameState.playing]!["gameOver"] = PlayingGameOverAnimation()..loadResource();

    // Load animations in pause page
    _animations[GameState.pause]!["back"] = PauseBackAnimation()..loadResource();

    // Load animations in game over page
    _animations[GameState.gameOver]!["home"] = GameOverHomeAnimation()..loadResource();
    _animations[GameState.gameOver]!["retry"] = GameOverRetryAnimation()..loadResource();


    super.onLoad();
  }

  /// Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
  /// Init settings.
  @override
  void onMount() {

  }

  /// Override from Game. (flame/lib/src/game/mixins/game.dart)
  /// Triggered 60 times/s when it is not lagged.
  @override
  void render(Canvas canvas) {
    switch(_gameState) {
      // The screen before game start
      case GameState.begin: {
        _drawBeginScreen(canvas);

        break;
      }

      // The setting screen (begin -> setting)
      case GameState.setting: {
        _drawSettingScreen(canvas);

        break;
      }

      // The history score screen (begin -> history)
      case GameState.history: {
        _drawHistoryScreen(canvas);

        break;
      }

      // The screen when the game is playing
      case GameState.playing: {
        _drawPlayingScreen(canvas);

        break;
      }

      // The screen when the game is pause
      case GameState.pause: {
        _drawPlayingScreen(canvas);
        _drawPauseMenu(canvas);

        break;
      }

      // The screen when the game over
      case GameState.gameOver: {
        _drawGameOverScreen(canvas);

        break;
      }
    }

    // Draw top animation if there have playing animation.
    _drawAnimation(canvas);
  }

  /// Override from Game. (flame/lib/src/game/mixins/game.dart)
  /// Triggered 60 times/s (0.016666 s/time) when it is not lagged.
  @override
  void update(double updateTime) {
    // update colorball position
    if(_gameState == GameState.begin) {
      // Generate colorball
      int imageId;
      do {
        imageId = Random().nextInt(5);
      } while(!enabledFood[imageId]);
      if(Random().nextDouble() < _colorballSpawnRate) {
        Colorball colorball = Colorball(
          position: Vector2(50, 50),
          velocity: Vector2(
            Random().nextDouble() * _colorballVelocity.x * (Random().nextInt(2) == 1 ? 1 : -1),
            Random().nextDouble() * _colorballVelocity.y * (Random().nextInt(2) == 1 ? 1 : -1),
          ),
          imageId: imageId,
        );
        _colorballs.insert(0, colorball);
      }

      // Move colorball
      for(int i = 0; i < _colorballs.length; ++i) {
        Colorball colorball = _colorballs[i];
        colorball.position += colorball.velocity;

        // Remove out of bound colorballs
        if(colorball.position.x + colorball.size.x < 0 ||
           colorball.position.x > 100 ||
           colorball.position.y + colorball.size.y < 0 ||
           colorball.position.y > 100) {
          _colorballs.removeAt(i);
        }
      }
    }

    // update setting background stripe offset
    else if(_gameState == GameState.setting) {
      _settingBackgroundStripeOffset += _settingBackgroundStripeVelocity;

      if(_settingBackgroundStripeOffset.x + _settingBackgroundStripeSize.x + _settingBackgroundStripeMargin.x < 0) {
        _settingBackgroundStripeOffset.x += _settingBackgroundStripeSize.x + _settingBackgroundStripeMargin.x * 2;
      }
      else if(_settingBackgroundStripeOffset.x - _settingBackgroundStripeMargin.x > 0) {
        _settingBackgroundStripeOffset.x -= _settingBackgroundStripeSize.x + _settingBackgroundStripeMargin.x * 2;
      }
      if(_settingBackgroundStripeOffset.y + _settingBackgroundStripeSize.y + _settingBackgroundStripeMargin.y < 0) {
        _settingBackgroundStripeOffset.y += _settingBackgroundStripeSize.y + _settingBackgroundStripeMargin.y * 2;
      }
      else if(_settingBackgroundStripeOffset.y - _settingBackgroundStripeMargin.y > 0) {
        _settingBackgroundStripeOffset.y -= _settingBackgroundStripeSize.y + _settingBackgroundStripeMargin.y * 2;
      }
    }

    // update history background stripe offset
    else if(_gameState == GameState.history) {
      _historyBackgroundStripeOffset += _historyBackgroundStripeVelocity;

      if(_historyBackgroundStripeOffset.x + _historyBackgroundStripeSize.x + _historyBackgroundStripeMargin.x < 0) {
        _historyBackgroundStripeOffset.x += _historyBackgroundStripeSize.x + _historyBackgroundStripeMargin.x * 2;
      }
      else if(_historyBackgroundStripeOffset.x - _historyBackgroundStripeMargin.x > 0) {
        _historyBackgroundStripeOffset.x -= _historyBackgroundStripeSize.x + _historyBackgroundStripeMargin.x * 2;
      }
      if(_historyBackgroundStripeOffset.y + _historyBackgroundStripeSize.y + _historyBackgroundStripeMargin.y < 0) {
        _historyBackgroundStripeOffset.y += _historyBackgroundStripeSize.y + _historyBackgroundStripeMargin.y * 2;
      }
      else if(_historyBackgroundStripeOffset.y - _historyBackgroundStripeMargin.y > 0) {
        _historyBackgroundStripeOffset.y -= _historyBackgroundStripeSize.y + _historyBackgroundStripeMargin.y * 2;
      }
    }

    // update game over background stripe offset
    else if(_gameState == GameState.gameOver) {
      _gameOverBackgroundStripeOffset += _gameOverBackgroundStripeVelocity;

      if(_gameOverBackgroundStripeOffset.x + _gameOverBackgroundStripeSize.x + _gameOverBackgroundStripeMargin.x < 0) {
        _gameOverBackgroundStripeOffset.x += _gameOverBackgroundStripeSize.x + _gameOverBackgroundStripeMargin.x * 2;
      }
      else if(_gameOverBackgroundStripeOffset.x - _gameOverBackgroundStripeMargin.x > 0) {
        _gameOverBackgroundStripeOffset.x -= _gameOverBackgroundStripeSize.x + _gameOverBackgroundStripeMargin.x * 2;
      }
      if(_gameOverBackgroundStripeOffset.y + _gameOverBackgroundStripeSize.y + _gameOverBackgroundStripeMargin.y < 0) {
        _gameOverBackgroundStripeOffset.y += _gameOverBackgroundStripeSize.y + _gameOverBackgroundStripeMargin.y * 2;
      }
      else if(_gameOverBackgroundStripeOffset.y - _gameOverBackgroundStripeMargin.y > 0) {
        _gameOverBackgroundStripeOffset.y -= _gameOverBackgroundStripeSize.y + _gameOverBackgroundStripeMargin.y * 2;
      }
    }

    // Update animation (and maybe change game state)
    final playingAnimation = _playingAnimation;
    if(playingAnimation != null) {
      // If it is the frame to change game state, change to the target game state. (define in animation class)
      if(playingAnimation.isStateChangingFrame()) {
        // reset game when restart
        if(_playingAnimation == _animations[GameState.begin]!["start"] ||
           _playingAnimation == _animations[GameState.gameOver]!["retry"]) {
          _snakeGame.reset();
        }

        final targetGameState = playingAnimation.getTargetGameState();
        if(targetGameState != null) {
          _gameState = targetGameState;
        }
      }

      // Update animation frame
      if(playingAnimation.haveNextFrame()) {
        playingAnimation.toNextFrame();
      } else {
        playingAnimation.reset();
        _playingAnimation = null;
      }

      // Update animation will blocking anything else.
      return;
    }

    // run game
    if(_gameState == GameState.playing) {
      // Update timer
      _snakeForwardTimer += updateTime;
      // If hit timer
      if(_snakeForwardTimer >= _snakeForwardTime) {
        // Reset timer
        _snakeForwardTimer = 0;
        // forward snake
        if(_snakeGame.canForwardSnake()) {
          _snakeGame.forwardSnake();
        }
        // game over
        else {
          _playingAnimation = _animations[_gameState]!["gameOver"];

          // Calculate score of this round
          HistoryRecord record = HistoryRecord();
          record.score = _snakeGame.currentScore;
          for(var snakeUnit in _snakeGame.snake.body) {
            for(int j = 0; j < Food.colors.length; ++j) {
              if(snakeUnit.color == Food.colors[j]) {
                ++record.foodEaten[j];
                break;
              }
            }
          }

          // Update history score
          if(record.score >= historyRecords[0].score) {
            historyRecords.insert(0, record);
            historyRecords.removeAt(3);
          }
          else if(record.score >= historyRecords[1].score) {
            historyRecords.insert(1, record);
            historyRecords.removeAt(3);
          }
          else if(record.score >= historyRecords[2].score) {
            historyRecords.insert(2, record);
            historyRecords.removeAt(3);
          }
        }
      }
    }
  }

  /// Override from Game. (flame/lib/src/game/mixins/game.dart)
  /// Triggered when the game is resize.
  @override
  // @material.mustCallSuper // import "package:flutter/material.dart"
  void onGameResize(Vector2 screenSize) {
    // super.onGameResize(size);
    _screenSize = screenSize;
  }

  /// Convert absolute x to percentage x (0.0 ~ 100.0).
  /// If there are no screen size set, return directly.
  double _toRelativeX(double absoluteX) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("PixelSnake::_toRelativeX(): Error! _screenSize is null");
      return 0;
    }

    return absoluteX / _screenSize.x * 100.0;
  }

  /// Convert absolute y to percentage y (0.0 ~ 100.0).
  /// If there are no screen size set, return directly.
  double _toRelativeY(double absoluteY) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("PixelSnake::_toRelativeY(): Error! _screenSize is null");
      return 0;
    }

    return absoluteY / _screenSize.y * 100.0;
  }

  /// Convert percentage x to absolute x.
  /// If there are no screen size set, return directly.
  double _toAbsoluteX(double relativeX) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("PixelSnake::_toAbsoluteX(): Error! _screenSize is null");
      return 0;
    }

    return relativeX * _screenSize.x / 100.0;
  }

  /// Convert percentage y to absolute y.
  /// If there are no screen size set, return directly.
  double _toAbsoluteY(double relativeY) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("PixelSnake::_toAbsoluteY(): Error! _screenSize is null");
      return 0;
    }

    return relativeY * _screenSize.y / 100.0;
  }

  /// Draw the game begin screen, used in render().
  /// If there are no screen size set, return directly.
  void _drawBeginScreen(Canvas canvas) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()
        ..color = const Color(0xFFFFFF66),
    );

    // Draw colorballs
    for(Colorball colorball in _colorballs) {
      Sprite sprite = Sprite(Colorball.images[colorball.imageId]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(colorball.position.x), _toAbsoluteY(colorball.position.y)),
        size: Vector2(_toAbsoluteX(colorball.size.x), _toAbsoluteY(colorball.size.y)),
      );
    }

    // Draw logo
    if(_logoImage != null) {
      Sprite sprite = Sprite(_logoImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(5.0), _toAbsoluteY(5.0)),
        size: Vector2(_toAbsoluteX(90.0), _toAbsoluteY(45.0)),
      );
    }

    // Draw all button
    _buttons[GameState.begin]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
    );
  }

  /// Draw the setting screen, used in render().
  /// If there are no screen size set, return directly.
  void _drawSettingScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()
        ..color = const Color(0XFF9999FF),
    );

    // Draw background stripe
    Vector2 currentPosition = _settingBackgroundStripeOffset.clone();
    for(; currentPosition.y < 100; currentPosition.y += _settingBackgroundStripeSize.y + _settingBackgroundStripeMargin.y * 2) {
      for(; currentPosition.x < 100; currentPosition.x += _settingBackgroundStripeSize.x + _settingBackgroundStripeMargin.x * 2) {
        // draw stripe
        if(_settingBackgroundImage != null) {
          Sprite sprite = Sprite(_settingBackgroundImage!);
          sprite.render(
            canvas,
            position: Vector2(_toAbsoluteX(currentPosition.x), _toAbsoluteY(currentPosition.y)),
            size: Vector2(_toAbsoluteX(_settingBackgroundStripeSize.x), _toAbsoluteY(_settingBackgroundStripeSize.y)),
            overridePaint: Paint()
              ..color = const Color.fromARGB(100, 0, 0, 0)
          );
        }
      }

      // set x to line begin
      currentPosition.x = _settingBackgroundStripeOffset.x;
    }

    // Draw volume title
    if(_volumeImage != null) {
      Sprite sprite = Sprite(_volumeImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(10), _toAbsoluteY(28)),
        size: Vector2(_toAbsoluteX(15), _toAbsoluteY(7.5)),
        overridePaint: Paint()
        ..color = const Color.fromARGB(150, 0, 0, 0)
      );
    }

    // Draw volume drag bar
    Vector2 volumeDragBarPosition = Vector2(30, 30);
    Vector2 volumeDragBarSize = Vector2(60, 5);
    if(_horizontalDragBarImage != null) {
      Sprite sprite = Sprite(_horizontalDragBarImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(volumeDragBarPosition.x), _toAbsoluteY(volumeDragBarPosition.y)),
        size: Vector2(_toAbsoluteX(volumeDragBarSize.x), _toAbsoluteY(volumeDragBarSize.y)),
        overridePaint: Paint()
        ..color = const Color.fromARGB(100, 0, 0, 0)
      );
    }

    // Draw volume drag bar calibrate
    for(int i = 0; i <= 100; i += 25) {
      if(_horizontalDragBarHandleImage != null && _horizontalDragBarCalibrateImage != null) {
        Vector2 calibrateSize = Vector2(2, 3);
        Vector2 calibratePosition = volumeDragBarPosition.clone() .. x -= calibrateSize.x / 2;

        Sprite sprite = Sprite(_horizontalDragBarCalibrateImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(calibratePosition.x + (i / 100) * volumeDragBarSize.x), _toAbsoluteY(calibratePosition.y + (volumeDragBarSize.y - calibrateSize.y) / 2)),
          size: Vector2(_toAbsoluteX(calibrateSize.x), _toAbsoluteY(calibrateSize.y)),
          overridePaint: Paint()
          ..color = const Color.fromARGB(150, 0, 0, 0)
        );
      }
    }
    // Draw volume drag bar handle
    {
      Vector2 handleSize = Vector2(3, 6);
      Vector2 handlePosition = Vector2(volumeDragBarPosition.x + volumeDragBarSize.x * _volume, volumeDragBarPosition.y - handleSize.x / 2);
      if(_horizontalDragBarImage != null) {
        Sprite sprite = Sprite(_horizontalDragBarHandleImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(handlePosition.x - handleSize.x / 2), _toAbsoluteY(handlePosition.y)),
          size: Vector2(_toAbsoluteX(handleSize.x), _toAbsoluteY(handleSize.y)),
          overridePaint: Paint()
          ..color = const Color.fromARGB(150, 0, 0, 0)
        );
      }
    }

    // Draw speed title
    if(_speedImage != null) {
      Sprite sprite = Sprite(_speedImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(10), _toAbsoluteY(49)),
        size: Vector2(_toAbsoluteX(15), _toAbsoluteY(7.5)),
        overridePaint: Paint()
        ..color = const Color.fromARGB(150, 0, 0, 0)
      );
    }

    // Draw speed drag bar
    Vector2 speedDragBarPosition = Vector2(30, 50);
    Vector2 speedDragBarSize = Vector2(60, 5);
    if(_horizontalDragBarImage != null) {
      Sprite sprite = Sprite(_horizontalDragBarImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(speedDragBarPosition.x), _toAbsoluteY(speedDragBarPosition.y)),
        size: Vector2(_toAbsoluteX(speedDragBarSize.x), _toAbsoluteY(speedDragBarSize.y)),
        overridePaint: Paint()
        ..color = const Color.fromARGB(100, 0, 0, 0)
      );
    }

    // Draw speed drag bar calibrate
    for(int i = 0; i <= 100; i += 25) {
      if(_horizontalDragBarHandleImage != null && _horizontalDragBarCalibrateImage != null) {
        Vector2 calibrateSize = Vector2(2, 3);
        Vector2 calibratePosition = speedDragBarPosition.clone() .. x -= calibrateSize.x / 2;

        Sprite sprite = Sprite(_horizontalDragBarCalibrateImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(calibratePosition.x + (i / 100) * speedDragBarSize.x), _toAbsoluteY(calibratePosition.y + (speedDragBarSize.y - calibrateSize.y) / 2)),
          size: Vector2(_toAbsoluteX(calibrateSize.x), _toAbsoluteY(calibrateSize.y)),
          overridePaint: Paint()
          ..color = const Color.fromARGB(150, 0, 0, 0)
        );
      }
    }

    // Draw speed drag bar handle
    {
      Vector2 handleSize = Vector2(3, 6);
      Vector2 handlePosition = Vector2(speedDragBarPosition.x + speedDragBarSize.x * (1 - (_snakeForwardTime * 2) + 0.2), speedDragBarPosition.y - handleSize.x / 2);
      if(_horizontalDragBarImage != null) {
        Sprite sprite = Sprite(_horizontalDragBarHandleImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(handlePosition.x - handleSize.x / 2), _toAbsoluteY(handlePosition.y)),
          size: Vector2(_toAbsoluteX(handleSize.x), _toAbsoluteY(handleSize.y)),
          overridePaint: Paint()
          ..color = const Color.fromARGB(150, 0, 0, 0)
        );
      }
    }

    // Draw food title
    if(_foodImage != null) {
      Sprite sprite = Sprite(_foodImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(10), _toAbsoluteY(69)),
        size: Vector2(_toAbsoluteX(15), _toAbsoluteY(7.5)),
        overridePaint: Paint()
        ..color = const Color.fromARGB(150, 0, 0, 0)
      );
    }

    // Draw food setting
    for(int i = 0; i < 5; ++i) {
      Vector2 offset = Vector2(i % 3 * 20, i ~/ 3 * 15);
      // Draw food check box
      if(_checkboxImage != null) {
          Sprite sprite = Sprite(_checkboxImage!);
          sprite.render(
            canvas,
            position: Vector2(_toAbsoluteX(30 + offset.x), _toAbsoluteY(71 + offset.y)),
            size: Vector2(_toAbsoluteX(5), _toAbsoluteY(5)),
            overridePaint: Paint()
            ..color = const Color.fromARGB(150, 0, 0, 0)
          );
      }

      // Draw food check
      if(enabledFood[i]) {
        if(_checkImage != null) {
          Sprite sprite = Sprite(_checkImage!);
          sprite.render(
            canvas,
            position: Vector2(_toAbsoluteX(30 + offset.x), _toAbsoluteY(71 + offset.y)),
            size: Vector2(_toAbsoluteX(5), _toAbsoluteY(5))
          );
        }
      }

      // Draw food image
      Sprite sprite = Sprite(Food.images[i]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(37 + offset.x), _toAbsoluteY(68 + offset.y)),
        size: Vector2(_toAbsoluteX(10), _toAbsoluteY(10))
      );
    }

  // Draw all button
  _buttons[GameState.setting]!.forEach(
    (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
  );
}

  /// Draw the game begin screen, used in render().
  /// If there are no screen size set, return directly.
  void _drawHistoryScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()
        ..color = const Color(0xFFCC69EB),
    );

    // Draw background stripe
    Vector2 currentPosition = _historyBackgroundStripeOffset.clone();
    for(; currentPosition.y < 100; currentPosition.y += _historyBackgroundStripeSize.y + _historyBackgroundStripeMargin.y * 2) {
      for(; currentPosition.x < 100; currentPosition.x += _historyBackgroundStripeSize.x + _historyBackgroundStripeMargin.x * 2) {
        // draw stripe
        if(_historyBackgroundImage != null) {
          Sprite sprite = Sprite(_historyBackgroundImage!);
          sprite.render(
            canvas,
            position: Vector2(_toAbsoluteX(currentPosition.x), _toAbsoluteY(currentPosition.y)),
            size: Vector2(_toAbsoluteX(_historyBackgroundStripeSize.x), _toAbsoluteY(_historyBackgroundStripeSize.y)),
            overridePaint: Paint()
              ..color = const Color.fromARGB(100, 0, 0, 0)
          );
        }
      }

      // set x to line begin
      currentPosition.x = _historyBackgroundStripeOffset.x;
    }

    // Draw stage
    if(_stageImage != null) {
      Sprite sprite = Sprite(_stageImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(10), _toAbsoluteY(20)),
        size: Vector2(_toAbsoluteX(80), _toAbsoluteY(80)),
        overridePaint: Paint()
          ..color = const Color.fromARGB(255, 0, 0, 0)
      );
    }

    // Draw all button
    _buttons[GameState.history]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
    );
  }

  /// Draw the game playing screen, used in render().
  /// If there are no screen size set, return directly.
  void _drawPlayingScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()
        ..color = const Color(0xFF66FF99),
    );

    // Draw score title
    if(_scoreImage != null) {
      Sprite sprite = Sprite(_scoreImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(58), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(20), _toAbsoluteY(8)),
      );
    }

    // Draw score
    int currentScore = _snakeGame.currentScore;
    // number >= ?????
    if(currentScore >= 10000) {
      // Draw number inf
      if(_numberInfImage != null) {
        Sprite sprite = Sprite(_numberInfImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
          size: Vector2(_toAbsoluteX(8), _toAbsoluteY(8)),
        );
      }
    }
    // number = ????
    else if(currentScore >= 1000) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 1000]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 1000 ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(85), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(90), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(95), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ???
    else if(currentScore >= 100) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(85), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(90), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ??
    else if(currentScore >= 10) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(85), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ?
    else if(currentScore >= 0) {
      Sprite sprite = Sprite(_numberImages[currentScore]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = -?
    else {
      // Draw number unknown
      if(_numberUnknownImage != null) {
        Sprite sprite = Sprite(_numberUnknownImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(80), _toAbsoluteY(2)),
          size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
        );
      }
    }


    // Draw snake game area
    /// Render the game on canvas.
    /// Game render area size have to be set in this function,
    /// need the size of render area to draw the game area correctly.
    /// Warning: Need to call loadResource before this function invoked.
    // Render game area on canvas
    canvas.drawRect(
      Rect.fromLTWH(
        _toAbsoluteX(_snakeGame.gameAreaOffset.x),
        _toAbsoluteY(_snakeGame.gameAreaOffset.y),
        _toAbsoluteX(_snakeGame.gameAreaSize.x),
        _toAbsoluteY(_snakeGame.gameAreaSize.y),
      ),
      Paint()
        ..color = _snakeGame.gameAreaColor,
    );

    // Render food on canvas
    final mapUnitSize = _snakeGame.getMapUnitSize(screenSize: _screenSize);
    Sprite sprite = Sprite(Food.images[_snakeGame.food.imageId]);
    sprite.render(
      canvas,
      position: Vector2(_snakeGame.food.position.x * mapUnitSize.width + _toAbsoluteX(_snakeGame.gameAreaOffset.x), _snakeGame.food.position.y * mapUnitSize.height + _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
      size: Vector2(mapUnitSize.width, mapUnitSize.height),
    );

    // Render debug food on canvas //debug!!
    sprite = Sprite(Food.images[0]);
    sprite.render(
      canvas,
      position: Vector2(29 * mapUnitSize.width + _toAbsoluteX(_snakeGame.gameAreaOffset.x), 29 * mapUnitSize.height + _toAbsoluteY(_snakeGame.gameAreaOffset.y)),
      size: Vector2(mapUnitSize.width, mapUnitSize.height),
    );

    // Render snake on canvas
    for(final snakeUnit in _snakeGame.snake.body) {
      canvas.drawRect(
        Rect.fromLTWH(
          snakeUnit.position.x * mapUnitSize.width + _toAbsoluteX(_snakeGame.gameAreaOffset.x),
          snakeUnit.position.y * mapUnitSize.height + _toAbsoluteY(_snakeGame.gameAreaOffset.y),
          mapUnitSize.width,
          mapUnitSize.height,
        ),
        Paint()
          ..color = snakeUnit.color,
      );
    }

    // Render snake eye
    // snake head
    final snakeHead = _snakeGame.snake.body.first;
    // snake head left up point
    final headOffset = Offset(snakeHead.position.x * mapUnitSize.width  + _toAbsoluteX(_snakeGame.gameAreaOffset.x), snakeHead.position.y * mapUnitSize.height + _toAbsoluteY(_snakeGame.gameAreaOffset.y));
    // snake head eye unit size
    final eyeUnitSize = Size(mapUnitSize.width / 5, mapUnitSize.height / 5);
    // store snake eye size
    Size eyeSize = const Size(0, 0);
    // store snake left eye offset
    Offset leftEyeOffset = const Offset(0, 0);
    // store snake right eye offset
    Offset rightEyeOffset = const Offset(0, 0);
    switch(snakeHead.direction) {
      case Direction.north: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 1);
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        break;
      }
      case Direction.east: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 3);
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        break;
      }
      case Direction.south: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 2);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 2);
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        break;
      }
      case Direction.west: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 3);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        break;
      }
    }
    // Render left eye
    canvas.drawRect(
      Rect.fromLTWH(
        leftEyeOffset.dx,
        leftEyeOffset.dy,
        eyeSize.width,
        eyeSize.height,
      ),
      Paint()
        ..color = _snakeGame.snake.eyeColor,
    );
    // Render right eye
    canvas.drawRect(
      Rect.fromLTWH(
        rightEyeOffset.dx,
        rightEyeOffset.dy,
        eyeSize.width,
        eyeSize.height,
      ),
      Paint()
        ..color = _snakeGame.snake.eyeColor,
    );

    // Draw all button
    _buttons[GameState.playing]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
    );
  }

  /// Draw the game pause menu, used in render().
  /// If there are no screen size set, return directly.
  void _drawPauseMenu(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(_toAbsoluteX(10), _toAbsoluteY(17.5), _toAbsoluteX(80),_toAbsoluteY(75)),
      Paint()
        ..color = const Color(0xAAEEFF77),
    );

    // Draw all button
    _buttons[GameState.pause]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
    );
  }

  /// Draw the game over screen, used in render().
  /// If there are no screen size set, return directly.
  void _drawGameOverScreen(Canvas canvas) {

    print(historyRecords[0].score);

    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.x, _screenSize.y),
      Paint()
        ..color = material.Colors.orange,
    );

    // Draw background stripe
    Vector2 currentPosition = _gameOverBackgroundStripeOffset.clone();
    for(; currentPosition.y < 100; currentPosition.y += _gameOverBackgroundStripeSize.y + _gameOverBackgroundStripeMargin.y * 2) {
      for(; currentPosition.x < 100; currentPosition.x += _gameOverBackgroundStripeSize.x + _gameOverBackgroundStripeMargin.x * 2) {
        // draw stripe
        if(_gameOverBackgroundImage != null) {
          Sprite sprite = Sprite(_gameOverBackgroundImage!);
          sprite.render(
            canvas,
            position: Vector2(_toAbsoluteX(currentPosition.x), _toAbsoluteY(currentPosition.y)),
            size: Vector2(_toAbsoluteX(_gameOverBackgroundStripeSize.x), _toAbsoluteY(_gameOverBackgroundStripeSize.y)),
            overridePaint: Paint()
              ..color = const Color.fromARGB(100, 0, 0, 0)
          );
        }
      }

      // set x to line begin
      currentPosition.x = _gameOverBackgroundStripeOffset.x;
    }

    // Draw game over title
    if(_gameOverImageFrame >= _gameOverImageCount * _gameOverImageChangeFrame) {
      _gameOverImageFrame = 0;
    }
    Sprite sprite = Sprite(_gameOverImages[_gameOverImageFrame ~/ _gameOverImageChangeFrame]);
    sprite.render(
      canvas,
      position: Vector2(_toAbsoluteX(20), _toAbsoluteY(5)),
      size: Vector2(_toAbsoluteX(60), _toAbsoluteY(30)),
    );
    ++_gameOverImageFrame;

    // Draw score title
    if(_scoreImage != null) {
      Sprite sprite = Sprite(_scoreImage!);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(18), _toAbsoluteY(45)),
        size: Vector2(_toAbsoluteX(20), _toAbsoluteY(10)),
      );
    }

    // Draw score
    int currentScore = _snakeGame.currentScore;
    // number >= ?????
    if(currentScore >= 10000) {
      // Draw number inf
      if(_numberInfImage != null) {
        Sprite sprite = Sprite(_numberInfImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
          size: Vector2(_toAbsoluteX(8), _toAbsoluteY(8)),
        );
      }
    }
    // number = ????
    else if(currentScore >= 1000) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 1000]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 1000 ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(45), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(50), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(55), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ???
    else if(currentScore >= 100) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 100]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 100 ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(45), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(50), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ??
    else if(currentScore >= 10) {
      Sprite sprite = Sprite(_numberImages[currentScore ~/ 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
      sprite = Sprite(_numberImages[currentScore % 10]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(45), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = ?
    else if(currentScore >= 0) {
      Sprite sprite = Sprite(_numberImages[currentScore]);
      sprite.render(
        canvas,
        position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
        size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
      );
    }
    // number = -?
    else {
      // Draw number unknown
      if(_numberUnknownImage != null) {
        Sprite sprite = Sprite(_numberUnknownImage!);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteX(40), _toAbsoluteY(47)),
          size: Vector2(_toAbsoluteX(4), _toAbsoluteY(8)),
        );
      }
    }

    // Draw all button
    _buttons[GameState.gameOver]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, screenSize: _screenSize)
    );
  }

  /// Draw the playing animation.
  /// If there are no screen size set, return directly.
  /// If there are no current playing animaton, return directly.
  void _drawAnimation(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // If there are no current playing animaton, return directly.
    final playingAnimation = _playingAnimation;
    if(playingAnimation == null) {
      return;
    }

    // Draw animation
    playingAnimation.drawOnCanvas(canvas, screenSize: _screenSize);
  }
}
