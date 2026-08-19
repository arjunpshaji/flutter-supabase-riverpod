/// Reusable form-field validators.
///
/// These match the signature Flutter's [TextFormField.validator] expects: take
/// the current text, return `null` when the value is **valid**, or an error
/// message [String] when it is not. That inverted convention (null = success) is
/// easy to get wrong — every branch that passes must return null.
///
/// The methods are `static` because validation is pure logic with no state, so
/// there is nothing to construct: call them as `AppValidator.email`.
///
/// Passing the tear-off (`validator: AppValidator.email`) works because the
/// method signature already matches the callback type. [confirmPassword] needs a
/// second argument, so it cannot be torn off and must be wrapped in a closure at
/// the call site.
class AppValidator {
  /// Requires a non-blank value containing an `@`.
  ///
  /// Deliberately loose — server-side verification (the confirmation email) is
  /// the real check, so an over-strict regex here would only reject valid
  /// addresses.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email required";
    } else if (!value.contains("@")) {
      return "Email format wrong";
    } else {
      return null;
    }
  }

  /// Requires at least 6 characters.
  ///
  /// 6 is Supabase's own default minimum password length. Raising it here
  /// without changing the Supabase Auth setting only tightens the client side;
  /// lowering it would let the request through and fail server-side instead.
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password required";
    } else if (value.length < 6) {
      return "Password must be 6 character long";
    } else {
      return null;
    }
  }

  /// Checks the confirmation field against the [password] typed above it.
  ///
  /// Needs the other field's current text passed in, so at the call site it has
  /// to be wrapped:
  /// `validator: (v) => AppValidator.confirmPassword(v, ctrl.text)`.
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm password required";
    } else if (value != password) {
      return "Passwords does not match";
    } else {
      return null;
    }
  }
}
