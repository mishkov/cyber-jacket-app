import 'dart:typed_data';

class Template {
  final int id;
  final String name;
  final Uint8List bytes;

  Template(this.name, this.bytes) : id = 0;

  Template.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        bytes = map['bytes'];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bytes': bytes,
    };
  }
}
