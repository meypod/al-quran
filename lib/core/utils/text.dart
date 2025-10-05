final RegExp alifRegExp = RegExp(r'[اإأآ\u0671\u0670]', unicode: true);
final RegExp yaRegExp = RegExp(r'[يیئ]', unicode: true);
final RegExp differentKafs = RegExp(r'[كک]', unicode: true);
final RegExp abnormalChars = RegExp(
  r'[\ufdf0-\ufdfd\u060c-\u060f\u061b\u061e\u061f\u066d\u06d4\u06dd\u06de\u06e9\u06fd\ufd3e\ufd3f\u064b-\u0652\u0615-\u061A\u06D6-\u06E5ـ]',
  unicode: true,
);

String simplifyText(String input) {
  // Normalize p_alef variants to ا
  return input
      .replaceAll(alifRegExp, 'ا')
      .replaceAll(yaRegExp, 'ي')
      .replaceAll(differentKafs, 'ک')
      .replaceAll(abnormalChars, '');
}
