# A2: Ignore non-string DeepSeek and ChatGPT streaming content

When a streaming delta has `content: null`, translation currently appends the literal word `null`.
Numbers, booleans, lists and objects are also converted to output text. Only string content
should be appended. This change checks the content type in both translation providers and
preserves valid strings, including empty strings and the literal string `null`.

Validation: `flutter test test/services/translations/stream_content_test.dart`.
Two HTTP-mocked integration tests exercise actual provider SSE handling with role-only,
null, numeric, boolean, array, object, reasoning-only, empty, finish and DONE events,
interleaved with Unicode text. No network, credentials or new dependencies are required.

Target branch: upstream `main`. Suggested branch: `upstream-fix/stream-content-types`.
The adjacent patch is independently based on main `289919df407b33c55a60518ae95e6c42aad08fe3`;
it contains no Papercart branding or CN-only modifications. Apply with `git apply`.
Suggested commit: `A2: Ignore non-string DeepSeek and ChatGPT stream deltas`.
