//
//  CollectionService.swift
//  
//
//  Created by Zhanggy on 14.07.24.
//

import Foundation

public class CollectionService: CrudService<CollectionModel> {
    
    public override var baseCrudPath: String {
        return "/api/collections"
    }
    
    public func doImport(_ collections:[CollectionModel],
                  deleteMissing:Bool = false,
                  options: CommonOptions = CommonOptions()) async throws -> Bool {
        options.method = .PUT
        options.body = ["collections": collections.toJSONExceptDefault(),
                       "deleteMissing":deleteMissing]
        try await self.client.send(self.baseCrudPath + "/import", options)
        return true
    }
}
