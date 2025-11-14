import 'dart:async';

import 'package:flame/components.dart';

// HasGameReference gives us a reference to the game instance
// This is provided by Flame to allow components to access the game
class Player extends SpriteComponent with HasGameReference {
  @override
  FutureOr<void> onLoad() async {
    // Set the size of the player
    // Here we are loading a sprite from assets/images/player_blue_on0.png
    sprite = await game.loadSprite('player_blue_on0.png');

    return super.onLoad();
  }
}
