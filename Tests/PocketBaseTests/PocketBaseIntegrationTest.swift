//
//  PocketBaseIntegrationTest.swift
//  
//
//  Created by Zhanggy on 21.07.24.
//

import XCTest
import Foundation
import ObjectMapper
import PocketBase

private var client:Client! = nil
private var bookService:CrudService<PBBook>! = nil
private var groupService:CrudService<PBBookGroup>! = nil

class PBBookGroup: RecordModel {
    var name:String = ""
    var description:String = ""
    var books:[PBBook] = []
    var position:Int = 0
    var isPublished = false

    public override func mapping(map: ObjectMapper.Map) {
        name        <- map["name"]
        description <- map["description"]
        books       <- map["expand.books"]
        position    <- map["position"]
        isPublished <- map["isPublished"]
    }
}

class PBBook: RecordModel {
    var name:String = ""
    var description:String?
    var cover:String?
    var narrator:String?
    var publisher:String?
    var publishDate:String?
    var price = 0//扣除点数，0表示免费
    var type = 0
    var ossHashTrail:String?
    var ossHash:String?//http://cdn.goodappwork.com/repo_test/2f72d4bad/book.json
    var assetsSize = -1
    
    class func create(name:String = "",
                      description:String? = nil,
                      cover:String? = nil,
                      narrator:String? = nil,
                      publisher:String? = nil,
                      publishDate:String? = nil,
                      price:Int? = nil,
                      type:Int? = nil,
                      ossHashTrail:String? = nil,
                      ossHash:String? = nil,
                      assetsSize:Int? = nil) -> PBBook {
        let book = PBBook(JSON: [:])!
        book.name = name
        book.description = description
        book.cover = cover
        book.narrator = narrator
        book.publisher = publisher
        book.publishDate = publishDate
        book.ossHashTrail = ossHashTrail
        book.ossHash = ossHash
        if let price {
            book.price = price
        }
        if let type {
            book.type = type
        }
        if let assetsSize {
            book.assetsSize = assetsSize
        }
        return book
    }
    
    public override func mapping(map: ObjectMapper.Map) {
        name        <- map["name"]
        description <- map["description"]
        cover       <- map["cover"]
        narrator    <- map["narrator"]
        publisher   <- map["publisher"]
        publishDate <- map["publishDate"]
        price       <- map["price"]
        type        <- map["type"]
        ossHashTrail <- map["ossHashTrail"]
        ossHash     <- map["ossHash"]
        assetsSize  <- map["assetsSize"]
    }
}


final class PocketBaseIntegrationTest: XCTestCase {
    static var isLoggedIn:Bool = false
    override class func setUp() {
        client = Client(baseUrl: URL(string: "http://localhost.proxyman.io:8090")!)
        bookService = client.collection("books")
        groupService = client.collection("book_groups")

        if client.authStore.isValid {
            isLoggedIn = true
        }
    }
    
    override func setUp() async throws {
        if Self.isLoggedIn{
            return
        }
        
        let (login,passwd) = try loginPairFromEnv()
        let resp = try await client.admins.authWithPassword(email: login, password: passwd)
        XCTAssertNotNil(resp.admin)
        Self.isLoggedIn = true
    }
    
    func testCRUD() async throws {

        let books = try await groupService.getList(page: 1, perPage: 50, options:.init(JSON: ["expand":"books"])!)
        for book in books.items {
            let id = try XCTUnwrap(book.id)
            print("remove: book:\(book.id ?? "nil")")
            try await bookService.delete(id)
        }
        
        for item in [["name":"book_1"]] {
            let name = item["name"]!
            let params =  PBBook.create(name: name).toJSONExceptDefault()
            let book = try await bookService.create(params)
            XCTAssertEqual(book.name, name)
            try XCTAssertGreaterThan(Date.now, XCTUnwrap(book.created))
            try XCTAssertGreaterThan(Date.now, XCTUnwrap(book.updated))
        }
    }
}
