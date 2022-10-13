import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wordrope_game/utils.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  //variable used for toggling the volumne button
  bool soundOn = true;
  //variable storing the AudioPlayer() class instance
  final player = AudioPlayer();
  //the word to guess
  String word = wordList[Random().nextInt(wordList.length)];
  //list that will contain the characters that user would have guessed correct
  List guessedAlphabets = [];
  //variable storing thre points of the user
  int points = 0;
  //(7-status) is going to be the life of user
  int status = 0;
  //variable storing the images name in the assets/images folder
  List images = [
    'hangman0.png',
    'hangman1.png',
    'hangman2.png',
    'hangman3.png',
    'hangman4.png',
    'hangman5.png',
    'hangman6.png'
  ];

  //function for playing sound
  void playSound(String sound) async {
    if (soundOn) {
      await player.play(AssetSource('sounds/$sound'));
    }
  }

  //function for building the whole display word
  String handleText() {
    String displayWord = '';
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (guessedAlphabets.contains(char)) {
        displayWord += char + ' ';
      } else {
        displayWord += '? ';
      }
    }
    return displayWord;
  }

  //function for checking if user pressed alphabet is present in the word or not
  checkAlphabet(String alphabet) {
    //if alphabet entered is right then increase the points
    if (word.contains(alphabet)) {
      playSound('correct.mp3');
      setState(() {
        guessedAlphabets.add(alphabet);
        points += 5;
      });
    }
    //if wrong alphabet is entered but lives are left, reduce points and increae status(reduce lives)
    else if (status < 6) {
      playSound('wrong.mp3');
      setState(() {
        status += 1;
        points -= 5;
      });
    }
    //if alphabet entered is wrong and 0 lives left, open dialog box and say you lost
    else {
      playSound('lost.mp3');
      openDialog('You lost !');
    }
    //checking if user has won on each guess
    checkIfWon();
  }

  //function to check if user has won
  void checkIfWon() {
    bool isWon = true;
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      if (!guessedAlphabets.contains(char)) {
        setState(() {
          isWon = false;
        });
        break;
      }
    }
    if (isWon) {
      openDialog('You won !');
    }
  }

  //function for opening the dialog box when game is over i.e. either player lost or won
  openDialog(String title) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 180,
              decoration: const BoxDecoration(color: Colors.purpleAccent),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: retroStyle(20, Colors.white, FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Your points is $points',
                        style: retroStyle(20, Colors.white, FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: InkWell(
                          enableFeedback: false,
                          onTap: () {
                            Navigator.pop(context);
                            playSound('restart.mp3');
                            setState(() {
                              points = 0;
                              status = 0;
                              guessedAlphabets = [];
                              word =
                                  wordList[Random().nextInt(wordList.length)];
                            });
                          },
                          child: Center(
                              child: Text(
                            'Play again ?',
                            style:
                                retroStyle(20, Colors.black, FontWeight.bold),
                          ))),
                    ),
                  ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black45,

        //AppBar
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black45,
          title: Text("WordRope Game",
              style: retroStyle(26, Colors.white, FontWeight.w700)),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  soundOn = !soundOn;
                });
              },
              icon: soundOn
                  ? const Icon(Icons.volume_up_sharp)
                  : const Icon(Icons.volume_off_sharp),
              iconSize: 36,
              color: Colors.purpleAccent,
            )
          ],
        ),

        //Body
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            //Points Box
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.lightBlueAccent),
              width: MediaQuery.of(context).size.width / 3.5,
              height: 30,
              child: Center(
                  child: Text(
                "$points points",
                style: retroStyle(15, Colors.black, FontWeight.w700),
              )),
            ),

            //Spacing
            const SizedBox(
              height: 20,
            ),

            //Image
            Image(
              image: AssetImage("assets/images/${images[status]}"),
              width: 155,
              height: 155,
              color: Colors.white,
              fit: BoxFit.cover,
            ),

            //Spacing
            const SizedBox(
              height: 15,
            ),

            //Text message
            Text(
              "${7 - status} lives left",
              style: retroStyle(18, Colors.grey, FontWeight.w700),
            ),

            //Spacing
            const SizedBox(
              height: 30,
            ),

            // ? mark or guessed word message
            Text(
              handleText(),
              style: retroStyle(35, Colors.white, FontWeight.w700),
              textAlign: TextAlign.center,
            ),

            //Spacing
            const SizedBox(
              height: 15,
            ),

            //Keyboard Pad
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 10),
              childAspectRatio: 1.3,
              children: letters.map((alphabet) {
                return InkWell(
                  enableFeedback: false,
                  onTap: () => checkAlphabet(alphabet),
                  child: Center(
                    child: Text(alphabet,
                        style: retroStyle(20, Colors.white, FontWeight.w700)),
                  ),
                );
              }).toList(),
            )
          ]),
        ));
  }
}
