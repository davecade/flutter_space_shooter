import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_space_shooter/my_game.dart';

void main() {
  // We firsyt create an instance of our game
  final MyGame game = MyGame();

  // Then we run the app with the game widget
  runApp(GameWidget(game: game));
}
