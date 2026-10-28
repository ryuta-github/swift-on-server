import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.get(use: show)
            todo.put(use: update)
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Todo] {
        try await Todo.query(on: req.db)
            .sort(\.$createdAt, .ascending)
            .all()
    }

    func create(req: Request) async throws -> Response {
        try CreateTodoRequest.validate(content: req)
        let input = try req.content.decode(CreateTodoRequest.self)
        let todo = Todo(
            title: input.title,
            isCompleted: input.isCompleted ?? false
        )
        try await todo.create(on: req.db)
        return try await todo.encodeResponse(status: .created, for: req)
    }

    func show(req: Request) async throws -> Todo {
        try await findTodo(req)
    }

    func update(req: Request) async throws -> Todo {
        let input = try req.content.decode(UpdateTodoRequest.self)
        guard input.title != nil || input.isCompleted != nil else {
            throw Abort(.badRequest, reason: "At least one field must be supplied.")
        }
        if let title = input.title,
           title.isEmpty || title.count > 200
        {
            throw Abort(.badRequest, reason: "Title must contain between 1 and 200 characters.")
        }

        let todo = try await findTodo(req)
        if let title = input.title {
            todo.title = title
        }
        if let isCompleted = input.isCompleted {
            todo.isCompleted = isCompleted
        }
        try await todo.update(on: req.db)
        return todo
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let todo = try await findTodo(req)
        try await todo.delete(on: req.db)
        return .noContent
    }

    private func findTodo(_ req: Request) async throws -> Todo {
        guard let id = req.parameters.get("todoID", as: UUID.self),
              let todo = try await Todo.find(id, on: req.db)
        else {
            throw Abort(.notFound, reason: "Todo not found.")
        }
        return todo
    }
}
