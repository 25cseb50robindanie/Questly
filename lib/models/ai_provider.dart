abstract class AIProvider {
  // Streams tokens progressively from the LLM
  Stream<String> streamResponse(String prompt, String baseUrl, String modelName);

  // Checks if the local AI server is running and reachable
  Future<bool> isAvailable(String baseUrl);

  // Returns list of deployed models on the server
  Future<List<String>> getAvailableModels(String baseUrl);
}
