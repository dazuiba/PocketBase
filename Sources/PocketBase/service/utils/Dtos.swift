import Foundation
import ObjectMapper

open class BaseModel:Mappable {
    
    public var id:String?
    public var created:Date?
    public var updated:Date?
    public required init?(map: ObjectMapper.Map) {
        
    }
    
    open func mapping(map: ObjectMapper.Map) {
        id      <- map["id"]
        created <- (map["created"],DateFormatterTransform.defaultPocketBase)
        updated <- (map["updated"],DateFormatterTransform.defaultPocketBase)
    }
    
}

public class ExternalAuthModel: BaseModel {
    
    var recordId: String = ""
    var collectionId: String = ""
    var provider: String = ""
    var providerId: String = ""

    public override func mapping(map: ObjectMapper.Map) {
        super.mapping(map: map)
        recordId     <- map["recordId"]
        collectionId <- map["collectionId"]
        provider     <- map["provider"]
        providerId   <- map["providerId"]    
    }
}

public class LogModel: BaseModel {
    var level: String = ""
    var message: String = ""
    var data = [String: Any]()
    
    public required init?(map: ObjectMapper.Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: ObjectMapper.Map) {
        super.mapping(map: map)
        level   <- map["level"]
        message <- map["message"]
        data    <- map["data"]
    }
}


open class RecordModel: BaseModel {
    var collectionId = ""
    var collectionName = ""
    
    var avatar = 0
    var email = ""
    var verified = false
    
    var expands = [String: Any]()
    
    public  required init?(map: ObjectMapper.Map) {
        super.init(map: map)
    }
    
    open override func mapping(map: ObjectMapper.Map) {
        super.mapping(map: map)
        collectionId   <- map["collectionId"]
        collectionName <- map["collectionName"]
        avatar         <- map["avatar"]
        email          <- map["email"]
        verified       <- map["verified"]
        expands        <- map["expands"]        
    }
    
    public func isCollectionEqualTo(_ nameOrId:String) -> Bool {
        return [self.collectionId,self.collectionName].contains(nameOrId)
    }
}

public class CollectionModel : BaseModel {
    var schema:[SchemaField] = [SchemaField]()
    var indexes:[String] = [String]()

    var system:Bool = false

    var listRule:String = ""
    var viewRule:String = ""
    var createRule:String = ""

    var updateRule:String = ""

    var deleteRule:String = ""

    var options = [String: Any]()
    public override func mapping(map: ObjectMapper.Map) {
        super.mapping(map: map)
        schema     <- map["schema"]
        indexes    <- map["indexes"]
        system     <- map["system"]
        listRule   <- map["listRule"]
        viewRule   <- map["viewRule"]
        createRule <- map["createRule"]
        updateRule <- map["updateRule"]
        deleteRule <- map["deleteRule"]
        options    <- map["options"]
    }
}
//
//class AuthModel: RecordModel {
//}

public typealias AdminModel = RecordModel
public typealias AuthModel = RecordModel

public class TokenObject: Mappable {
    enum AuthType: String {
        case admin
        case authRecord
    }
    var id = ""
    var collectionId = ""
    var type = AuthType.authRecord
    
    // expire
    var exp:Double = -1
    
    public required init?(map: ObjectMapper.Map) {
        
    }
    
    public func mapping(map: ObjectMapper.Map) {
        id           <- map["id"]
        collectionId <- map["collectionId"]
        exp          <- map["exp"]
        type         <- map["type"]        
    }
    
    public func isValid() -> Bool {
        return !self.isTokenExpired()
    }
    
    public func isTokenExpired(expirationThreshold:Int = 0) -> Bool {
        guard self.exp > 0 else { return false }
        return Date().timeIntervalSince1970 >= exp
    }
}


public class AuthPayload: Mappable {
    
    var token:String = ""
    var model:AuthModel?
    private var _tokenObj:TokenObject?

    public required init?(map: ObjectMapper.Map) {
    }
    
    public func mapping(map: ObjectMapper.Map) {
        token <- map["token"]
        model <- map["model"]
    }
    
    public var tokenObj: TokenObject? {
        if _tokenObj == nil {
            _tokenObj = Utils.getTokenPayload(self.token)
        }
        return _tokenObj
    }
    
    public init(token: String, model: AuthModel? = nil) {
        self.token = token
        self.model = model
    }
    
}


// 2. ListResult<T> 使用泛型

public struct ListResult<T:Mappable>: Mappable {
    public init?(map: ObjectMapper.Map) {
        
    }
    
    public mutating func mapping(map: ObjectMapper.Map) {
        page       <- map["page"]
        perPage    <- map["perPage"]
        totalItems <- map["totalItems"]
        totalPages <- map["totalPages"]
        items      <- map["items"]
    }
    
    public var page: Int = 0
    public var perPage: Int = 0
    public var totalItems: Int = 0
    public var totalPages: Int = 0
    public var items = [T]()
}

// 3. 使用 typealias 来简化类型定义


public struct SchemaField {
    var id: String
    var name: String
    var type: String
    var system: Bool
    var required: Bool
    var presentable: Bool
    var options: [String: Any]
}


typealias AdminModelListResult = ListResult<AdminModel>
typealias CollectionModelListResult = ListResult<CollectionModel>
typealias ExternalAuthModelListResult = ListResult<ExternalAuthModel>
typealias LogModelListResult = ListResult<LogModel>
typealias RecordModelListResult = ListResult<RecordModel>
