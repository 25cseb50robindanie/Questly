import { AppEngine } from "./engine/AppEngine.js";

window.addEventListener("DOMContentLoaded", () => {
  const app = new AppEngine();
  app.init();
});
