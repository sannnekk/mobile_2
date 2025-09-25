import 'package:mobile_2/core/entities/work.dart';

class TaskChecker {
  static String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r"\s+"), '');
  }

  static int checkAnswer(String? answer, WorkTaskEntity task) {
    if (task.type != WorkTaskType.word ||
        task.rightAnswer == null ||
        task.rightAnswer!.isEmpty) {
      return 0;
    }

    final rightAnswers = task.rightAnswer!
        .split('|')
        .map((e) => e.trim().toLowerCase())
        .toList();

    List<int> scores = [];

    switch (task.checkingStrategy) {
      case TaskCheckingStrategy.type1:
        scores = rightAnswers
            .map((a) => checkType1(answer, a, task.highestScore))
            .toList();
        break;
      case TaskCheckingStrategy.type2:
        scores = rightAnswers
            .map((a) => checkType2(answer, a, task.highestScore))
            .toList();
        break;
      case TaskCheckingStrategy.type3:
        scores = rightAnswers
            .map((a) => checkType3(answer, a, task.highestScore))
            .toList();
        break;
      case TaskCheckingStrategy.type4:
        scores = rightAnswers
            .map((a) => checkType4(answer, a, task.highestScore))
            .toList();
        break;
      default:
        scores = [];
    }

    // return the highest score
    return scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0;
  }

  static int checkType1(String? answer, String rightAnswer, int maxScore) {
    final a = _normalize(answer ?? '');
    final e = _normalize(rightAnswer);
    return a == e ? maxScore : 0;
  }

  static int checkType2(String? answer, String rightAnswer, int maxScore) {
    final e = _normalize(rightAnswer);
    final w = _normalize(answer ?? '');
    int score = maxScore;

    final minLen = w.length < e.length ? w.length : e.length;
    for (int i = 0; i < minLen; i++) {
      if (w[i] != e[i]) score--;
    }
    score -= (w.length - e.length).abs();

    return score < 0 ? 0 : score;
  }

  static int checkType3(String? answer, String rightAnswer, int maxScore) {
    String e = _normalize(rightAnswer);
    String w = _normalize(answer ?? '');
    int score = maxScore;

    final wl = w.split('');
    final el = e.split('');

    for (int i = 0; i < el.length; i++) {
      if (!wl.contains(el[i])) {
        score--;
      }
    }

    int missingLetters = 0;

    if (e.length < w.length) {
      for (int i = 0; i < wl.length; i++) {
        if (!el.contains(wl[i])) {
          missingLetters++;
        }
      }

      if (w.length - e.length != missingLetters) {
        return 0;
      }
    }

    score = score - missingLetters;

    return score < 0 ? 0 : score;
  }

  static int checkType4(String? answer, String rightAnswer, int maxScore) {
    String e = _normalize(rightAnswer);
    String w = _normalize(answer ?? '');

    maxScore -= (w.length - e.length).abs();

    int errorCount = 0;

    final minLen = w.length < e.length ? w.length : e.length;
    for (int i = 0; i < minLen; i++) {
      if (w[i] != e[i]) errorCount++;
    }
    errorCount += (w.length - e.length).abs();

    return errorCount == 0 ? maxScore : (errorCount <= 2 ? maxScore - 1 : 0);
  }
}
