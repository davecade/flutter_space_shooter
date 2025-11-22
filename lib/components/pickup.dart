import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_space_shooter/my_game.dart';

enum PickupType { bomb, laser, shield }

class Pickup extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final PickupType pickupType;

  // So remember here, when we do required suoer.position, we're calling the constructor of the
  // parent class SpriteComponent, and passing the position parameter to it.
  Pickup({required super.position, required this.pickupType})
    : super(size: Vector2.all(100), anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('${pickupType.name}_pickup.png');

    // Adds a pulsing effect to the pickup
    add(
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(
          duration: 0.6,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    add(CircleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += 100 * dt; // Move down at 100 pixels per second

    // Remove the pickup if it goes off the bottom of the screen
    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }
  }
}
