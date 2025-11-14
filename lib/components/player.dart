import 'dart:async';

import 'package:flame/components.dart';

// HasGameReference gives us a reference to the game instance
// This is provided by Flame to allow components to access the game
class Player extends SpriteComponent with HasGameReference {
  @override
  FutureOr<void> onLoad() async {
    // Here we are loading a sprite from assets/images/player_blue_on0.png
    sprite = await game.loadSprite('player_blue_on0.png');

    // Set the size of the player, while maintaining aspect ratio
    size *= 0.3; // scale down the size to 30%

    return super.onLoad();
  }
}
