import 'dart:convert';

extension FormatString on String {
  String get dollar => '\$$this';
  Map<String, dynamic> get map => json.decode(jsonEncode(this));

  // format enum into uppercase first letter string
  String get formatEnumToUppercaseFirstLetter =>
      '${this[0]}${replaceAll('_', ' ').substring(1).toLowerCase()}';

  String get formatPhoneNumber {
    String result = this;

    if (result.length == 10) {
      result = result.substring(1);
    }

    return '+84 $result';
  }

  String get formatToJson {
    String jsonString = this;

    /// add quotes to json string
    jsonString = jsonString.replaceAll('{', '{"');
    jsonString = jsonString.replaceAll(': ', '": "');
    jsonString = jsonString.replaceAll(', ', '", "');
    jsonString = jsonString.replaceAll('}', '"}');
    jsonString = jsonString.replaceAll('}"', '}');
    jsonString = jsonString.replaceAll('"{', '{');

    /// remove quotes on array json string
    jsonString = jsonString.replaceAll('"[{', '[{');
    jsonString = jsonString.replaceAll('}]"', '}]');

    return jsonString;
  }
}
