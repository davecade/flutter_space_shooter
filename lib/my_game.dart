import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_space_shooter/components/asteroid.dart';

import 'package:flutter_space_shooter/components/player.dart';
import 'package:flutter_space_shooter/components/shoot_button.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // We need to add the HasKeyboardHandlerComponents mixin so that the
  // game knows that some components will be handling keyboard input.

  // ----------------------------------
  // We add the player component to the game
  // This is a global and public variable so other components can access it.
  // We use "late" because we don't have the player yet when the game is created.
  // it allows us to set the variable later.
  late Player player;
  late SpawnComponent _asteroidSpawner;
  late JoystickComponent joystick;
  final Random _random = Random.secure();
  late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;

  @override
  FutureOr<void> onLoad() async {
    // Make the game full screen
    await Flame.device.fullScreen();

    // We need to make it Portrait only
    await Flame.device.setPortrait();

    // This is where we start the game
    startGame();

    return super.onLoad();
  }

  void startGame() async {
    // create the joystick and add it to the game
    await _createJoystick();

    // this method will first create the player and add it to the game
    await _createPlayer();
    _createShootButton();
    _createAsteroidSpawner();
    _createScoreDisplay();
  }

  // underscore for private method
  Future<void> _createPlayer() async {
    // We set the player variable to a new Player instance
    player = Player()
      ..anchor = Anchor
          .center // anchor the image to its center, not top-left
      ..position = Vector2(
        size.x / 2,
        size.y * 0.8,
      ); // position the player near the bottom center

    // This is how we add components to the game, by using the add() method
    add(player);
  }

  void _createShootButton() {
    _shootButton = ShootButton()
      ..anchor = Anchor.bottomRight
      ..position = Vector2(size.x - 20, size.y - 20)
      ..priority = 10;
    add(_shootButton);
  }

  // Component that spawns asteroids periodically
  void _createAsteroidSpawner() {
    // using the SpawnComponent from Flame to spawn asteroids, we can set the min and max period
    // this will create a new asteroid every 0.7 to 1.2 seconds
    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteroid(position: _generateSpawnPosition()),
      maxPeriod: 0.7,
      minPeriod: 1.2,
      selfPositioning:
          true, // we have to set this true so that the Asteroid component will use its own position
    );

    add(_asteroidSpawner);
  }

  Future<void> _createJoystick() async {
    // Create the joystick component
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_knob.png'),
        size: Vector2.all(50),
      ), // we're setting the knob sprite, and the size of the knob
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ), // setting the background sprite and size
      anchor: Anchor.bottomLeft, // anchor to bottom-left of the screen
      position: Vector2(
        20,
        size.y - 20,
      ), // position with some margin from edges
      priority: 10,
    );

    add(joystick); // add the joystick to the game
  }

  Vector2 _generateSpawnPosition() {
    final double x = 10 + _random.nextDouble() * (size.x - 10 * 2);
    final double y = -100; // spawn just above the top edge
    return Vector2(x, y);
  }

  void _createScoreDisplay() {
    _score = 0;
    _scoreDisplay = TextComponent(
      text: 'Score: $_score',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: BorderSide.strokeAlignCenter,
            ),
          ],
        ),
      ),
    );
    add(_scoreDisplay);
  }

  void incrementScore() {
    _score += 1;
    _scoreDisplay.text = 'Score: $_score';
  }
}
