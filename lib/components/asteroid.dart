import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Asteroid extends SpriteComponent with HasGameReference<MyGame> {
  final Random _random = Random();

  Asteroid({required super.position})
    : super(size: Vector2.all(120), anchor: Anchor.center, priority: -1);

  @override
  Future<void> onLoad() async {
    final int imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += Vector2(0, 150) * dt;

    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }

    super.update(dt);
  }
}
