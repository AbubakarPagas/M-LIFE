// Centralised configuration for the Fanar API.
//
// SECURITY NOTE:
//   The API key below is a placeholder. In production:
//   1. Do NOT ship the key in client code.
//   2. Route all Fanar requests through your own backend gateway.
//   3. The backend stores the key in environment variables / secrets manager.
//   4. The mobile app calls YOUR backend, which proxies to Fanar.
//
// For development you can temporarily put the key here or load it from a
// local .env file (excluded from source control).

class FanarApiConfig {
  // Replace with your actual Fanar API key.
  // In production this should come from a secure backend, not be hardcoded.
  static const String apiKey = 'YOUR_FANAR_API_KEY_HERE';

  static const String baseUrl = 'https://api.fanar.qa';

  static const String defaultModel = 'Fanar';

  // System prompt injected at the start of every conversation.
  static const String systemPrompt =
      'You are a helpful AI assistant. '
      'Answer questions accurately and concisely. '
      'Respond in the same language the user writes in.';
}
