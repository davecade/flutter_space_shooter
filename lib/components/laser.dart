import 'package:flame/components.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame> {
  // add constructor
  Laser({required super.position})
    : super(
        anchor: Anchor.center,
        priority: -1,
      ); // since it has an empty body, we can add a semicolon here

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');

    size *= 0.25; // scale down the size to 50%

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y -= 500 * dt; // this will make the laser move up the screen

    if (position.y < size.y) {
      // if the laser goes off the top of the screen, remove it
      removeFromParent();
    }

    super.update(dt);
  }
}
