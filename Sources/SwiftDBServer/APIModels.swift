import Vapor

struct CreateRowRequest: Content {
    let id: String?
    let values: DBRow
}

struct UpdateRowRequest: Content {
    let values: DBRow
}

struct RowResponse: Content {
    let id: String
    let values: DBRow
}

struct MessageResponse: Content {
    let message: String
}

struct DatabaseInfoResponse: Content {
    let name: String
    let version: String
    let tables: [String]
}
