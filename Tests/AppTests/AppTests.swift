@testable import App
import FluentSQLiteDriver
import XCTVapor

final class AppTests: XCTestCase {
    private func makeApplication() async throws -> Application {
        let app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        registerMigrations(on: app)
        try routes(app)
        try await app.autoMigrate()
        return app
    }

    func testHelloSwift() async throws {
        let app = try await makeApplication()
        addTeardownBlock { try await app.asyncShutdown() }

        try await app.test(.GET, "hello-swift") { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(
                try response.content.decode(HelloResponse.self).message,
                "Hello, Swift!"
            )
        }
    }

    func testTodoCRUD() async throws {
        let app = try await makeApplication()
        addTeardownBlock { try await app.asyncShutdown() }

        var todoID: UUID?
        try await app.test(
            .POST,
            "todos",
            beforeRequest: { request async throws in
                try request.content.encode(["title": "Vaporを試す"])
            },
            afterResponse: { response async throws in
                XCTAssertEqual(response.status, .created)
                let todo = try response.content.decode(Todo.self)
                todoID = todo.id
                XCTAssertEqual(todo.title, "Vaporを試す")
                XCTAssertFalse(todo.isCompleted)
            }
        )

        let id = try XCTUnwrap(todoID)
        try await app.test(.GET, "todos/\(id)") { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(try response.content.decode(Todo.self).id, id)
        }

        try await app.test(
            .PUT,
            "todos/\(id)",
            beforeRequest: { request async throws in
                try request.content.encode(["isCompleted": true])
            },
            afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)
                XCTAssertTrue(try response.content.decode(Todo.self).isCompleted)
            }
        )

        try await app.test(.DELETE, "todos/\(id)") { response async throws in
            XCTAssertEqual(response.status, .noContent)
        }

        try await app.test(.GET, "todos/\(id)") { response async throws in
            XCTAssertEqual(response.status, .notFound)
        }
    }

    func testRejectsEmptyTitle() async throws {
        let app = try await makeApplication()
        addTeardownBlock { try await app.asyncShutdown() }

        try await app.test(
            .POST,
            "todos",
            beforeRequest: { request async throws in
                try request.content.encode(["title": ""])
            },
            afterResponse: { response async throws in
                XCTAssertEqual(response.status, .badRequest)
            }
        )
    }
}
