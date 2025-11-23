import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_space_shooter/my_game.dart';
import 'package:flutter_space_shooter/overlays/game_over_overlay.dart';

void main() {
  // We firsyt create an instance of our game
  final MyGame game = MyGame();

  // Then we run the app with the game widget
  runApp(
    GameWidget(
      game: game,
      // We add the Game Over overlay to the game widget
      overlayBuilderMap: {
        'GameOver': (context, MyGame game) {
          return GameOverOverlay(game: game);
        },
      },
    ),
  );
}
