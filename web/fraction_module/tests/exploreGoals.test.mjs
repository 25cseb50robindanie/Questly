import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { equalFrac } from "../js/math/fractions.js";
import {
  collectionEqualsTarget,
  evaluateExploreGoals,
  hasQuarterEquivalent,
  syncExploreGoalIds,
  QUARTER,
  HALF
} from "../js/math/exploreGoals.js";

const pizza = (num, den) => ({ kind: "frac", num, den, zone: "pizza" });
const bar = (num, den) => ({ kind: "frac", num, den, zone: "bar" });
const shelf = (num, den, crafted = false) => ({ kind: "frac", num, den, crafted });

describe("equivalence of 1/4", () => {
  it("treats 2/8, 3/12, and 1/4 as the same amount", () => {
    assert.equal(equalFrac({ num: 2, den: 8 }, QUARTER), true);
    assert.equal(equalFrac({ num: 3, den: 12 }, QUARTER), true);
    assert.equal(equalFrac({ num: 1, den: 4 }, QUARTER), true);
    assert.equal(equalFrac({ num: 1, den: 2 }, QUARTER), false);
  });

  it("treats two eighths as a quarter", () => {
    assert.equal(
      collectionEqualsTarget(
        [
          { num: 1, den: 8 },
          { num: 1, den: 8 }
        ],
        QUARTER
      ),
      true
    );
  });
});

describe("Build a quarter objective", () => {
  it("is incomplete when only starter 1/4 pieces sit on the shelf", () => {
    const ev = evaluateExploreGoals({
      placed: [],
      inventory: [shelf(1, 4), shelf(1, 4), shelf(1, 8)]
    });
    assert.equal(ev["eighths-to-quarter"], false);
  });

  it("completes when the player places a 1/4 piece", () => {
    assert.equal(hasQuarterEquivalent({ placed: [pizza(1, 4)], inventory: [] }), true);
    assert.equal(evaluateExploreGoals({ placed: [bar(1, 4)] })["eighths-to-quarter"], true);
  });

  it("completes for 2/8 on a board (unsimplified equivalent)", () => {
    assert.equal(evaluateExploreGoals({ placed: [bar(2, 8)] })["eighths-to-quarter"], true);
  });

  it("completes for 1/8 + 1/8 on the bar without merging", () => {
    assert.equal(
      evaluateExploreGoals({ placed: [bar(1, 8), bar(1, 8)] })["eighths-to-quarter"],
      true
    );
  });

  it("completes for merged 2/8 then simplified 1/4 in inventory", () => {
    assert.equal(
      evaluateExploreGoals({ placed: [], inventory: [shelf(2, 8, true)] })["eighths-to-quarter"],
      true
    );
    assert.equal(
      evaluateExploreGoals({ placed: [], inventory: [shelf(1, 4, true)] })["eighths-to-quarter"],
      true
    );
  });

  it("completes for 3/12 or four 1/16s", () => {
    assert.equal(evaluateExploreGoals({ placed: [pizza(3, 12)] })["eighths-to-quarter"], true);
    assert.equal(
      evaluateExploreGoals({
        placed: [bar(1, 16), bar(1, 16), bar(1, 16), bar(1, 16)]
      })["eighths-to-quarter"],
      true
    );
  });

  it("does not complete for a lone 1/2 or a single 1/8", () => {
    assert.equal(evaluateExploreGoals({ placed: [pizza(1, 2)] })["eighths-to-quarter"], false);
    assert.equal(evaluateExploreGoals({ placed: [bar(1, 8)] })["eighths-to-quarter"], false);
  });
});

describe("Cover one half + Continue gating", () => {
  it("marks half when two quarters are placed", () => {
    const ev = evaluateExploreGoals({ placed: [pizza(1, 4), pizza(1, 4)] });
    assert.equal(ev["two-quarters"], true);
    assert.equal(ev["eighths-to-quarter"], true);
  });

  it("marks half for a 1/2 piece or four eighths", () => {
    assert.equal(evaluateExploreGoals({ placed: [bar(1, 2)] })["two-quarters"], true);
    assert.equal(
      evaluateExploreGoals({
        placed: [bar(1, 8), bar(1, 8), bar(1, 8), bar(1, 8)]
      })["two-quarters"],
      true
    );
  });

  it("enables Continue only when both objectives are true", () => {
    const onlyQuarter = evaluateExploreGoals({ placed: [pizza(1, 4)] });
    const syncQuarter = syncExploreGoalIds([], onlyQuarter);
    assert.equal(syncQuarter.allComplete, false);

    const both = evaluateExploreGoals({ placed: [pizza(1, 4), pizza(1, 4)] });
    const syncBoth = syncExploreGoalIds([], both);
    assert.deepEqual(syncBoth.next.sort(), ["eighths-to-quarter", "two-quarters"].sort());
    assert.equal(syncBoth.allComplete, true);
  });
});

describe("dynamic revalidation", () => {
  it("drops the quarter objective when the construction is cleared", () => {
    const before = syncExploreGoalIds([], evaluateExploreGoals({ placed: [bar(1, 4)] }));
    assert.equal(before.next.includes("eighths-to-quarter"), true);

    const after = syncExploreGoalIds(before.next, evaluateExploreGoals({ placed: [], inventory: [shelf(1, 4)] }));
    assert.equal(after.next.includes("eighths-to-quarter"), false);
    assert.deepEqual(after.lost, ["eighths-to-quarter"]);
    assert.equal(after.allComplete, false);
  });

  it("awards newlyCompleted only the first time a goal appears", () => {
    const first = syncExploreGoalIds([], evaluateExploreGoals({ placed: [pizza(1, 4)] }));
    assert.deepEqual(first.newlyCompleted, ["eighths-to-quarter"]);
    const again = syncExploreGoalIds(first.next, evaluateExploreGoals({ placed: [pizza(1, 4)] }));
    assert.deepEqual(again.newlyCompleted, []);
  });
});

describe("half target helper", () => {
  it("does not treat 3/4 as a half", () => {
    assert.equal(collectionEqualsTarget([{ num: 3, den: 4 }], HALF), false);
  });
});
