import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_space_shooter/components/asteroid.dart';
import 'package:flutter_space_shooter/components/explosion.dart';
import 'package:flutter_space_shooter/components/laser.dart';
import 'package:flutter_space_shooter/my_game.dart';
import 'package:flutter/services.dart';

// Origialnlly the Player was a SpriteComponent, but we change it to SpriteAnimationComponent
// This allows us to have an animated player ship
class Player extends SpriteAnimationComponent
    with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks {
  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _timeSinceLastFire = 0.0;
  final Vector2 _keyboardMovements = Vector2.zero();
  bool _isDestroyed = false;
  final Random _random = Random.secure();

  @override
  FutureOr<void> onLoad() async {
    // Here we are loading a sprite from assets/images/player_blue_on0.png
    animation = await _loadAnimation();

    // Set the size of the player, while maintaining aspect ratio
    size *= 0.3; // scale down the size to 30%

    //collider for the player
    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // This adds movement from both joystick and keyboard
    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovements;
    if (_isDestroyed) {
      return; // if destroyed, do not allow movement
    }
    position +=
        movement.normalized() *
        200 *
        dt; // always * the dt because update is called every frame, and the dt is the time difference between frames

    _handleScreenBoundaries();

    _timeSinceLastFire += dt; // this keeps track of time since last fire
    if (_isShooting && _timeSinceLastFire >= _fireCooldown) {
      // fire lazer
      _fireLazer();
      _timeSinceLastFire = 0.0; // reset the timer
    }
  }

  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList(
      [
        await game.loadSprite('player_blue_on0.png'),
        await game.loadSprite('player_blue_on1.png'),
      ],
      stepTime: 0.1,
      loop: true,
    );
  }

  // inside the player we handle the screen bounds\
  void _handleScreenBoundaries() {
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    // Next prevent the player from going off the edges of the screen
    position.y = clampDouble(position.y, size.y / 2, screenHeight - size.y / 2);

    // prevent going off left and right edges
    // position.x = clampDouble(position.x, size.x / 2, screenWidth - size.x / 2);

    // if the player goes off the left edge, we want it to appear on the right edge
    if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;

      // else if it goes off the right edge, appear on the left edge
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }

  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireLazer() {
    // we need to create a new laser component and add it to the game
    // here we set the laser position to be at the top center of the player
    // the Vector2(0, -size.y / 2) offsets the laser to be at the top of the player
    game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2)));
  }

  void _createRandomExplision() {
    // Generate a random position somewhere within the bounds of this component.
    // This creates variation so explosions don't always appear in the same spot.
    final Vector2 explosionPosition = Vector2(
      // X position:
      // Start at this component's X position, then offset by a random value
      // within its width, while re-centering to keep it visually balanced.
      position.x + (_random.nextDouble() * size.x) - (size.x / 2),

      // Y position:
      // Same logic as X, but for vertical placement.
      position.y + (_random.nextDouble() * size.y) - (size.y / 2),
    );

    // Randomly decide which type of explosion to create.
    // 50% chance for smoke, 50% chance for fire.
    final ExplosionType explosionType = _random.nextBool()
        ? ExplosionType.smoke
        : ExplosionType.fire;

    // Create a new Explosion instance using the generated data.
    final Explosion explosion = Explosion(
      // Where the explosion will appear in the game world
      position: explosionPosition,

      // Size of the explosion relative to this component's width.
      // 70% of the current component's size for consistent scaling.
      explosionSize: size.x * 0.7,

      // The visual / animation style of the explosion (smoke or fire)
      explosionType: explosionType,
    );

    // Add the explosion to the game so it gets rendered and updated.
    game.add(explosion);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (_isDestroyed) {
      return; // if already destroyed, do nothing
    }

    if (other is Asteroid) {
      // handle player destruction
      _handleDestruction();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // this gives you access to the keys currently pressed
    _keyboardMovements.x = 0;

    // Note::
    // I tried using Letter Keys, but the porblem with android emulators
    // is that when you hold down a letter key, it cancels straight after its pressed
    // then presses it again after a short delay, like a typewriter effect
    // this doesn't happen with arrow keys, so for now we will use arrow keys for movement

    // check for left and right arrow keys
    _keyboardMovements.x += keysPressed.contains(LogicalKeyboardKey.arrowRight)
        ? 1
        : 0;

    // check for left arrow key
    _keyboardMovements.x -= keysPressed.contains(LogicalKeyboardKey.arrowLeft)
        ? 1
        : 0;

    //
    _keyboardMovements.y = 0;

    // check for up arrow key
    _keyboardMovements.y += keysPressed.contains(LogicalKeyboardKey.arrowUp)
        ? -1
        : 0;

    // check for up and down arrow keys
    _keyboardMovements.y -= keysPressed.contains(LogicalKeyboardKey.arrowDown)
        ? -1
        : 0;

    // this is so that the super class knows we've handled the event
    return true;
  }

  void _handleDestruction() async {
    // here we change the player animation to an "off" state
    animation = SpriteAnimation.spriteList([
      await game.loadSprite('player_blue_off.png'),
    ], stepTime: double.infinity);

    add(
      ColorEffect(
        const Color.fromRGBO(255, 255, 255, 0),
        EffectController(duration: 0.0),
      ),
    );

    add(OpacityEffect.fadeOut(EffectController(duration: 0.3)));

    _isDestroyed = true;
  }
}
