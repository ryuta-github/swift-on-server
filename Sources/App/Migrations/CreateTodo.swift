import Fluent

struct CreateTodo: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Todo.schema)
            .id()
            .field("title", .string, .required)
            .field("is_completed", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Todo.schema).delete()
    }
}
