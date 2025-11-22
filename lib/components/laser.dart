import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_space_shooter/components/asteroid.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Laser extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  // add constructor
  Laser({required super.position, super.angle = 0.0})
    : super(
        anchor: Anchor.center,
        priority: -1,
      ); // since it has an empty body, we can add a semicolon here

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');

    size *= 0.25; // scale down the size to 50%

    //This hitbox will automatically size itself to the size of the component (the parent component)
    // It will also automatically update its position when the parent component moves
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // We use sin and cos to move the laser in the direction it's facing
    // Why sin? because in a unit circle, sin(angle) gives us the x component
    // Why -cos? because in a unit circle, cos(angle) gives us the y component
    // We negate it because in Flutter, the y axis is inverted (increases downwards)
    position += Vector2(sin(angle), -cos(angle)) * 500 * dt;

    if (position.y < size.y) {
      // if the laser goes off the top of the screen, remove it
      removeFromParent();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      // Handle collision with asteroid
      removeFromParent(); // Remove laser from the game
      other.takeDamage(1); // Inflict damage to the asteroid
    }
  }
}
