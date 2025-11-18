import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_space_shooter/my_game.dart';

enum ExplosionType { dust, smoke, fire }

class Explosion extends PositionComponent with HasGameReference<MyGame> {
  final ExplosionType explosionType;
  final double explosionSize;
  final Random _random = Random();

  Explosion({
    required super.position,
    required this.explosionSize,
    required this.explosionType,
  });

  @override
  FutureOr<void> onLoad() {
    _createFlash();

    // We need to add a delay before removing the explosion to allow the flash effect to be visible
    add(RemoveEffect(delay: 1.0));

    return super.onLoad();
  }

  void _createFlash() {
    // Here we create a bright flash effect to simulate the explosion
    final CircleComponent flash = CircleComponent(
      radius: explosionSize * 0.6,
      paint: Paint()..color = const Color.fromRGBO(2500, 2550, 255, 1.0),
      anchor: Anchor.center,
    );

    // Here we create a fade out effect for the flash
    final OpacityEffect fadeOutEffect = OpacityEffect.fadeOut(
      EffectController(duration: 0.3),
    );

    // We then add the fade out effect to the flash component
    flash.add(fadeOutEffect);

    // Finally, we add the flash component to the explosion
    add(flash);
  }
}
