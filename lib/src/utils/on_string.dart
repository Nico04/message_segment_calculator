extension CustomStringExt on String? {
  bool get isNullOrEmpty => this == null || (this ?? '').trim().isEmpty;
  bool get notNullNorEmpty =>
      this != null &&
      (this ?? '').trim().isNotEmpty &&
      (this ?? '').trim() != 'null';
  String get firstLetterToCap {
    if (isNullOrEmpty) return '';

    final temp = <String>[];
    this!.trim().split(' ').toList().forEach((element) {
      if (element.trim().isEmpty) return;
      temp.add(element[0].toUpperCase() + element.substring(1));
    });
    return temp.join(' ');
  }
}
