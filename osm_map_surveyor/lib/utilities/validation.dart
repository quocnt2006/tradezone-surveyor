class BuildingValidation {
  static String validateName(String name) {
    if (name.trim().isEmpty) return "Building's name can not be empty";
    if (name.isEmpty) return "Building's name can not be empty";
    if (name.length > 150) return "Max length is 150";
    return null;
  }

  static String validateAddress(String address) {
    if (address.trim().isEmpty) return "Building's name can not be empty";
    if (address.isEmpty) return "Building's address can not be empty";
    if (address.length > 300) return "Max length is 300";
    if (address.length < 6) return "Min length is 6";
    return null;
  }

  static String validateImage(String image) {
    if (image == null) {
      return "Image must be available";
    } else {
      if (image.isEmpty) return "Image must be available";
    }
    return null;
  }

  static String validateGeom(String geom) {
    if (geom == null) {
      return "Geom building cannot be null";
    } else {
      if (geom.isEmpty) return "Geom building cannot be null";
    }
    return null;
  }

  static bool validateStreetSegment(String streetsegment) {
    if (streetsegment == null) {
      return false;
    } else {
      if (streetsegment.isEmpty)
        return false;
      else
        return true;
    }
  }
}

class PointsGeomValidation {
  static bool validatePointsGeom(String pointsgeom) {
    if (pointsgeom == null) {
      return false;
    } else {
      if (pointsgeom.isEmpty)
        return false;
      else
        return true;
    }
  }

  static bool validateCheckPointsGeom(String checkpoints) {
    if (checkpoints == null) {
      return false;
    } else {
      if (checkpoints.isEmpty)
        return false;
      else
        return true;
    }
  }
}

class PointGeomValidation {
  static bool validatePointGeom(String pointgeom) {
    if (pointgeom == null) {
      return false;
    } else {
      if (pointgeom.isEmpty)
        return false;
      else
        return true;
    }
  }

  static bool validateCheckPointsGeom(String checkpoints) {
    if (checkpoints == null) {
      return false;
    } else {
      if (checkpoints.isEmpty)
        return false;
      else
        return true;
    }
  }
}

class FloorValidation {
  static String validateName(String name) {
    if (name != null) {
      if (name.isEmpty) {
        return 'Name can not be empty';
      } else {
        if (name.length > 50) {
          return 'Max length is 50';
        } else {
          return null;
        }
      }
    } else {
      return 'Name can not be null';
    }
  }
}

class FloorAreaValidation {
  static String validateName(String name) {
    if (name.isEmpty) return "Floor area name can not be empty";
    if (name.length > 50) return "Max length is 50";
    return null;
  }
}

class StoreValidation {
  static String validateName(String name) {
    if (name != null) {
      if (name.trim().isEmpty) {
        return "Store's name can not be empty";
      } else {
        if (name.trim().length > 150) {
          return "Max length is 150";
        } else {
          return null;
        }
      }
    } else {
     return 'Store name can not be null';
    }
  }

  static String validateTimeSlot(String timeSlot) {
    int timeSlotInt = int.parse(timeSlot);
    if (timeSlotInt == 0) {
      return "error";
    } else {
      return null;
    }
  }

  static String validateAbilityToServe(String ability) {
    if (ability != null) {
      try {
        int abilityInt = int.parse(ability);
        if (abilityInt > 1000) {
          return "Ability to serve max is 1000";
        } else if (abilityInt <= 0) {
          return "Ability to serve min is 1";
        } else {
          return null;
        }
      } catch(e) {
        return "Invalid format";
      }
    } else {
      return 'Ability to serve can not be null';
    }
  }

  static String validateAddress(String address) {
    if (address != null) {
      if (address.trim().isEmpty) {
        return "Store's address can not be empty";
      } else {
        if (address.trim().length > 300) {
          return "Max length is 300";
        } else {
          return null;
        }
      }
    } else {
     return 'Store address can not be null';
    }
  }

  static String validateImage(String image) {
    if (image == null) {
      return "Image must be available";
    } else {
      if (image.isEmpty) return "Image must be available";
    }
    return null;
  }

  static String validateGeom(String geom) {
    if (geom == null) {
      return "Geom store cannot be null";
    } else {
      if (geom.isEmpty) return "Geom store cannot be null";
    }
    return null;
  }
}

class ProfileValidation {
  static String validateFullname(String fullname) {
    if (fullname == null) {
      return 'Full name can be not null';
    } else {
      if (fullname.isEmpty) {
        return 'Full name is empty';
      } else {
        if (fullname.length > 50) {
          return 'Full name length is not longer than 50 characters';
        } else {
          return null;
        }
      }
    }
  }

  static String validatePhoneNumber(String phoneNumber) {
    if (phoneNumber == null) {
      return 'Phone number can be not null';
    } else {
      if (phoneNumber.isEmpty) {
        return 'Phone Number is empty';
      } else {
        if (phoneNumber.length > 11) {
          return 'Phone number length must be 9-11 characters';
        } else if (phoneNumber.length < 9) {
          return 'Phone number length must be 9-11 chracters';
        } else {
          return null;
        }
      }
    }
  }
}

class AnalysisValidation {
  static String validateTimeSlot(String timeSlot) {
    int timeSlotInt = int.parse(timeSlot);
    if (timeSlotInt == 0) {
      return "error";
    } else {
      return null;
    }
  }

  static String validatePrimaryAge(String ageStr) {
    int ageInt = int.parse(ageStr);
    if (ageInt == 0) {
      return "error";
    } else {
      return null;
    }
  }

  static String validatePotentialCustomer(String potentialCustomer) {
    if (potentialCustomer != null) {
      if (potentialCustomer.isEmpty) {
        return 'Potential customer is empty';
      } else {
        int age = int.parse(potentialCustomer);
        if (age >= 10000) {
          return 'Max is 9999';
        } else if (age <= 0) {
          return 'Potential customer is more than 0';
        } else {
          return null;
        }
      }
    } else {
      return 'Primary Age can not be empty.';
    }
  }
}