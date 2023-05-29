String? textFieldValidator(String? value,
    {bool isRequired = false, bool isNumber = false}) {
  if (!isRequired && (value == null || value.isEmpty)) {
    // If the field is not required and is empty, we don't return any error
    return null;
  } else if (value == null || value.isEmpty) {
    return 'This field is required';
  }

  if (isNumber && (double.tryParse(value) == null)) {
    if (value.contains(',')) {
      return 'Character "," is not valid. Split the decimal part by a "."';
    }

    return 'Please enter a valid number';
  }

  return null;
}
