import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_space_shooter/my_game.dart';

class Asteroid extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final Random _random = Random();
  static const double _maxSize = 120;
  late Vector2 _velocity;
  late double _spinSpeed;

  // Constructor for creating an asteroid
  // - position: where the asteroid appears on screen
  // - size: the width/height of the asteroid (defaults to _maxSize if not specified)
  Asteroid({required super.position, double size = _maxSize})
    : super(
        size: Vector2.all(
          size,
        ), // Creates a square asteroid (same width and height)
        anchor: Anchor.center, // Centers the asteroid on its position
        priority: -1, // Render behind other game objects
      ) {
    _velocity = _generateVelocity(); // Set random movement direction and speed
    _spinSpeed =
        _random.nextDouble() * 1.5 -
        0.75; // Random spin speed between -0.75 and 0.75
  }

  @override
  Future<void> onLoad() async {
    final int imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');

    //This hitbox will automatically size itself to the size of the component (the parent component)
    // It will also automatically update its position when the parent component moves
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // By updating the position based on velocity and delta time,
    // this will move the asteroid down the screen
    position += _velocity * dt;

    _handleScreenBoundaries();

    // angle comes from the SpriteComponent class
    angle += _spinSpeed * dt; // Rotate the asteroid

    if (position.y > game.size.y + size.y / 2) {
      // if the asteroid goes off the bottom of the screen, remove it
      // this helps free up memory and processing power
      removeFromParent();
    }

    // Call the superclass update method
    super.update(dt);
  }

  Vector2 _generateVelocity() {
    // We're diving the velocity by size to make smaller asteroids move faster
    final double forceFactor = _maxSize / size.x;

    // The x value will always be going left or right
    // The y value will always be going down
    return Vector2(
          _random.nextDouble() * 100 -
              60, // sets the x velocity between -60 and 40
          100 +
              _random.nextDouble() *
                  50, // sets the y velocity between 100 and 150
        ) *
        forceFactor; // we multiply by forceFactor to adjust speed based on size
  }

  void _handleScreenBoundaries() {
    final double screenWidth = game.size.x;

    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }

    if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }
}
