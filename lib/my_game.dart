import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_space_shooter/components/player.dart';

class MyGame extends FlameGame {
  // We add the player component to the game
  // This is a global and public variable so other components can access it.
  // We use "late" because we don't have the player yet when the game is created.
  // it allows us to set the variable later.
  late Player player;
  late JoystickComponent joystick;

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

  void startGame() async {
    // create the joystick and add it to the game
    await _createJoystick();

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
    );

    add(joystick); // add the joystick to the game
  }
}
