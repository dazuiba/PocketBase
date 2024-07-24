//
//  TestUtils.swift
//  
//
//  Created by Zhanggy on 20.07.24.
//

import XCTest


func XCTAssertJSONEqual(_ lhs: Any, _ rhs: Any, file: StaticString = #file, line: UInt = #line) {
    guard let stringLeft  = try? String(data: JSONSerialization.data(withJSONObject: lhs, options: [.sortedKeys,.prettyPrinted]), encoding: .utf8) else {
        XCTAssertFalse(false,"invalid json:\(lhs)",file: file,line: line)
        return
    }

    guard let stringRight  = try? String(data: JSONSerialization.data(withJSONObject: rhs, options: [.sortedKeys,.prettyPrinted]), encoding: .utf8) else {
        XCTAssertFalse(false,"invalid json:\(rhs)",file: file,line: line)
        return
    }

    XCTAssertEqual(stringLeft, stringRight,file: file,line: line)
}

func XCTAssertThrowsAsyncError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        // expected error to be thrown, but it was not
        let customMessage = message()
        if customMessage.isEmpty {
            XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
        } else {
            XCTFail(customMessage, file: file, line: line)
        }
    } catch {
        errorHandler(error)
    }
}
