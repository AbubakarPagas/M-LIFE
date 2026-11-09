import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/allah_names_data.dart';
import '../model/allah_name_model.dart';

const _kFavKey = 'allah_names_favorites';
const _kLearnedKey = 'allah_names_learned';
const _kRecentKey = 'allah_names_recent';
const _kStreakKey = 'allah_names_streak';
const _kQuizScoresKey = 'allah_names_quiz_scores';

enum NameFilter { all, favorites, learned }

enum ViewMode { grid, list }

class AllahNamesController extends GetxController {
  // ── Lists ─────────────────────────────────────────────────────────────────
  final RxList<AllahName> filteredNames = <AllahName>[].obs;
  final RxSet<int> favorites = <int>{}.obs;
  final RxSet<int> learnedNames = <int>{}.obs;
  final RxList<int> recentlyViewed = <int>[].obs;

  // ── UI state ──────────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final Rx<NameFilter> activeFilter = NameFilter.all.obs;
  final Rx<ViewMode> viewMode = ViewMode.grid.obs;

  // ── Daily name ────────────────────────────────────────────────────────────
  final RxInt dailyNameIndex = 0.obs;

  // ── Memorization ─────────────────────────────────────────────────────────
  final RxInt streak = 0.obs;
  final RxInt flashcardIndex = 0.obs;
  final RxBool showFlashcardAnswer = false.obs;

  // ── Quiz ─────────────────────────────────────────────────────────────────
  final RxInt quizScore = 0.obs;
  final RxInt quizTotal = 0.obs;
  final RxInt currentQuizQuestion = 0.obs;
  final RxList<int> quizScoreHistory = <int>[].obs;

  final TextEditingController searchController = TextEditingController();

  // ── Getters ───────────────────────────────────────────────────────────────
  List<AllahName> get allNames => kAllahNames;

  AllahName get dailyName => kAllahNames[dailyNameIndex.value % 99];

  int get learnedCount => learnedNames.length;
  double get progressPercent =>
      learnedNames.isEmpty ? 0.0 : learnedNames.length / 99;

  List<AllahName> get recentNames =>
      recentlyViewed.take(5).map((i) => kAllahNames[i.clamp(0, 98)]).toList();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _load().then((_) {
      _applyFilter();
      searchController.addListener(() {
        searchQuery.value = searchController.text;
        _applyFilter();
      });
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ── Public actions ────────────────────────────────────────────────────────

  void setFilter(NameFilter f) {
    activeFilter.value = f;
    _applyFilter();
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == ViewMode.grid
        ? ViewMode.list
        : ViewMode.grid;
  }

  void toggleFavorite(int number) {
    if (favorites.contains(number)) {
      favorites.remove(number);
    } else {
      favorites.add(number);
    }
    _persistFavorites();
  }

  bool isFavorite(int number) => favorites.contains(number);

  void markAsLearned(int number) {
    learnedNames.add(number);
    _persistLearned();
  }

  void addToRecent(int number) {
    recentlyViewed.remove(number);
    recentlyViewed.insert(0, number);
    if (recentlyViewed.length > 10) recentlyViewed.removeLast();
    _persistRecent();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilter();
  }

  // ── Flashcard ──────────────────────────────────────────────────────────────

  void nextFlashcard() {
    showFlashcardAnswer.value = false;
    flashcardIndex.value = (flashcardIndex.value + 1) % 99;
  }

  void prevFlashcard() {
    showFlashcardAnswer.value = false;
    final i = flashcardIndex.value - 1;
    flashcardIndex.value = i < 0 ? 98 : i;
  }

  void flipFlashcard() {
    showFlashcardAnswer.toggle();
  }

  AllahName get currentFlashcard => kAllahNames[flashcardIndex.value];

  // ── Quiz ──────────────────────────────────────────────────────────────────

  late List<_QuizQuestion> _quizQuestions;
  final RxInt quizAnswerSelected = (-1).obs;
  final RxBool quizAnswerRevealed = false.obs;

  void startQuiz({int count = 10}) {
    final shuffled = List<AllahName>.from(kAllahNames)..shuffle(Random());
    _quizQuestions = shuffled.take(count).map((name) {
      final wrong = List<AllahName>.from(kAllahNames)
        ..remove(name)
        ..shuffle(Random());
      final options = [name, ...wrong.take(3)]..shuffle(Random());
      return _QuizQuestion(name: name, options: options);
    }).toList();
    quizTotal.value = count;
    quizScore.value = 0;
    currentQuizQuestion.value = 0;
    quizAnswerSelected.value = -1;
    quizAnswerRevealed.value = false;
  }

  _QuizQuestion get currentQuestion =>
      _quizQuestions[currentQuizQuestion.value];

  void selectQuizAnswer(int optionIndex) {
    if (quizAnswerRevealed.value) return;
    quizAnswerSelected.value = optionIndex;
    quizAnswerRevealed.value = true;
    if (currentQuestion.options[optionIndex].number ==
        currentQuestion.name.number) {
      quizScore.value++;
    }
  }

  void nextQuizQuestion() {
    if (currentQuizQuestion.value < quizTotal.value - 1) {
      currentQuizQuestion.value++;
      quizAnswerSelected.value = -1;
      quizAnswerRevealed.value = false;
    } else {
      _saveQuizScore(quizScore.value);
    }
  }

  bool get quizFinished =>
      currentQuizQuestion.value >= quizTotal.value - 1 &&
      quizAnswerRevealed.value;

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(_kFavKey) ?? [];
    final learnList = prefs.getStringList(_kLearnedKey) ?? [];
    final recentList = prefs.getStringList(_kRecentKey) ?? [];
    final scores = prefs.getStringList(_kQuizScoresKey) ?? [];

    favorites.addAll(favList.map(int.parse));
    learnedNames.addAll(learnList.map(int.parse));
    recentlyViewed.addAll(recentList.map(int.parse));
    quizScoreHistory.addAll(scores.map(int.parse));
    streak.value = prefs.getInt(_kStreakKey) ?? 0;

    // Daily name — rotate by day
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    dailyNameIndex.value = dayOfYear % 99;
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kFavKey,
      favorites.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _persistLearned() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kLearnedKey,
      learnedNames.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _persistRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kRecentKey,
      recentlyViewed.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveQuizScore(int score) async {
    quizScoreHistory.insert(0, score);
    if (quizScoreHistory.length > 20) quizScoreHistory.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kQuizScoresKey,
      quizScoreHistory.map((e) => e.toString()).toList(),
    );
  }

  void _applyFilter() {
    final q = searchQuery.value.toLowerCase().trim();
    List<AllahName> base;

    switch (activeFilter.value) {
      case NameFilter.favorites:
        base = kAllahNames.where((n) => favorites.contains(n.number)).toList();
        break;
      case NameFilter.learned:
        base = kAllahNames
            .where((n) => learnedNames.contains(n.number))
            .toList();
        break;
      case NameFilter.all:
        base = kAllahNames;
    }

    if (q.isEmpty) {
      filteredNames.value = base;
    } else {
      filteredNames.value = base.where((n) {
        return n.transliteration.toLowerCase().contains(q) ||
            n.meaning.toLowerCase().contains(q) ||
            n.arabic.contains(q) ||
            n.number.toString() == q;
      }).toList();
    }
  }
}

class _QuizQuestion {
  final AllahName name;
  final List<AllahName> options;
  const _QuizQuestion({required this.name, required this.options});
}
