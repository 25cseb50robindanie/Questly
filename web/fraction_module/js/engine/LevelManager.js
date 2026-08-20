import { addFrac, equalFrac, isSimplified, simplify, compareFrac, labelOf } from "../math/fractions.js";
import { GUIDED_PUZZLES, GAME_LEVELS, FINAL_CHALLENGE } from "../data/content.js";

export class LevelManager {
  constructor() {
    this.guided = GUIDED_PUZZLES;
    this.game = GAME_LEVELS;
    this.final = FINAL_CHALLENGE;
  }

  starsFromMistakes(mistakes) {
    if (mistakes === 0) return 3;
    if (mistakes <= 4) return 2;
    return 1;
  }

  sumPlaced(placed) {
    const fracs = placed.filter((p) => p.kind === "frac");
    if (!fracs.length) return { num: 0, den: 1 };
    return fracs.reduce((acc, p) => addFrac(acc, { num: p.num, den: p.den }), { num: 0, den: 1 });
  }

  evaluateFraction(placed, target, options = {}) {
    if (!placed.length) {
      return {
        success: false,
        reason: "empty",
        message: "The span is empty. Place planks that add to the target amount."
      };
    }

    if (placed.some((p) => p.kind !== "frac")) {
      return {
        success: false,
        reason: "wrong-type",
        message: "This span only accepts fraction planks, not ratio supports."
      };
    }

    const sum = this.sumPlaced(placed);

    if (options.requireSimplifiedSingle) {
      if (placed.length !== 1) {
        return {
          success: false,
          reason: "not-single",
          message: "The royal lock accepts only one simplified plank. Merge pieces, then simplify."
        };
      }
      const p = placed[0];
      if (!isSimplified({ num: p.num, den: p.den })) {
        return {
          success: false,
          reason: "unsimplified",
          message: `${labelOf(p)} covers the right amount of space, but it is not simplified. Double-click it to simplify.`
        };
      }
      if (!equalFrac({ num: p.num, den: p.den }, target)) {
        const tooMuch = compareFrac({ num: p.num, den: p.den }, target) > 0;
        return {
          success: false,
          reason: tooMuch ? "over" : "under",
          message: tooMuch
            ? "This is too much. Can you remove a piece or split a larger one?"
            : "These pieces don't completely fill the bridge. Try adding another quarter or eighth."
        };
      }
      return { success: true, reason: "perfect", sum };
    }

    const cmp = compareFrac(sum, target);
    if (cmp < 0) {
      return { success: false, reason: "under", sum, message: this.underMessage(sum, target) };
    }
    if (cmp > 0) {
      return { success: false, reason: "over", sum, message: this.overMessage(sum, target) };
    }

    if (options.requireEquivalent && placed.length < 2) {
      return {
        success: false,
        reason: "need-equivalent",
        message: "Use more than one piece so the span is built from equivalent parts, not a single lucky plank."
      };
    }

    return { success: true, reason: "perfect", sum };
  }

  evaluateRatio(redCount, blueCount, target) {
    if (redCount === 0 && blueCount === 0) {
      return {
        success: false,
        reason: "empty",
        message: "Both towers are empty. Stack red and blue supports to match the ratio."
      };
    }
    if (redCount === 0 || blueCount === 0) {
      return {
        success: false,
        reason: "missing-color",
        message: "A ratio needs both parts. Add the missing color."
      };
    }
    if (redCount * target.blue === blueCount * target.red) {
      return { success: true, reason: "perfect" };
    }
    const current = `${redCount}:${blueCount}`;
    const goal = `${target.red}:${target.blue}`;
    if (redCount / blueCount > target.red / target.blue) {
      return {
        success: false,
        reason: "red-heavy",
        message: `The towers are ${current}. That is more red than ${goal}. Remove a red support or add blue.`
      };
    }
    return {
      success: false,
      reason: "blue-heavy",
      message: `The towers are ${current}. That is more blue than ${goal}. Remove a blue support or add red.`
    };
  }

  underMessage(sum, target) {
    const t = labelOf(target);
    const s = labelOf(simplify(sum));
    if (equalFrac(target, { num: 3, den: 4 }) && equalFrac(sum, { num: 1, den: 2 })) {
      return "These pieces don't completely fill the bridge. Try adding another quarter.";
    }
    if (equalFrac(target, { num: 5, den: 8 }) && equalFrac(sum, { num: 1, den: 2 })) {
      return "Almost! 1/2 is 4/8. The bridge still needs one more eighth.";
    }
    return `Almost! You have ${s}, but the span needs ${t}. A smaller piece can fill the missing section.`;
  }

  overMessage(_sum, target) {
    const t = labelOf(target);
    return `This is too much for a ${t} gap. Can you remove one eighth or a quarter?`;
  }

  hintFor(level, mistakeCount) {
    if (!level.hints || !level.hints.length) return "";
    return level.hints[Math.min(mistakeCount, level.hints.length - 1)];
  }
}
