# A2: Update DeepSeek models and disable thinking for translation

DeepSeek's retired model aliases can make existing users' translation requests fail.
Use `deepseek-flash` by default and send `thinking: {type: disabled}` on translation
requests, so the API's default thinking mode is explicitly disabled.

A shared settings loader updates the provider, AI settings form and chat model fallback.
On the official API, saved `deepseek-chat` and `deepseek-reasoner` selections migrate
once to `deepseek-flash`, with the result persisted. Both used to route to Flash;
translation deliberately requests non-thinking output. Explicit current or unknown model
names remain intact. Third-party endpoint aliases are preserved, including the retired
names, because third parties may define their own compatibility names. Custom URLs
pointing to the exact official host are migrated; lookalike hosts are not.
The settings hint is updated, and async UI loaders check mounted before setState.

Official sources rechecked on 2026-10-19:

- [Chat Completions API](https://api-docs.deepseek.com/api/create-chat-completion/):
  current IDs `deepseek-flash` / `deepseek-v4-pro`, and thinking enabled by default.
- [V4 announcement](https://api-docs.deepseek.com/news/news260424/):
  old aliases retired after July 24, 2026, 15:59 UTC. Its April model names are historical;
  use the current API reference for today's IDs.

Validation: `flutter test test/services/translations/deepseek_settings_test.dart`.
17 tests cover defaults, persisted/idempotent migration of both aliases, custom endpoints,
lookalike hosts, empty values, retained current/custom names, and actual HTTP-mocked
translation requests with the correct model and thinking disabled. No new dependencies.

Target branch: upstream `main`. Suggested branch: `upstream-fix/deepseek-models`.
The adjacent patch is independently based on main `289919df407b33c55a60518ae95e6c42aad08fe3`;
it does not depend on the stream parsing patch and contains no Papercart/CN changes.
Apply with `git apply`.
Suggested commit: `A2: Update DeepSeek defaults, migrate retired models and disable thinking`.
