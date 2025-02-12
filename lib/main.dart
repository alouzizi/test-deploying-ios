import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class GameTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color boardColor;
  final Color xColor;
  final Color oColor;
  final LinearGradient backgroundGradient;

  GameTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.boardColor,
    required this.xColor,
    required this.oColor,
    required this.backgroundGradient,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced XO Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  bool xTurn = true;
  String winner = '';
  int xScore = 0;
  int oScore = 0;
  int draws = 0;
  bool gameOver = false;
  late AnimationController _boardController;
  late Animation<double> _boardAnimation;
  int currentThemeIndex = 0;

  final List<GameTheme> themes = [
    GameTheme(
      name: 'Classic',
      primaryColor: Colors.blue,
      secondaryColor: Colors.red,
      backgroundColor: const Color(0xFFF0F2F5),
      boardColor: Colors.white,
      xColor: Colors.blue,
      oColor: Colors.red,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF0F2F5), Color(0xFFE1E5EA)],
      ),
    ),
    GameTheme(
      name: 'Dark Mode',
      primaryColor: Colors.purple,
      secondaryColor: Colors.teal,
      backgroundColor: const Color(0xFF1A1A1A),
      boardColor: const Color(0xFF2D2D2D),
      xColor: Colors.purple,
      oColor: Colors.teal,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
      ),
    ),
    GameTheme(
      name: 'Nature',
      primaryColor: Colors.green,
      secondaryColor: Colors.brown,
      backgroundColor: const Color(0xFFE8F5E9),
      boardColor: Colors.white,
      xColor: Colors.green,
      oColor: Colors.brown,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      ),
    ),
    GameTheme(
      name: 'Sunset',
      primaryColor: Colors.orange,
      secondaryColor: Colors.pink,
      backgroundColor: const Color(0xFFFFF3E0),
      boardColor: Colors.white,
      xColor: Colors.orange,
      oColor: Colors.pink,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _boardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _boardAnimation = CurvedAnimation(
      parent: _boardController,
      curve: Curves.easeInOut,
    );
    _boardController.forward();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (board[index] == '' && !gameOver) {
      setState(() {
        board[index] = xTurn ? 'X' : 'O';
        xTurn = !xTurn;
        checkWinner();
      });
    }
  }

  void _changeTheme() {
    setState(() {
      currentThemeIndex = (currentThemeIndex + 1) % themes.length;
      _boardController.reset();
      _boardController.forward();
    });
  }

  void checkWinner() {
    // Check rows, columns, and diagonals
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[0]] == board[pattern[2]]) {
        _setWinner(board[pattern[0]]);
        return;
      }
    }

    if (!board.contains('')) {
      _setWinner('Draw');
    }
  }

  void _setWinner(String player) {
    setState(() {
      winner = player;
      gameOver = true;
      if (player == 'X') {
        xScore++;
      } else if (player == 'O') {
        oScore++;
      } else if (player == 'Draw') {
        draws++;
      }
    });
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      xTurn = true;
      winner = '';
      gameOver = false;
      _boardController.reset();
      _boardController.forward();
    });
  }

  void _resetScores() {
    setState(() {
      xScore = 0;
      oScore = 0;
      draws = 0;
      _resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = themes[currentThemeIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: currentTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _resetScores,
                      color: currentTheme.primaryColor,
                    ),
                    Text(
                      'XO Game',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: _changeTheme,
                      color: currentTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              // Score Board
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: currentTheme.boardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreColumn('Player X', xScore, currentTheme.xColor),
                    _buildScoreColumn('Draws', draws, Colors.grey),
                    _buildScoreColumn('Player O', oScore, currentTheme.oColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Turn Indicator
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gameOver
                      ? winner == 'Draw'
                          ? Colors.grey
                          : winner == 'X'
                              ? currentTheme.xColor
                              : currentTheme.oColor
                      : xTurn
                          ? currentTheme.xColor
                          : currentTheme.oColor,
                ),
                child: Text(
                  gameOver
                      ? winner == 'Draw'
                          ? "It's a Draw!"
                          : 'Player $winner Wins!'
                      : "Player ${xTurn ? 'X' : 'O'}'s Turn",
                ),
              ),
              const SizedBox(height: 20),
              // Game Board
              Expanded(
                child: ScaleTransition(
                  scale: _boardAnimation,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _handleTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: currentTheme.boardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 200),
                              tween: Tween(
                                begin: 0.0,
                                end: board[index].isEmpty ? 0.0 : 1.0,
                              ),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Text(
                                    board[index],
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: board[index] == 'X'
                                          ? currentTheme.xColor
                                          : currentTheme.oColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Play Again Button
              if (gameOver)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            score.toString(),
            key: ValueKey<int>(score),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}