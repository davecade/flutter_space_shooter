import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_space_shooter/my_game.dart';

class ShootButton extends SpriteComponent
    with HasGameReference<MyGame>, TapCallbacks {
  ShootButton() : super(size: Vector2.all(80));

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('shoot_button.png');
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // this calls the parent class's onTapDown method
    super.onTapDown(event);

    // the game reference has access to the player
    // and we update the player's shooting state
    game.player.startShooting();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    game.player.stopShooting();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // we have to do this so that it doesn't keep pressing when the tap is cancelled
    // this happens when the user moves their finger off the button
    // now moving it off the button will stop shooting
    super.onTapCancel(event);
    game.player.stopShooting();
  }
}
