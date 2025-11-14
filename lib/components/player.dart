import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_space_shooter/my_game.dart';

// HasGameReference gives us a reference to the game instance
// This is provided by Flame to allow components to access the game
class Player extends SpriteComponent with HasGameReference<MyGame> {
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

    position +=
        game.joystick.relativeDelta.normalized() *
        200 *
        dt; // always * the dt because update is called every frame, and the dt is the time difference between frames

    _handleScreenBoundaries();
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
}
