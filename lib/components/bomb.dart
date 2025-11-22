import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_space_shooter/components/asteroid.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Bomb extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  Bomb({required super.position})
    : super(size: Vector2.all(1), anchor: Anchor.center, priority: -1);

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('bomb.png');

    // We set this hitbox as solid so that any asteroids created inside the bomb's hitbox
    // will collide with the bomb and take damage
    add(CircleHitbox(isSolid: true));

    // add sequence of effects
    add(
      SequenceEffect([
        SizeEffect.to(
          Vector2.all(800),
          EffectController(duration: 1.0, curve: Curves.easeOut),
        ),
        OpacityEffect.fadeOut(EffectController(duration: 0.5)),
        RemoveEffect(),
      ]),
    );

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      other.takeDamage(1); // Inflict damage to the asteroid
    }
  }
}
