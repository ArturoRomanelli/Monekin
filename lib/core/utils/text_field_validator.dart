String? textFieldValidator(String? value,
    {bool isRequired = false, bool isNumber = false}) {
  if (isRequired && (value == null || value.isEmpty)) {
    return 'This field is required';
  } else if (isNumber && (double.tryParse(value!) == null)) {
    if (value.contains(',')) {
      return 'Character "," is not valid. Split the decimal part by a "."';
    }

    return 'Please enter a valid number';
  }

  return null;
}
