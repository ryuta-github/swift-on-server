import Vapor

struct HelloResponse: Content {
    let message: String
}

func routes(_ app: Application) throws {
    app.get("hello-swift") { _ async -> HelloResponse in
        HelloResponse(message: "Hello, Swift!")
    }

    try app.register(collection: TodoController())
}
