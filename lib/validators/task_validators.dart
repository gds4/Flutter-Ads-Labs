import 'package:intl/intl.dart';

class TaskValidators{

  static String? existsTitle(String? value){
    if(value == null || value.isEmpty){
      return "Forneça um título";
    }
    return null;
  }

  static String? isMinimalLength(String input){
    if(input.length < 3){
      return "O título deve possuir no mínimo 3 caracteres";
    }
    return null;
  }


  static String? containsOnlyLetters(String input) {
    final pattern = RegExp(r'^[a-zA-Z\s\u00C0-\u00FF]+$');
    if(!pattern.hasMatch(input)){
      return "O título deve conter apenas letras";
    }
    return null;
  }

  static String? titleValidators(String value){
    var validators = [ existsTitle, isMinimalLength, containsOnlyLetters];
    for(var validator in validators){
      final result = validator(value);

      if(result != null){
        return result;
      }
    }
    return null;
  }

  static String? isPastDate(String? value){
    if(DateFormat("dd/MM/yyyy").parse(value!).isBefore(DateTime.now())){
      return "A data não pode ser anterior a hoje";
    }
    return null;
  }

  static String? existsDate(String? value){
    if(value == null || value.isEmpty){
      return "Forneça uma prazo de conclusão";
    }
    return null;
  }

  static String? dateValidators(String? value){
    var validators = [ existsDate, isPastDate ];
    for(var validator in validators){
      final result = validator(value);

      if(result != null){
        return result;
      }
    }
    return null;
  }
}