//
//  MsicTestCase.swift
//  
//
//  Created by Zhanggy on 21.07.24.
//

import XCTest
import Foundation
@testable import PocketBase

// fmt: YYYY-MM-dd
private func formatDate(date: Date, fmt: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fmt
    return dateFormatter.string(from: date)
}

final class MsicTestCase: XCTestCase {
    func testUtils() throws {
        let a = String.join(["aaa","",""])
        print(a)
        
        let string = formatDate(date: Date(), fmt: "yyyy-MM-dd")
        print(string)
    }

}
