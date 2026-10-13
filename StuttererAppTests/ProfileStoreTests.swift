//
//  ProfileStoreTests.swift
//  StuttererApp

import XCTest
import UIKit
@testable import StuttererApp

final class ProfileStoreTests: XCTestCase {

    func testFullNameJoinsFirstAndLast() {
        XCTAssertEqual(ProfileStore.fullName(first: "Ana", last: "Lopez"), "Ana Lopez")
    }

    func testFullNameSkipsBlankParts() {
        XCTAssertEqual(ProfileStore.fullName(first: "  Ana ", last: ""), "Ana")
        XCTAssertEqual(ProfileStore.fullName(first: "", last: "Lopez"), "Lopez")
        XCTAssertNil(ProfileStore.fullName(first: " ", last: ""))
    }

    func testCompressedPhotoFitsInsideMaxSide() throws {
        // a big 1200x800 photo, like one straight from the camera roll
        let big = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 800)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1200, height: 800))
        }
        let original = try XCTUnwrap(big.pngData())

        let compressed = try XCTUnwrap(ProfileStore.compressedPhoto(from: original))
        let result = try XCTUnwrap(UIImage(data: compressed))

        XCTAssertEqual(max(result.size.width, result.size.height), ProfileStore.maxPhotoSide)
        // small enough to live inside a firestore document
        XCTAssertLessThan(compressed.count, 200_000)
    }

    func testCompressedPhotoRejectsNonImageData() {
        XCTAssertNil(ProfileStore.compressedPhoto(from: Data("not an image".utf8)))
    }
}
