import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
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
    _createParticles();

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

  List<Color> _generateColors() {
    switch (explosionType) {
      case ExplosionType.dust:
        return [
          const Color(0xFFB2A38B),
          const Color(0xFFD7C4A3),
          const Color(0xFF8C7B6D),
        ];
      case ExplosionType.smoke:
        return [
          const Color(0xFF555555),
          const Color(0xFF777777),
          const Color(0xFF333333),
        ];
      case ExplosionType.fire:
        return [
          const Color(0xFFFF4500),
          const Color(0xFFFFA500),
          const Color(0xFFFFD700),
        ];
    }
  }

  void _createParticles() {
    // Step 1: Get a list of colors to use for the particles
    // This method (defined elsewhere) returns colors like [red, blue, yellow, etc.]
    final List<Color> colors = _generateColors();

    // Step 2: Create a particle system component that will manage all particles
    // ParticleSystemComponent is a Flame component that handles updating and rendering particles
    final ParticleSystemComponent particles = ParticleSystemComponent(
      // Step 3: Use Particle.generate to create multiple particles at once
      // This is a factory method that generates a batch of particles
      particle: Particle.generate(
        // Step 4: Determine how many particles to create
        // Creates between 8 and 12 particles (8 + random number from 0 to 4)
        count: 8 + _random.nextInt(5),

        // Step 5: Define how to create each individual particle
        // This generator function runs once for EACH particle being created
        // 'index' tells you which particle number this is (0, 1, 2, etc.)
        generator: (index) {
          // Step 6: Create a MovingParticle (a particle that moves from point A to B)
          return MovingParticle(
            // Step 7: Define what the particle looks like (the visual)
            // CircleParticle draws a circle on screen
            child: CircleParticle(
              // Step 8: Create a Paint object to define how to draw the circle
              // Paint() creates a new drawing tool
              // The '..' is a cascade operator - it means "on this Paint object, do the following"
              paint: Paint()
                // Step 9: Set the color of the circle
                // Pick a random color from the colors list and modify its transparency
                ..color = colors[_random.nextInt(colors.length)].withValues(
                  // Step 10: Set the transparency (alpha) of the color
                  // Random value between 0.4 (40% visible) and 0.8 (80% visible)
                  // 0.4 is minimum + (random 0.0-1.0 * 0.4) gives range of 0.4-0.8
                  alpha: (0.4 + _random.nextDouble() * 0.4),
                ),

              // Step 11: Set the size of the circle
              // Radius is between 10% and 15% of explosionSize
              // 0.1 is base (10%) + (random 0.0-1.0 * 0.05) adds up to 5% more
              radius: explosionSize * (0.1 + _random.nextDouble() * 0.05),
            ),

            // Step 12: Define where the particle should move TO (the destination)
            // Creates a random direction vector for the particle to travel
            to: Vector2(
              // Step 13: Calculate random X movement
              // random.nextDouble() gives 0.0-1.0, subtract 0.5 gives -0.5 to +0.5
              // Multiply by explosionSize * 2 to spread particles across explosion area
              // Example: if explosionSize=100, this gives -100 to +100 (left to right)
              (_random.nextDouble() - 0.5) * explosionSize * 2,

              // Step 14: Calculate random Y movement (same logic as X)
              // Creates vertical movement from -explosionSize to +explosionSize
              (_random.nextDouble() - 0.5) * explosionSize * 2,
            ),

            // Step 15: Set how long this particle exists before disappearing
            // Random lifespan between 0.5 seconds and 1.0 seconds
            // 0.5 is minimum + (random 0.0-1.0 * 0.5) gives 0.5-1.0 seconds
            lifespan: 0.5 + _random.nextDouble() * 0.5,
          );
        },
      ),
    );

    // Step 16: Add the particle system to the game component tree
    // Flame will now automatically update and render all these particles
    add(particles);
  }
}
