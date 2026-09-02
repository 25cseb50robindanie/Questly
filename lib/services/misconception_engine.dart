class MisconceptionDiagnosis {
  final String id;
  final String title;
  final String summary;
  final String studentThinking;
  final String correctConcept;
  final String visualExplanation;
  final String visualType; // 'pizza_comparison', 'fraction_strip', 'number_line', 'ratio_beaker'
  final Map<String, dynamic> visualData;
  final String scaffoldedHint;
  final ScaffoldedRetryProblem retryProblem;

  const MisconceptionDiagnosis({
    required this.id,
    required this.title,
    required this.summary,
    required this.studentThinking,
    required this.correctConcept,
    required this.visualExplanation,
    required this.visualType,
    required this.visualData,
    required this.scaffoldedHint,
    required this.retryProblem,
  });
}

class ScaffoldedRetryProblem {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String feedback;

  const ScaffoldedRetryProblem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.feedback,
  });
}

class MisconceptionEngine {
  final Map<String, MisconceptionDiagnosis> _diagnoses = {
    'larger_denominator_fallacy': MisconceptionDiagnosis(
      id: 'larger_denominator_fallacy',
      title: 'Larger Denominator Misconception',
      summary: 'More pieces means smaller slices!',
      studentThinking: 'You chose a fraction with a larger denominator thinking 8 is bigger than 4, so 1/8 must be bigger than 1/4.',
      correctConcept: 'The denominator tells us how many equal pieces the whole is cut into. The more pieces you cut a pizza into, the SMALLER each slice becomes!',
      visualExplanation: 'Cutting a pizza into 4 slices gives large hearty slices. Cutting the exact same pizza into 8 slices makes each slice half as big!',
      visualType: 'pizza_comparison',
      visualData: {
        'fractionA': {'num': 1, 'den': 4, 'label': '1/4 (Bigger Slice)'},
        'fractionB': {'num': 1, 'den': 8, 'label': '1/8 (Smaller Slice)'},
      },
      scaffoldedHint: 'Remember: Denominator = Number of cuts. More cuts = Smaller slices!',
      retryProblem: ScaffoldedRetryProblem(
        question: 'Would you rather have 1 slice of a pizza cut into 2 pieces (1/2) or 1 slice cut into 10 pieces (1/10)? Which is BIGGER?',
        options: ['1/2 is bigger', '1/10 is bigger', 'They are equal'],
        correctIndex: 0,
        feedback: 'Superb! 1/2 is half the whole pizza, which is much bigger than 1/10!',
      ),
    ),
    'denominator_confusion': MisconceptionDiagnosis(
      id: 'denominator_confusion',
      title: 'Denominator Counting Error',
      summary: 'Denominator is the TOTAL number of parts in the whole.',
      studentThinking: 'You counted only the unshaded or leftover parts for the bottom number.',
      correctConcept: 'The denominator (bottom number) must ALWAYS represent the TOTAL number of all equal parts combined (shaded + unshaded).',
      visualExplanation: 'If a rectangle has 3 red parts and 1 white part, the total parts is 3 + 1 = 4. The red fraction is 3/4, NOT 3/1.',
      visualType: 'fraction_strip',
      visualData: {
        'shaded': 3,
        'unshaded': 1,
        'total': 4,
        'correctFraction': '3/4',
        'wrongFraction': '3/1',
      },
      scaffoldedHint: 'Count ALL the pieces in the whole shape first to find the bottom number.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'A chocolate bar has 2 eaten pieces and 3 remaining pieces. What was the TOTAL number of pieces in the whole bar?',
        options: ['5 total pieces (Denominator = 5)', '3 total pieces (Denominator = 3)', '2 total pieces (Denominator = 2)'],
        correctIndex: 0,
        feedback: 'Correct! 2 + 3 = 5 total pieces, so the denominator is 5!',
      ),
    ),
    'numerator_confusion': MisconceptionDiagnosis(
      id: 'numerator_confusion',
      title: 'Numerator Inversion Error',
      summary: 'Numerator is the top number (parts being selected).',
      studentThinking: 'You flipped the numerator and denominator or counted the unselected parts.',
      correctConcept: 'Top number (Numerator) = How many parts you have. Bottom number (Denominator) = How many total parts make the whole.',
      visualExplanation: 'Remember: N for North (Top) = Number of parts we focus on. D for Down (Bottom) = Divided into total parts.',
      visualType: 'fraction_strip',
      visualData: {
        'numeratorMeaning': 'Parts chosen (Top)',
        'denominatorMeaning': 'Total equal parts (Bottom)',
      },
      scaffoldedHint: 'Top is what you TAKE/SHADE. Bottom is the WHOLE block.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'If you eat 1 slice out of a 6-slice cake, which number goes on top?',
        options: ['1 goes on top (1/6)', '6 goes on top (6/1)', '5 goes on top (5/6)'],
        correctIndex: 0,
        feedback: 'Spot on! You ate 1 slice, so 1 is the numerator on top (1/6)!',
      ),
    ),
    'equivalent_additive_fallacy': MisconceptionDiagnosis(
      id: 'equivalent_additive_fallacy',
      title: 'Equivalent Fraction Scaling Error',
      summary: 'Multiply or divide top and bottom by the SAME number.',
      studentThinking: 'You added the same number to numerator and denominator (e.g. 1/2 + 1/1 = 2/3).',
      correctConcept: 'Equivalent fractions are created by MULTIPLYING or DIVIDING numerator and denominator by the same number, NOT by adding!',
      visualExplanation: '1/2 is equal to 2/4 (both multiplied by 2). If you add 1 to top and bottom of 1/2, you get 2/3, which is 66.7%, NOT 50%!',
      visualType: 'pizza_comparison',
      visualData: {
        'fractionA': {'num': 1, 'den': 2, 'label': '1/2 (50%)'},
        'fractionB': {'num': 2, 'den': 4, 'label': '2/4 (50% Equal!)'},
        'fractionWrong': {'num': 2, 'den': 3, 'label': '2/3 (Not equal to 1/2)'},
      },
      scaffoldedHint: 'Always scale fractions by MULTIPLYING both top and bottom by 2, 3, or 4.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'To find a fraction equivalent to 1/3, multiply top and bottom by 2. What do you get?',
        options: ['2/6', '2/4', '3/5'],
        correctIndex: 0,
        feedback: 'Brilliant! 1×2 = 2 and 3×2 = 6, giving 2/6 which equals 1/3!',
      ),
    ),
    'ratio_order_inversion': MisconceptionDiagnosis(
      id: 'ratio_order_inversion',
      title: 'Ratio Order Reversal',
      summary: 'Order matters in ratios!',
      studentThinking: 'You reversed the items in the ratio (e.g., wrote blue:red when asked for red:blue).',
      correctConcept: 'In ratios, the first item mentioned MUST correspond to the first number. Ratio of A to B is A : B.',
      visualExplanation: 'If there are 4 stars and 2 hearts, the ratio of Stars to Hearts is 4 : 2, whereas Hearts to Stars is 2 : 4.',
      visualType: 'ratio_beaker',
      visualData: {
        'firstQuantity': 'Apples (3)',
        'secondQuantity': 'Bananas (5)',
        'correctRatio': '3 : 5',
        'wrongRatio': '5 : 3',
      },
      scaffoldedHint: 'Match each word in the question to its number in the exact same order.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'There are 3 blue balls and 7 yellow balls. What is the ratio of BLUE balls to YELLOW balls?',
        options: ['3 : 7', '7 : 3', '3 : 10'],
        correctIndex: 0,
        feedback: 'Perfect! Blue comes first (3) and Yellow comes second (7), so 3 : 7!',
      ),
    ),
    'ratio_simplification_subtraction': MisconceptionDiagnosis(
      id: 'ratio_simplification_subtraction',
      title: 'Ratio Simplification Error',
      summary: 'Simplify ratios by dividing by the Greatest Common Divisor (GCD).',
      studentThinking: 'You subtracted numbers instead of dividing by a common factor.',
      correctConcept: 'To simplify a ratio like 6 : 8, divide both numbers by their common factor (2) to get 3 : 4.',
      visualExplanation: '6 : 8 = (6÷2) : (8÷2) = 3 : 4. Both represent the exact same proportion!',
      visualType: 'ratio_beaker',
      visualData: {
        'original': '6 : 8',
        'divisor': '2',
        'simplified': '3 : 4',
      },
      scaffoldedHint: 'Divide both sides by the biggest number that goes into both evenly.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'Simplify the ratio 4 : 8 by dividing both sides by 4:',
        options: ['1 : 2', '2 : 4', '0 : 4'],
        correctIndex: 0,
        feedback: 'Awesome! 4÷4 = 1 and 8÷4 = 2, so the simplest form is 1 : 2!',
      ),
    ),
  };

  MisconceptionDiagnosis? diagnose({
    required String? explicitTrigger,
    required String topic,
    required String selectedOption,
    required String correctOption,
  }) {
    if (explicitTrigger != null && _diagnoses.containsKey(explicitTrigger)) {
      return _diagnoses[explicitTrigger];
    }

    // Heuristic pattern analysis if no explicit trigger tag
    if (topic == 'fractions') {
      if (selectedOption.contains('/') && correctOption.contains('/')) {
        final selParts = selectedOption.split('/');
        final corParts = correctOption.split('/');
        if (selParts.length == 2 && corParts.length == 2) {
          final selNum = int.tryParse(selParts[0].trim());
          final selDen = int.tryParse(selParts[1].trim());
          final corNum = int.tryParse(corParts[0].trim());
          final corDen = int.tryParse(corParts[1].trim());

          if (selNum != null && selDen != null && corNum != null && corDen != null) {
            // Check if student picked bigger denominator thinking it's bigger
            if (selNum == corNum && selDen > corDen) {
              return _diagnoses['larger_denominator_fallacy'];
            }
            // Check if inverted numerator/denominator
            if (selNum == corDen && selDen == corNum) {
              return _diagnoses['numerator_confusion'];
            }
          }
        }
      }
    } else if (topic == 'ratios') {
      if (selectedOption.contains(':') && correctOption.contains(':')) {
        final selParts = selectedOption.split(':');
        final corParts = correctOption.split(':');
        if (selParts.length == 2 && corParts.length == 2) {
          if (selParts[0].trim() == corParts[1].trim() && selParts[1].trim() == corParts[0].trim()) {
            return _diagnoses['ratio_order_inversion'];
          }
        }
      }
    }

    return null;
  }

  List<MisconceptionDiagnosis> getAllDiagnoses() => _diagnoses.values.toList();
}
