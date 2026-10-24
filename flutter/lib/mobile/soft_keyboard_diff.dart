/// Edit needed to turn the remote text into the local soft keyboard text.
///
/// The remote caret is assumed to sit at the end of the mirrored text, so the
/// edit is expressed as: press backspace [backspaces] times, then type [insert].
class SoftKeyboardEdit {
  final int backspaces;
  final String insert;

  const SoftKeyboardEdit(this.backspaces, this.insert);

  bool get isEmpty => backspaces == 0 && insert.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is SoftKeyboardEdit &&
      other.backspaces == backspaces &&
      other.insert == insert;

  @override
  int get hashCode => Object.hash(backspaces, insert);

  @override
  String toString() => 'SoftKeyboardEdit($backspaces, "$insert")';
}

/// Diffs two soft keyboard values by their common prefix (in Unicode code
/// points), so IMEs that replace already typed characters (e.g. Vietnamese
/// Telex "viet" -> "việt", autocorrect, suggestions) are mirrored correctly.
SoftKeyboardEdit diffSoftKeyboardText(String oldValue, String newValue) {
  final oldRunes = oldValue.runes.toList(growable: false);
  final newRunes = newValue.runes.toList(growable: false);
  var common = 0;
  final maxCommon =
      oldRunes.length < newRunes.length ? oldRunes.length : newRunes.length;
  while (common < maxCommon && oldRunes[common] == newRunes[common]) {
    common++;
  }
  return SoftKeyboardEdit(
    oldRunes.length - common,
    String.fromCharCodes(newRunes, common),
  );
}
