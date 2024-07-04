import AnyCodable
// Convert the following TypeScript code to Swift:
/*
export interface ListResult<T> {
    page: number;
    perPage: number;
    totalItems: number;
    totalPages: number;
    items: Array<T>;
}

export interface BaseModel {
    [key: string]: any;

    id: string;
    created: string;
    updated: string;
}

export interface AdminModel extends BaseModel {
    avatar: number;
    email: string;
}

export interface SchemaField {
    id: string;
    name: string;
    type: string;
    system: boolean;
    required: boolean;
    presentable: boolean;
    options: { [key: string]: any };
}

export interface CollectionModel extends BaseModel {
    name: string;
    type: string;
    schema: Array<SchemaField>;
    indexes: Array<string>;
    system: boolean;
    listRule?: string;
    viewRule?: string;
    createRule?: string;
    updateRule?: string;
    deleteRule?: string;
    options: { [key: string]: any };
}

export interface ExternalAuthModel extends BaseModel {
    recordId: string;
    collectionId: string;
    provider: string;
    providerId: string;
}

export interface LogModel extends BaseModel {
    level: string;
    message: string;
    data: { [key: string]: any };
}

export interface RecordModel extends BaseModel {
    collectionId: string;
    collectionName: string;
    expand?: { [key: string]: any };
}

*/

// Swift code:
// 1. swift struct 不能继承，使用 protocol+extension+struct 来实现

protocol BaseModel {
    var id: String { get set }
    var created: String { get set }
    var updated: String { get set }
}

struct AdminModel: BaseModel,Codable {
    var id: String
    var created: String
    var updated: String
    var avatar: Int
    var email: String
}

struct SchemaField: Codable {
    var id: String
    var name: String
    var type: String
    var system: Bool
    var required: Bool
    var presentable: Bool
    var options: [String: AnyCodable]
}

struct CollectionModel: BaseModel,Codable {
    var id: String
    var created: String
    var updated: String
    var name: String
    var type: String
    var schema: [SchemaField]
    var indexes: [String]
    var system: Bool
    var listRule: String?
    var viewRule: String?
    var createRule: String?
    var updateRule: String?
    var deleteRule: String?
    var options: [String: AnyCodable]
}

struct ExternalAuthModel: BaseModel, Codable {
    var id: String
    var created: String
    var updated: String
    var recordId: String
    var collectionId: String
    var provider: String
    var providerId: String
}

struct LogModel: BaseModel,Codable {
    var id: String
    var created: String
    var updated: String
    var level: String
    var message: String
    var data: [String: AnyCodable]
}

class RecordModel: BaseModel, Codable {
    var id: String
    var created: String
    var updated: String
    var collectionId: String
    var collectionName: String
    var expand: [String: AnyCodable]
    init(id: String, created: String, updated: String, collectionId: String, collectionName: String, expand: [String : AnyCodable]) {
        self.id = id
        self.created = created
        self.updated = updated
        self.collectionId = collectionId
        self.collectionName = collectionName
        self.expand = expand
    }
}

// 2. ListResult<T> 使用泛型

struct ListResult<T:Codable>: Codable {
    var page: Int
    var perPage: Int
    var totalItems: Int
    var totalPages: Int
    var items: [T]
}

// 3. 使用 typealias 来简化类型定义

typealias AdminModelListResult = ListResult<AdminModel>
typealias CollectionModelListResult = ListResult<CollectionModel>
typealias ExternalAuthModelListResult = ListResult<ExternalAuthModel>
typealias LogModelListResult = ListResult<LogModel>
typealias RecordModelListResult = ListResult<RecordModel>
