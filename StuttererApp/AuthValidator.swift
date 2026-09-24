//
//  AuthValidator.swift
//  StuttererApp
//

import Foundation

// checks email and password input before sending it to firebase
enum AuthValidator {

    // shortest password we accept
    static let minPasswordLength = 8

    // returns an error message, or nil if the email looks valid
    static func emailError(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "Please enter your email."
        }

        // something@something.something with no spaces
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if trimmed.range(of: pattern, options: .regularExpression) == nil {
            return "Please enter a valid email address."
        }

        return nil
    }

    // returns an error message, or nil if the password is strong enough
    static func passwordError(_ password: String) -> String? {
        if password.isEmpty {
            return "Please enter a password."
        }

        if password.count < minPasswordLength {
            return "Password must be at least \(minPasswordLength) characters."
        }

        // needs at least one letter and one number
        if password.rangeOfCharacter(from: .letters) == nil ||
            password.rangeOfCharacter(from: .decimalDigits) == nil {
            return "Password must include at least one letter and one number."
        }

        return nil
    }

    // returns an error message, or nil if both passwords match
    static func confirmError(_ password: String, _ confirm: String) -> String? {
        password == confirm ? nil : "Passwords do not match."
    }
}
