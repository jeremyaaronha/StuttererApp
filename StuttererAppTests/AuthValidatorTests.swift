//
//  AuthValidatorTests.swift
//  StuttererApp

import XCTest
@testable import StuttererApp

final class AuthValidatorTests: XCTestCase {

    // MARK: - Email

    func testEmailEmptyReturnsError() {
        XCTAssertNotNil(AuthValidator.emailError(""))
    }

    func testEmailMissingAtSignReturnsError() {
        XCTAssertNotNil(AuthValidator.emailError("rodrigoexample.com"))
    }

    func testEmailValidReturnsNil() {
        XCTAssertNil(AuthValidator.emailError("rodrigo@example.com"))
    }

    // MARK: - Password

    func testPasswordEmptyReturnsError() {
        XCTAssertNotNil(AuthValidator.passwordError(""))
    }

    func testPasswordTooShortReturnsError() {
        XCTAssertNotNil(AuthValidator.passwordError("ab1"))
    }

    func testPasswordMissingNumberReturnsError() {
        XCTAssertNotNil(AuthValidator.passwordError("password"))
    }

    func testPasswordMissingLetterReturnsError() {
        XCTAssertNotNil(AuthValidator.passwordError("12345678"))
    }

    func testPasswordValidReturnsNil() {
        XCTAssertNil(AuthValidator.passwordError("password1"))
    }

    // MARK: - Confirm password

    func testConfirmMismatchReturnsError() {
        XCTAssertNotNil(AuthValidator.confirmError("password1", "password2"))
    }

    func testConfirmMatchReturnsNil() {
        XCTAssertNil(AuthValidator.confirmError("password1", "password1"))
    }
}
