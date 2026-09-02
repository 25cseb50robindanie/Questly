class MisconceptionDiagnosis {
  final String id;
  final String title;
  final String summary;
  final String studentThinking;
  final String correctConcept;
  final String visualExplanation;
  final String visualType; // 'pizza_comparison', 'fraction_strip', 'number_line', 'ratio_beaker', 'scale_comparison', 'hundred_grid'
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
    // -------------------------------------------------------------
    // Quest 1: Fractions Diagnoses
    // -------------------------------------------------------------
    'larger_denominator_fallacy': const MisconceptionDiagnosis(
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
    'denominator_confusion': const MisconceptionDiagnosis(
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
    'numerator_confusion': const MisconceptionDiagnosis(
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
    'equivalent_additive_fallacy': const MisconceptionDiagnosis(
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

    // -------------------------------------------------------------
    // Quest 2: Ratios Diagnoses
    // -------------------------------------------------------------
    'ratio_order_inversion': const MisconceptionDiagnosis(
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
      scaffoldedHint: 'Match the first word in the sentence to the first number in the ratio.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'There are 2 cats and 7 dogs. What is the ratio of CATS to DOGS?',
        options: ['2 : 7', '7 : 2', '2 : 9'],
        correctIndex: 0,
        feedback: 'Exact! Cats came first (2), Dogs second (7), so it is 2 : 7.',
      ),
    ),
    'ratio_simplification_subtraction': const MisconceptionDiagnosis(
      id: 'ratio_simplification_subtraction',
      title: 'Ratio Subtraction Simplification Fallacy',
      summary: 'Simplify ratios by DIVIDING by greatest common factor.',
      studentThinking: 'You tried to simplify a ratio by subtracting numbers instead of dividing.',
      correctConcept: 'To simplify a ratio like 4 : 6, you must DIVIDE both numbers by their common factor (2) to get 2 : 3. Never subtract!',
      visualExplanation: 'Dividing preserves the proportional relationship. Subtraction changes the taste, color, or speed ratio!',
      visualType: 'ratio_beaker',
      visualData: {
        'original': '4 : 6',
        'dividedByTwo': '2 : 3 (Correct)',
        'subtractedTwo': '2 : 4 (Wrong)',
      },
      scaffoldedHint: 'Divide BOTH numbers by their common divisor (e.g. ÷2, ÷3).',
      retryProblem: ScaffoldedRetryProblem(
        question: 'Simplify the ratio 6 : 9 by dividing both by 3:',
        options: ['2 : 3', '3 : 6', '4 : 7'],
        correctIndex: 0,
        feedback: 'Perfect! 6÷3 = 2 and 9÷3 = 3, so 6:9 simplifies to 2:3!',
      ),
    ),

    // -------------------------------------------------------------
    // Quest 3: Proportions Diagnoses
    // -------------------------------------------------------------
    'additive_scaling_fallacy': const MisconceptionDiagnosis(
      id: 'additive_scaling_fallacy',
      title: 'Additive Scaling Fallacy',
      summary: 'Proportions scale by MULTIPLICATION, not addition!',
      studentThinking: 'You added a number to both terms instead of multiplying by the scale factor.',
      correctConcept: 'If 2 cups juice mixes with 3 cups water (2:3), doubling the juice means multiplying by 2 (2×2=4), so water must also be multiplied by 2 (3×2=6). Adding 2 gives 4:5, which ruins the proportion!',
      visualExplanation: 'Scaling a picture or recipe means multiplying all dimensions by the same scale factor k.',
      visualType: 'scale_comparison',
      visualData: {
        'original': '2 : 3',
        'scaleFactor': '×2 = 4 : 6',
        'additiveWrong': '+2 = 4 : 5',
      },
      scaffoldedHint: 'Find what number you MULTIPLIED by, then multiply the other term by that exact same number.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'If 1 potion requires 3 crystals (1 : 3), how many crystals are needed for 4 potions?',
        options: ['12 crystals (4 × 3)', '7 crystals (4 + 3)', '8 crystals'],
        correctIndex: 0,
        feedback: 'Outstanding! 4 potions × 3 crystals each = 12 crystals!',
      ),
    ),
    'cross_multiplication_inversion': const MisconceptionDiagnosis(
      id: 'cross_multiplication_inversion',
      title: 'Cross-Multiplication Inversion',
      summary: 'Multiply diagonally across the equals sign: a × d = b × c.',
      studentThinking: 'You multiplied across the top and bottom instead of cross-multiplying diagonally.',
      correctConcept: 'For the proportion a/b = c/d, the cross-products are equal: a × d = b × c.',
      visualExplanation: 'Draw an "X" connecting numerator of one side to denominator of the other side.',
      visualType: 'scale_comparison',
      visualData: {
        'rule': 'a/b = c/d ==> a*d = b*c',
      },
      scaffoldedHint: 'Multiply top-left with bottom-right, and bottom-left with top-right.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'In the proportion 2/5 = x/10, cross-multiply: 2 × 10 = 5 × x. What is x?',
        options: ['x = 4 (20 ÷ 5)', 'x = 8', 'x = 15'],
        correctIndex: 0,
        feedback: 'Correct! 2 × 10 = 20, and 20 ÷ 5 = 4!',
      ),
    ),

    // -------------------------------------------------------------
    // Quest 4: Percentages Diagnoses
    // -------------------------------------------------------------
    'base_100_misinterpretation': const MisconceptionDiagnosis(
      id: 'base_100_misinterpretation',
      title: 'Percentage Base-100 Misinterpretation',
      summary: 'Percent means "per hundred" (parts out of 100).',
      studentThinking: 'You treated a fraction directly as a percentage without scaling to 100 (e.g. thinking 3/5 = 3%).',
      correctConcept: 'Percent means per hundred (out of 100). To find the percent for 3/5, scale the denominator to 100: 3/5 = 60/100 = 60%!',
      visualExplanation: 'On a 100-square grid, 3 out of 5 columns is 60 individual squares filled, which is 60%.',
      visualType: 'hundred_grid',
      visualData: {
        'fraction': '3/5',
        'scaledTo100': '60/100',
        'percentage': '60%',
      },
      scaffoldedHint: 'Multiply numerator and denominator to make the bottom equal 100.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'What is 1/2 as a percentage (scale 1/2 to have denominator 100)?',
        options: ['50% (50/100)', '12%', '2%'],
        correctIndex: 0,
        feedback: 'Brilliant! 1/2 = 50/100 = 50%!',
      ),
    ),
    'discount_subtraction_fallacy': const MisconceptionDiagnosis(
      id: 'discount_subtraction_fallacy',
      title: 'Discount Percent vs Dollar Fallacy',
      summary: 'Calculate the percentage of the original price first!',
      studentThinking: 'You subtracted the percentage number directly from the dollar price (e.g. \$50 with 20% off = \$30).',
      correctConcept: 'A 20% discount on \$50 means subtracting 20% OF \$50 (which is \$10), giving a final price of \$50 - \$10 = \$40!',
      visualExplanation: '20% of \$50 = 0.20 × 50 = \$10 discount. New price = \$50 - \$10 = \$40.',
      visualType: 'hundred_grid',
      visualData: {
        'originalPrice': 50,
        'discountPercent': 20,
        'discountAmount': 10,
        'finalPrice': 40,
      },
      scaffoldedHint: 'Find the discount amount first: (Discount % / 100) × Original Price.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'A sword costs 100 gold coins. It is on sale for 25% off. How much is the discount in coins?',
        options: ['25 gold coins (25% of 100)', '75 gold coins', '4 gold coins'],
        correctIndex: 0,
        feedback: 'Exactly right! 25% of 100 is 25 gold coins!',
      ),
    ),

    // -------------------------------------------------------------
    // Quest 5: Real-World Applications Diagnoses
    // -------------------------------------------------------------
    'multi_step_order_confusion': const MisconceptionDiagnosis(
      id: 'multi_step_order_confusion',
      title: 'Multi-Step Application Order Error',
      summary: 'Break real-world problems into clear sequential steps.',
      studentThinking: 'You skipped an intermediate calculation or applied steps out of order.',
      correctConcept: 'In multi-step problems (e.g. scaling a recipe and then calculating cost), always compute the scaled quantities first before multiplying by unit cost.',
      visualExplanation: 'Step 1: Scale the ingredient. Step 2: Multiply by cost per unit. Step 3: Sum total budget.',
      visualType: 'scale_comparison',
      visualData: {
        'step1': 'Find total ingredients',
        'step2': 'Calculate cost',
      },
      scaffoldedHint: 'Solve Step 1 first, verify the answer, then proceed to Step 2.',
      retryProblem: ScaffoldedRetryProblem(
        question: 'To build 1 bridge section needs 4 wood planks costing 2 gold each. What is the cost for 3 bridge sections?',
        options: ['24 gold (12 planks × 2 gold)', '14 gold', '8 gold'],
        correctIndex: 0,
        feedback: 'Masterful! 3 sections × 4 planks = 12 planks. 12 planks × 2 gold = 24 gold!',
      ),
    ),
  };

  MisconceptionDiagnosis? diagnose({
    String? explicitTrigger,
    required String topic,
    required String selectedOption,
    required String correctOption,
  }) {
    if (explicitTrigger != null && _diagnoses.containsKey(explicitTrigger)) {
      return _diagnoses[explicitTrigger];
    }

    // Heuristic Fallback based on topic
    if (topic == 'fractions') {
      return _diagnoses['larger_denominator_fallacy'];
    } else if (topic == 'ratios') {
      return _diagnoses['ratio_order_inversion'];
    } else if (topic == 'proportions') {
      return _diagnoses['additive_scaling_fallacy'];
    } else if (topic == 'percentages') {
      return _diagnoses['base_100_misinterpretation'];
    } else if (topic == 'applications') {
      return _diagnoses['multi_step_order_confusion'];
    }
    return null;
  }
}
