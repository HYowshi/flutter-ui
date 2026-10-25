final _combiningMarks = RegExp(r'[\u0300-\u036f]');
final _vietnameseGroups = [
  'àáạảãâầấậẩẫăằắặẳẵ',
  'èéẹẻẽêềếệểễ',
  'ìíịỉĩ',
  'òóọỏõôồốộổỗơờớợởỡ',
  'ùúụủũưừứựửữ',
  'ỳýỵỷỹ',
  'đ',
].map((group) => RegExp('[$group]')).toList(growable: false);

// Shared Vietnamese search folding for local selectors and tables.
String normalizeSearchText(String input) {
  var result = input.toLowerCase().trim().replaceAll(_combiningMarks, '');
  const plain = ['a', 'e', 'i', 'o', 'u', 'y', 'd'];
  for (var i = 0; i < _vietnameseGroups.length; i++) {
    result = result.replaceAll(_vietnameseGroups[i], plain[i]);
  }
  return result;
}
