import 'package:flutter/cupertino.dart';
import 'package:flutter_space_shooter/my_game.dart';

class TitleOverlay extends StatefulWidget {
  final MyGame game; // We need to import the game instance

  const TitleOverlay({super.key, required this.game});

  @override
  State<TitleOverlay> createState() => _TitleOverlayState();
}

class _TitleOverlayState extends State<TitleOverlay> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Will animate the opacity to 1.0 after the first frame build
    Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String playerColor =
        widget.game.playerColors[widget.game.playerColorIndex];
    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0.0) {
          // only remove the overlay when the opacity animation ends and the opacity is 0.0
          widget.game.overlays.remove('Title');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            SizedBox(width: 270, child: Image.asset('assets/images/title.png')),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // This is the left arrow button
                GestureDetector(
                  onTap: () {
                    widget.game.audioManager.playSound('click');
                    setState(() {
                      widget.game.playerColorIndex--;
                      if (widget.game.playerColorIndex < 0) {
                        widget.game.playerColorIndex =
                            widget.game.playerColors.length - 1;
                      }
                    });
                  },
                  child: Transform.flip(
                    flipX: true,
                    child: SizedBox(
                      width: 100,
                      child: Image.asset('assets/images/arrow_button.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/player_${playerColor}_off.png',
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                // This is the right arrow button
                GestureDetector(
                  onTap: () {
                    widget.game.audioManager.playSound('click');
                    setState(() {
                      widget.game.playerColorIndex++;
                      if (widget.game.playerColorIndex ==
                          widget.game.playerColors.length) {
                        widget.game.playerColorIndex = 0;
                      }
                    });
                  },
                  child: SizedBox(
                    width: 100,
                    child: Image.asset('assets/images/arrow_button.png'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                widget.game.audioManager.playSound('start');
                // Start the game
                widget.game.startGame();

                // Fade out the overlay
                setState(() {
                  _opacity = 0.0;
                });
              },
              child: SizedBox(
                width: 200,
                child: Image.asset('assets/images/start_button.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
