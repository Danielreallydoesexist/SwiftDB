import Vapor
import Foundation

let environment = try Environment.detect()
let app = try await Application.make(environment)

let port = Environment.get("PORT")
    .flatMap(Int.init)
    ?? 8080

app.http.server.configuration.hostname = "0.0.0.0"
app.http.server.configuration.port = port

let databasePath =
    Environment.get("DATABASE_PATH")
    ?? "/data/database.json"

let store = DBStore(
    filePath: databasePath
)

// MARK: - Home

app.get { request async throws -> DatabaseInfoResponse in
    DatabaseInfoResponse(
        name: "SwiftDB",
        version: "0.1.0",
        tables: [
            "users",
            "posts",
            "messages"
        ]
    )
}

// MARK: - Get entire database

app.get("db") { request async throws -> DB in
    await store.getDatabase()
}

// MARK: - Get a table

app.get(":table") { request async throws -> DBTable in
    guard let tableName = request.parameters.get("table") else {
        throw Abort(.badRequest)
    }

    return try await store.getTable(tableName)
}

// MARK: - Get one row

app.get(":table", ":id") { request async throws -> RowResponse in
    guard
        let tableName = request.parameters.get("table"),
        let id = request.parameters.get("id")
    else {
        throw Abort(.badRequest)
    }

    let row = try await store.getRow(
        table: tableName,
        id: id
    )

    return RowResponse(
        id: id,
        values: row
    )
}

// MARK: - Create a row

app.post(":table") { request async throws -> RowResponse in
    guard let tableName = request.parameters.get("table") else {
        throw Abort(.badRequest)
    }

    let input = try request.content.decode(
        CreateRowRequest.self
    )

    let id = input.id ?? UUID().uuidString

    try await store.insert(
        table: tableName,
        id: id,
        values: input.values
    )

    return RowResponse(
        id: id,
        values: input.values
    )
}

// MARK: - Update a row

app.patch(":table", ":id") { request async throws -> RowResponse in
    guard
        let tableName = request.parameters.get("table"),
        let id = request.parameters.get("id")
    else {
        throw Abort(.badRequest)
    }

    let input = try request.content.decode(
        UpdateRowRequest.self
    )

    let updatedRow = try await store.update(
        table: tableName,
        id: id,
        values: input.values
    )

    return RowResponse(
        id: id,
        values: updatedRow
    )
}

// MARK: - Delete a row

app.delete(":table", ":id") { request async throws -> MessageResponse in
    guard
        let tableName = request.parameters.get("table"),
        let id = request.parameters.get("id")
    else {
        throw Abort(.badRequest)
    }

    try await store.delete(
        table: tableName,
        id: id
    )

    return MessageResponse(
        message: "Deleted '\(id)' from '\(tableName)'."
    )
}


try await app.execute()
