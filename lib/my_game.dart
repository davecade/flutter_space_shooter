import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_space_shooter/components/player.dart';

class MyGame extends FlameGame {
  // We add the player component to the game
  // This is a global and public variable so other components can access it.
  // We use "late" because it will be initialized in onLoad
  late Player player;

  @override
  FutureOr<void> onLoad() async {
    // Make the game full screen
    await Flame.device.fullScreen();

    // We need to make it Porttait only
    await Flame.device.setPortrait();

    // This is where we start the game
    startGame();

    return super.onLoad();
  }

  void startGame() {
    // this method will first create the player and add it to the game
    _createPlayer();
  }

  // underscore for private method
  void _createPlayer() {
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

  // We cah change background color llike this:
  // @override
  // Color backgroundColor() {
  //   return const Color.fromRGBO(255, 0, 0, 1.0); // Red background
  // }
}
