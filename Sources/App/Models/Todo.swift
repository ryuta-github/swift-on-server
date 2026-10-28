import Fluent
import Vapor

final class Todo: Model, Content, @unchecked Sendable {
    static let schema = "todos"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "is_completed")
    var isCompleted: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct CreateTodoRequest: Content, Validatable {
    let title: String
    let isCompleted: Bool?

    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty && .count(...200))
    }
}

struct UpdateTodoRequest: Content {
    let title: String?
    let isCompleted: Bool?
}
