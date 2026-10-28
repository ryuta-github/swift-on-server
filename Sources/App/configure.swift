import Fluent
import FluentPostgresDriver
import Vapor

func configure(_ app: Application) async throws {
    let databaseURL = Environment.get("DATABASE_URL")
        ?? "postgres://vapor:vapor@localhost:5432/vapor"

    try app.databases.use(.postgres(url: databaseURL), as: .psql)
    registerMigrations(on: app)
    try routes(app)
}

func registerMigrations(on app: Application) {
    app.migrations.add(CreateTodo())
}
