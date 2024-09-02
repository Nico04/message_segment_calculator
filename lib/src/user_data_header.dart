/*
 * Represent a User Data Header https://en.wikipedia.org/wiki/User_Data_Header
 * Twilio messages reserve 6 of this per segment in a concatenated message
 */
class UserDataHeader {
  // Optional boolean to indicate if the header is a reserved character.
  bool? isReservedChar;

  // Optional boolean to indicate if this object represents a user data header.
  bool? isUserDataHeader;

  // Constructor that initializes the object properties.
  UserDataHeader() {
    isReservedChar =
        true; // Set to true because user data headers are reserved characters.
    isUserDataHeader =
        true; // Explicitly marks this object as a user data header.
  }

  // A static method to return the size of a code unit in bits for user data headers.
  static int codeUnitSizeInBits() {
    return 8; // User data headers use 8 bits per code unit.
  }

  // Instance method to return the total size in bits of the user data header.
  int sizeInBits() {
    return 8; // Each user data header has a fixed size of 8 bits.
  }
}
