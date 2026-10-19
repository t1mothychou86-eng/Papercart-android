# A2: Ignore non-string Gemini translation parts

Gemini translation uses `part['text'].toString()`, so a null or structured text field
can appear as garbage in the translated output. Append only string text fields;
skip non-map parts and non-text fields while preserving the order of valid text parts.

Validation: `flutter test test/services/translations/gemini_content_test.dart`.
An HTTP-mocked provider test mixes missing, null, numeric, boolean, list, object,
inline-data and non-map parts with empty and Unicode strings. The exact translated
output is asserted, including a valid literal `null` string. No new dependencies.

Target branch: upstream `main`. Suggested branch: `upstream-fix/gemini-content-types`.
The adjacent patch is independently based on main `289919df407b33c55a60518ae95e6c42aad08fe3`;
it contains no Papercart branding or CN-only modifications. Apply with `git apply`.
Suggested commit: `A2: Ignore non-string Gemini translation parts`.
