import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_space_shooter/components/laser.dart';
import 'package:flutter_space_shooter/my_game.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent
    with HasGameReference<MyGame>, KeyboardHandler {
  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _timeSinceLastFire = 0.0;
  final Vector2 _keyboardMovements = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    // Here we are loading a sprite from assets/images/player_blue_on0.png
    sprite = await game.loadSprite('player_blue_on0.png');

    // Set the size of the player, while maintaining aspect ratio
    size *= 0.3; // scale down the size to 30%

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // This adds movement from both joystick and keyboard
    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovements;

    position +=
        movement.normalized() *
        200 *
        dt; // always * the dt because update is called every frame, and the dt is the time difference between frames

    _handleScreenBoundaries();

    _timeSinceLastFire += dt; // this keeps track of time since last fire
    if (_isShooting && _timeSinceLastFire >= _fireCooldown) {
      // fire lazer
      _fireLazer();
      _timeSinceLastFire = 0.0; // reset the timer
    }
  }

  // inside the player we handle the screen bounds\
  void _handleScreenBoundaries() {
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // Next prevent the player from going off the edges of the screen
    position.y = clampDouble(position.y, size.y / 2, screenHeight - size.y / 2);

    // prevent going off left and right edges
    // position.x = clampDouble(position.x, size.x / 2, screenWidth - size.x / 2);

    // if the player goes off the left edge, we want it to appear on the right edge
    if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;

      // else if it goes off the right edge, appear on the left edge
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }

  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireLazer() {
    // we need to create a new laser component and add it to the game
    // here we set the laser position to be at the top center of the player
    // the Vector2(0, -size.y / 2) offsets the laser to be at the top of the player
    game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2)));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // this gives you access to the keys currently pressed
    _keyboardMovements.x = 0;

    // Note::
    // I tried using Letter Keys, but the porblem with android emulators
    // is that when you hold down a letter key, it cancels straight after its pressed
    // then presses it again after a short delay, like a typewriter effect
    // this doesn't happen with arrow keys, so for now we will use arrow keys for movement

    // check for left and right arrow keys
    _keyboardMovements.x += keysPressed.contains(LogicalKeyboardKey.arrowRight)
        ? 1
        : 0;

    // check for left arrow key
    _keyboardMovements.x -= keysPressed.contains(LogicalKeyboardKey.arrowLeft)
        ? 1
        : 0;

    //
    _keyboardMovements.y = 0;

    // check for up arrow key
    _keyboardMovements.y += keysPressed.contains(LogicalKeyboardKey.arrowUp)
        ? -1
        : 0;

    // check for up and down arrow keys
    _keyboardMovements.y -= keysPressed.contains(LogicalKeyboardKey.arrowDown)
        ? -1
        : 0;

    // this is so that the super class knows we've handled the event
    return true;
  }
}
