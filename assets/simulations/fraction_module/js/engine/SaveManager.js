/**
 * SaveManager handles reading and writing from localStorage.
 * Incorporates defensive parsing and gracefully falls back to in-memory storage
 * if localStorage is unavailable (e.g. private browsing, security settings).
 */
export class SaveManager {
  constructor() {
    this.isStorageAvailable = this._checkStorageAvailability();
    this.memoryStorage = {};
  }

  /**
   * Internal helper to test if localStorage is supported and writable.
   */
  _checkStorageAvailability() {
    try {
      const testKey = "__storage_test__";
      window.localStorage.setItem(testKey, testKey);
      window.localStorage.removeItem(testKey);
      return true;
    } catch (e) {
      console.warn("localStorage is not available. Falling back to in-memory storage.", e);
      return false;
    }
  }

  /**
   * Save a key-value pair.
   * @param {string} key 
   * @param {*} value - Will be JSON stringified
   */
  save(key, value) {
    const serialized = JSON.stringify(value);
    if (this.isStorageAvailable) {
      try {
        window.localStorage.setItem(key, serialized);
      } catch (e) {
        console.error(`Failed to save key "${key}" to localStorage:`, e);
      }
    } else {
      this.memoryStorage[key] = serialized;
    }
  }

  /**
   * Load a key's value, falling back to a default value if missing or corrupt.
   * @param {string} key 
   * @param {*} defaultValue 
   * @returns {*} Parsed value or defaultValue
   */
  load(key, defaultValue) {
    let data = null;
    if (this.isStorageAvailable) {
      try {
        data = window.localStorage.getItem(key);
      } catch (e) {
        console.error(`Failed to read key "${key}" from localStorage:`, e);
      }
    } else {
      data = this.memoryStorage[key] || null;
    }

    if (data === null) {
      return defaultValue;
    }

    try {
      return JSON.parse(data);
    } catch (e) {
      console.error(`Failed to parse cached data for key "${key}":`, e);
      return defaultValue;
    }
  }

  /**
   * Clear a specific key.
   * @param {string} key 
   */
  clear(key) {
    if (this.isStorageAvailable) {
      try {
        window.localStorage.removeItem(key);
      } catch (e) {
        console.error(`Failed to clear key "${key}" from localStorage:`, e);
      }
    } else {
      delete this.memoryStorage[key];
    }
  }
}
