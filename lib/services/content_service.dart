import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/course_models.dart';

/// Loads course content from local JSON assets.
/// Fully offline after the assets are bundled with the app.
class ContentService {
  static Course? _course;
  static Map<String, VocabularyItem> _vocabulary = {};

  static Course? get course => _course;
  static Map<String, VocabularyItem> get vocabulary => _vocabulary;

  static Future<void> loadContent() async {
    if (_course != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/content/spanish_a1.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      _course = Course.fromJson(data['course'] as Map<String, dynamic>);

      final vocabList = data['vocabulary'] as List? ?? [];
      _vocabulary = {
        for (final item in vocabList)
          (item as Map)['id'] as String: VocabularyItem.fromJson(Map<String, dynamic>.from(item)),
      };
    } catch (e) {
      // Fallback minimal content so the app still launches
      _course = _createFallbackCourse();
      _vocabulary = _createFallbackVocabulary();
    }
  }

  static VocabularyItem? getVocab(String id) => _vocabulary[id];

  static List<VocabularyItem> getVocabForLesson(Lesson lesson) {
    return lesson.vocabularyIds
        .map((id) => _vocabulary[id])
        .whereType<VocabularyItem>()
        .toList();
  }

  // ---------- Fallback content (so the UI works even without the JSON file) ----------

  static Course _createFallbackCourse() {
    return Course(
      id: 'spanish_complete',
      languageCode: 'es',
      languageName: 'Spanish',
      baseLanguageCode: 'en',
      levels: [
        Level(
          id: 'a1',
          cefr: CefrLevel.a1,
          title: 'Beginner A1',
          description: 'Basic greetings, introductions and everyday phrases.',
          units: [
            Unit(
              id: 'u1',
              title: 'Greetings & Introductions',
              description: 'Say hello, introduce yourself and ask basic questions.',
              order: 1,
              lessons: [
                Lesson(
                  id: 'l1_1',
                  title: 'Hello & Goodbye',
                  subtitle: 'Essential greetings',
                  order: 1,
                  estimatedMinutes: 4,
                  vocabularyIds: ['v_hola', 'v_adios', 'v_buenos_dias'],
                  sections: [
                    LessonSection(
                      id: 's1',
                      type: 'vocab',
                      title: 'New Words',
                      content: {
                        'items': ['v_hola', 'v_adios', 'v_buenos_dias'],
                      },
                    ),
                    LessonSection(
                      id: 's2',
                      type: 'dialogue',
                      title: 'A Simple Conversation',
                      content: {
                        'lines': [
                          {'speaker': 'Ana', 'text': '¡Hola! ¿Cómo estás?', 'translation': 'Hi! How are you?'},
                          {'speaker': 'Luis', 'text': '¡Hola! Estoy bien, gracias.', 'translation': 'Hi! I am fine, thank you.'},
                          {'speaker': 'Ana', 'text': 'Adiós, ¡hasta luego!', 'translation': 'Goodbye, see you later!'},
                        ],
                      },
                    ),
                    LessonSection(
                      id: 's3',
                      type: 'exercise',
                      title: 'Quick Check',
                      content: {
                        'type': 'multipleChoice',
                        'question': 'How do you say "Hello" in Spanish?',
                        'options': ['Adiós', 'Hola', 'Gracias', 'Por favor'],
                        'correctIndex': 1,
                      },
                    ),
                  ],
                ),
                Lesson(
                  id: 'l1_2',
                  title: 'My Name Is…',
                  subtitle: 'Introducing yourself',
                  order: 2,
                  estimatedMinutes: 5,
                  vocabularyIds: ['v_me_llamo', 'v_mucho_gusto'],
                  sections: [
                    LessonSection(
                      id: 's1',
                      type: 'vocab',
                      title: 'Useful Phrases',
                      content: {
                        'items': ['v_me_llamo', 'v_mucho_gusto'],
                      },
                    ),
                    LessonSection(
                      id: 's2',
                      type: 'exercise',
                      title: 'Practice',
                      content: {
                        'type': 'fillBlank',
                        'sentence': '____ llamo María.',
                        'answer': 'Me',
                        'hint': 'I call myself…',
                      },
                    ),
                  ],
                ),
              ],
            ),
            Unit(
              id: 'u2',
              title: 'Food & Ordering',
              description: 'Order a coffee and basic food items.',
              order: 2,
              lessons: [
                Lesson(
                  id: 'l2_1',
                  title: 'At the Café',
                  order: 1,
                  estimatedMinutes: 6,
                  vocabularyIds: ['v_cafe', 'v_por_favor', 'v_la_cuenta'],
                  sections: [
                    LessonSection(
                      id: 's1',
                      type: 'vocab',
                      title: 'Café Vocabulary',
                      content: {
                        'items': ['v_cafe', 'v_por_favor', 'v_la_cuenta'],
                      },
                    ),
                    LessonSection(
                      id: 's2',
                      type: 'speaking',
                      title: 'Try Saying It',
                      content: {
                        'prompt': 'Un café con leche, por favor.',
                        'translation': 'A coffee with milk, please.',
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Map<String, VocabularyItem> _createFallbackVocabulary() {
    return {
      'v_hola': const VocabularyItem(
        id: 'v_hola',
        word: 'Hola',
        translation: 'Hello / Hi',
        phonetic: 'OH-lah',
        exampleSentence: '¡Hola! ¿Cómo estás?',
        exampleTranslation: 'Hi! How are you?',
        partOfSpeech: 'interjection',
      ),
      'v_adios': const VocabularyItem(
        id: 'v_adios',
        word: 'Adiós',
        translation: 'Goodbye',
        phonetic: 'ah-DYOHS',
        exampleSentence: 'Adiós, hasta mañana.',
        exampleTranslation: 'Goodbye, see you tomorrow.',
      ),
      'v_buenos_dias': const VocabularyItem(
        id: 'v_buenos_dias',
        word: 'Buenos días',
        translation: 'Good morning',
        phonetic: 'BWEH-nos DEE-ahs',
      ),
      'v_me_llamo': const VocabularyItem(
        id: 'v_me_llamo',
        word: 'Me llamo…',
        translation: 'My name is…',
        exampleSentence: 'Me llamo Carlos.',
        exampleTranslation: 'My name is Carlos.',
      ),
      'v_mucho_gusto': const VocabularyItem(
        id: 'v_mucho_gusto',
        word: 'Mucho gusto',
        translation: 'Nice to meet you',
      ),
      'v_cafe': const VocabularyItem(
        id: 'v_cafe',
        word: 'un café',
        translation: 'a coffee',
        exampleSentence: 'Quiero un café, por favor.',
        exampleTranslation: 'I want a coffee, please.',
      ),
      'v_por_favor': const VocabularyItem(
        id: 'v_por_favor',
        word: 'por favor',
        translation: 'please',
      ),
      'v_la_cuenta': const VocabularyItem(
        id: 'v_la_cuenta',
        word: 'la cuenta',
        translation: 'the bill / check',
        exampleSentence: 'La cuenta, por favor.',
        exampleTranslation: 'The bill, please.',
      ),
    };
  }
}
