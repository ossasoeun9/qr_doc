import 'package:qr_doc/models/InvalidOptionModel.dart';

class InvalidOptions {
  const InvalidOptions._();

  static const options = [
    // InvalidOptionModel(0, "Invalid date"),
    InvalidOptionModel(4, "ទំនិញមិនត្រឹមត្រូវ"),
    InvalidOptionModel(1, "បរិមាណមិនត្រឹមត្រូវ"),
    // InvalidOptionModel(2, "Invalid location"),
    InvalidOptionModel(5, "មធ្យេាបាយដឹកជញ្ជូនមិនត្រឹមត្រូវ"),
    other,
  ];

  static const Map<int, InvalidOptionModel> optionAsMap = {
    4: InvalidOptionModel(4, "ទំនិញមិនត្រឹមត្រូវ"),
    1: InvalidOptionModel(1, "បរិមាណមិនត្រឹមត្រូវ"),
    5: InvalidOptionModel(5, "មធ្យេាបាយដឹកជញ្ជូនមិនត្រឹមត្រូវ"),
    3: other,
  };

  static const InvalidOptionModel other = InvalidOptionModel(3, "ផ្សេងៗ");

  static InvalidOptionModel getOptionById(int id) => optionAsMap[id] ?? other;
}
