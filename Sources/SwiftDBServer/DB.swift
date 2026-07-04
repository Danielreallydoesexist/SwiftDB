import Foundation

typealias DBRow = [String: DBValue]
typealias DBTable = [String: DBRow]

struct DB: Codable, Sendable {
    var users: DBTable = [:]
    var posts: DBTable = [:]
    var messages: DBTable = [:]
}