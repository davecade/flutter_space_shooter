import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_space_shooter/components/asteroid.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Shield extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  Shield() : super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('shield.png');
    add(CircleHitbox());

    position = game.player.size / 2;

    final pulsatingEffect = ScaleEffect.to(
      Vector2.all(1.1),
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    );

    final OpacityEffect fadeOutEffect = OpacityEffect.fadeOut(
      EffectController(
        duration: 1,
        startDelay: 3,
        alternate: true,
        repeatCount: 2,
      ),
      onComplete: () => game.player.shieldsDown(),
    );

    // Adds a pulsing effect to the pickup
    add(pulsatingEffect);
    add(fadeOutEffect);

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      other.applyKnockback();
      other.takeDamage(1);
    }
  }
}
