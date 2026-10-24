import 'package:flutter_hbb/mobile/soft_keyboard_diff.dart';
import 'package:flutter_test/flutter_test.dart';

String applyEdits(String remote, List<String> values) {
  for (var i = 1; i < values.length; i++) {
    final edit = diffSoftKeyboardText(values[i - 1], values[i]);
    final runes = remote.runes.toList();
    remote = String.fromCharCodes(runes.take(runes.length - edit.backspaces)) +
        edit.insert;
  }
  return remote;
}

void main() {
  test('appending text sends only the new characters', () {
    expect(diffSoftKeyboardText('11', '11a'), const SoftKeyboardEdit(0, 'a'));
    expect(diffSoftKeyboardText('11', '11ab'), const SoftKeyboardEdit(0, 'ab'));
  });

  test('backspace deletes one character', () {
    expect(diffSoftKeyboardText('11ab', '11a'), const SoftKeyboardEdit(1, ''));
  });

  test('same-length replacement from Vietnamese Telex is sent', () {
    expect(diffSoftKeyboardText('11a', '11â'), const SoftKeyboardEdit(1, 'â'));
    expect(
        diffSoftKeyboardText('11vie', '11viê'), const SoftKeyboardEdit(1, 'ê'));
    expect(diffSoftKeyboardText('11á', '11à'), const SoftKeyboardEdit(1, 'à'));
    expect(diffSoftKeyboardText('11d', '11đ'), const SoftKeyboardEdit(1, 'đ'));
  });

  test('tone mark moved inside a word retypes the tail', () {
    // "hoaf" -> "hoà" style IMEs may place the mark on an earlier vowel.
    expect(diffSoftKeyboardText('11hoà', '11hòa'),
        const SoftKeyboardEdit(2, 'òa'));
  });

  test('suggestion replacing a whole word', () {
    expect(diffSoftKeyboardText('11 viet', '11 việt '),
        const SoftKeyboardEdit(2, 'ệt '));
  });

  test('unchanged value sends nothing', () {
    expect(diffSoftKeyboardText('11abc', '11abc').isEmpty, isTrue);
  });

  test('characters outside the BMP count as one backspace', () {
    expect(diffSoftKeyboardText('11a😀', '11a'), const SoftKeyboardEdit(1, ''));
  });

  test('Telex typing sequence mirrors the final text', () {
    const values = [
      '11',
      '11v',
      '11vi',
      '11vie',
      '11viê',
      '11việ',
      '11việt',
      '11việt ',
      '11việt n',
      '11việt na',
      '11việt nam',
    ];
    expect(applyEdits('', values), 'việt nam');
  });

  test('auto-paired brackets keep remote text in sync', () {
    const values = ['11', '11()', '11(a)', '11(ab)'];
    expect(applyEdits('', values), '(ab)');
  });

  test('real Gboard Vietnamese Telex sequence (with Telex undo)', () {
    // Captured from Gboard "Tiếng Việt" on Android 14 typing
    // "dduowcj ddi hocj<<<<oocj nhes" ('<' = backspace).
    const tails = [
      '',
      'd',
      'đ',
      'đu',
      'đuo',
      'đuơ',
      'đươc',
      'được',
      'được ',
      'được d',
      'được đ',
      'được đi',
      'được đi ',
      'được đi h',
      'được đi ho',
      'được đi hoc',
      'được đi học',
      'được đi họ',
      'được đi h',
      'được đi ',
      'được đi',
      'được đio',
      'được điô',
      'được điôc',
      'được đioocj',
      'được đioocj ',
      'được đioocj n',
      'được đioocj nh',
      'được đioocj nhe',
      'được đioocj nhé',
    ];
    final values = tails.map((t) => '11$t').toList();
    for (var i = 1; i <= values.length; i++) {
      expect(applyEdits('', values.sublist(0, i)), tails[i - 1]);
    }
  });
}
