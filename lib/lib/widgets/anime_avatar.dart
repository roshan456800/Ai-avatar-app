import 'package:flutter/material.dart';

class AnimeAvatar extends StatefulWidget {
  const AnimeAvatar({
    super.key,
    required this.isTalking,
    this.imagePath = 'assets/images/anime_girl.png',
    this.size = 280,
  });

  final bool isTalking;
  final String imagePath;
  final double size;

  @override
  State<AnimeAvatar> createState() => _AnimeAvatarState();
}

class _AnimeAvatarState extends State<AnimeAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _talkController;
  late final AnimationController _idleController;

  late final Animation<double> _talkScale;
  late final Animation<double> _mouthScale;
  late final Animation<double> _idleFloat;

  @override
  void initState() {
    super.initState();

    _talkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _talkScale = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(
      CurvedAnimation(
        parent: _talkController,
        curve: Curves.easeInOut,
      ),
    );

    _mouthScale = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _talkController,
        curve: Curves.easeInOut,
      ),
    );

    _idleFloat = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimeAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isTalking) {
      _talkController.repeat(reverse: true);
    } else {
      _talkController.stop();
      _talkController.animateBack(0);
    }
  }

  @override
  void dispose() {
    _talkController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _talkController,
        _idleController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _idleFloat.value),
          child: Transform.scale(
            scale: _talkScale.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      widget.imagePath,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.24,
                    child: AnimatedOpacity(
                      opacity: widget.isTalking ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Transform.scale(
                        scaleY: _mouthScale.value,
                        child: Container(
                          width: widget.size * 0.12,
                          height: widget.size * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.isTalking)
                    Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Speaking...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
