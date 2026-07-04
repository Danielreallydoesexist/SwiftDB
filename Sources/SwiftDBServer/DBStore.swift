import Foundation
import Vapor

actor DBStore {
    private var database: DB
    private let fileURL: URL

    init(filePath: String) {
        self.fileURL = URL(fileURLWithPath: filePath)

        if let data = try? Data(contentsOf: fileURL),
           let savedDatabase = try? JSONDecoder().decode(DB.self, from: data) {
            self.database = savedDatabase
        } else {
            self.database = DB()
        }
    }

    func getDatabase() -> DB {
        database
    }

    func getTable(_ name: String) throws -> DBTable {
        switch name {
        case "users":
            return database.users

        case "posts":
            return database.posts

        case "messages":
            return database.messages

        default:
            throw Abort(
                .notFound,
                reason: "Table '\(name)' does not exist."
            )
        }
    }

    func getRow(
        table tableName: String,
        id: String
    ) throws -> DBRow {
        let table = try getTable(tableName)

        guard let row = table[id] else {
            throw Abort(
                .notFound,
                reason: "Row '\(id)' does not exist."
            )
        }

        return row
    }

    func insert(
        table tableName: String,
        id: String,
        values: DBRow
    ) async throws {
        var table = try getTable(tableName)

        guard table[id] == nil else {
            throw Abort(
                .conflict,
                reason: "A row with ID '\(id)' already exists."
            )
        }

        table[id] = values

        try setTable(
            tableName,
            to: table
        )

        try await save()
    }

    func update(
        table tableName: String,
        id: String,
        values: DBRow
    ) async throws -> DBRow {
        var table = try getTable(tableName)

        guard var row = table[id] else {
            throw Abort(
                .notFound,
                reason: "Row '\(id)' does not exist."
            )
        }

        for (key, value) in values {
            row[key] = value
        }

        table[id] = row

        try setTable(
            tableName,
            to: table
        )

        try await save()

        return row
    }

    func delete(
        table tableName: String,
        id: String
    ) async throws {
        var table = try getTable(tableName)

        guard table.removeValue(forKey: id) != nil else {
            throw Abort(
                .notFound,
                reason: "Row '\(id)' does not exist."
            )
        }

        try setTable(
            tableName,
            to: table
        )

        try await save()
    }

    private func setTable(
        _ name: String,
        to table: DBTable
    ) throws {
        switch name {
        case "users":
            database.users = table

        case "posts":
            database.posts = table

        case "messages":
            database.messages = table

        default:
            throw Abort(
                .notFound,
                reason: "Table '\(name)' does not exist."
            )
        }
    }

    private func save() async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        let data = try encoder.encode(database)

        let folder = fileURL.deletingLastPathComponent()

        try FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )

        try data.write(
            to: fileURL,
            options: .atomic
        )
    }
}