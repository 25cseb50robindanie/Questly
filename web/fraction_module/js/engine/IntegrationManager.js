/**
 * IntegrationManager owns the integration contract with the Questly parent frame.
 * Emits postMessage payloads for start, progress, and completion states.
 */
export class IntegrationManager {
  constructor(gameId = "fraction_forge") {
    this.gameId = gameId;
  }

  /**
   * Dispatches the Game Start event hooks.
   */
  sendGameStart() {
    console.log(`[Questly Integration] Game Start: ${this.gameId}`);
    
    const event = new CustomEvent("questly_game_start", {
      detail: { gameId: this.gameId }
    });
    window.dispatchEvent(event);

    if (window.parent && window.parent !== window) {
      window.parent.postMessage({
        type: "QUESTLY_GAME_START",
        gameId: this.gameId
      }, "*");
    }
  }

  /**
   * Dispatches Game Progress event hooks when a level is completed.
   */
  sendGameProgress(levelIndex, score, mistakes) {
    console.log(`[Questly Integration] Progress: Level ${levelIndex + 1} completed. Score: ${score}, Mistakes: ${mistakes}`);

    const event = new CustomEvent("questly_game_progress", {
      detail: {
        gameId: this.gameId,
        levelCompleted: levelIndex + 1,
        score: score,
        mistakes: mistakes
      }
    });
    window.dispatchEvent(event);

    if (window.parent && window.parent !== window) {
      window.parent.postMessage({
        type: "QUESTLY_GAME_PROGRESS",
        gameId: this.gameId,
        levelCompleted: levelIndex + 1,
        score: score,
        mistakes: mistakes
      }, "*");
    }
  }

  /**
   * Dispatches the final Game Complete event payload.
   * Conforms to the postMessage contract specified in sections 11-12.
   */
  sendGameComplete(finalScore, earnedStars, mistakes) {
    const payload = {
      type: "QUESTLY_GAME_COMPLETE",
      gameId: this.gameId,
      score: finalScore,
      completed: true,
      stars: earnedStars,
      mistakes: mistakes
    };

    console.log("[Questly Integration] Game Complete. Payload:", payload);

    const event = new CustomEvent("questly_game_complete", {
      detail: payload
    });
    window.dispatchEvent(event);

    if (window.parent && window.parent !== window) {
      window.parent.postMessage(payload, "*");
    }
  }

  /**
   * Dispatches the Navigate Back event to the Questly Flutter parent frame.
   */
  sendNavigateBack() {
    console.log("[Questly Integration] Navigate Back Requested");
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({
        type: "QUESTLY_NAVIGATE_BACK",
        gameId: this.gameId
      }, "*");
    }
  }
}
