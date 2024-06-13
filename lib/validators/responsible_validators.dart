import 'package:intl/intl.dart';

class ResponsibleValidators{

  static String? existsName(String? value){
    if(value == null || value.isEmpty){
      return "Forneça um nome";
    }
    return null;
  }

  static String? isMinimalLength(String input){
    if(input.length < 3){
      return "O nome deve possuir no mínimo 3 caracteres";
    }
    return null;
  }


  static String? containsOnlyLetters(String input) {
    final pattern = RegExp(r'^[a-zA-Z\s\u00C0-\u00FF]+$');
    if(!pattern.hasMatch(input)){
      return "O nome deve conter apenas letras";
    }
    return null;
  }

  static String? nameValidators(String value){
    var validators = [ existsName, isMinimalLength, containsOnlyLetters];
    for(var validator in validators){
      final result = validator(value);

      if(result != null){
        return result;
      }
    }
    return null;
  }

  static String? minimumAge(String? value){
    if(DateFormat("dd/MM/yyyy").parse(value!).year > 2014){
      return "2014: ano mínimo de nascimento";
    }
    return null;
  }

  static String? existsDate(String? value){
    if(value ==null || value.isEmpty){
      return "Forneça uma data de nascimento";
    }
    return null;
  }

  static String? dateValidators(String? value){
    var validators = [ existsDate, minimumAge];
    for(var validator in validators){
      final result = validator(value);

      if(result != null){
        return result;
      }
    }
    return null;
  }
}
