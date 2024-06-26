import XCTest
@testable import todo

final class TodoTests: XCTestCase {
    
    func testTodoStructTitleProperty() {
        let todo = Todo(title: "Buy groceries")
        XCTAssertEqual(todo.title, "Buy groceries")
    }
    
    func testTodoStructDescriptionProperty() {
        let todo = Todo(title: "Get milk, eggs, and bread")
        XCTAssertEqual(todo.description, "Get milk, eggs, and bread")
    }
    
    func testTodoStructIsCompletedProperty() {
        var todo = Todo(title: "Walk the dog")
        todo.isCompleted = true
        XCTAssertTrue(todo.isCompleted)
    }
    
}

final class TodoManagerTests: XCTestCase {
    func testAddingTodos() {
        let todoManager = TodoManager()
        todoManager.todos = []
        todoManager.addTodo(with: "Walk the dog")
        todoManager.addTodo(with: "Buy groceries")
        todoManager.addTodo(with: "Do laundry")
        XCTAssert(todoManager.todos.count == 3)
    }
    
    func testDeleteTodo() {
        let todoManager = TodoManager()
        todoManager.todos = []
        do {
            todoManager.addTodo(with: "Walk the dog")
            todoManager.addTodo(with: "Buy groceries")
            todoManager.addTodo(with: "Do laundry")
            
            try todoManager.deleteTodo(atIndex: 1)
        } catch {
            XCTFail("Error deleting todo")
        }
        print(todoManager.todos.count)
        XCTAssert(todoManager.todos.count == 2)
    }
    
    func testToggleCompletion() {
        let todoManager = TodoManager()
        todoManager.todos = []
        do {
            todoManager.addTodo(with: "Walk the dog")
            todoManager.addTodo(with: "Buy groceries")
            todoManager.addTodo(with: "Do laundry")
            try todoManager.toggleCompletion(forTodoAtIndex: 1)
        }catch {
            XCTFail("Toggling completion failed")
        }
        XCTAssert(todoManager.todos[1].isCompleted)
    }
    
    func testLoadSaveImplemenation() {
        let todoManager = TodoManager()
        todoManager.todos = []
        todoManager.addTodo(with: "Walk the dog")
        todoManager.addTodo(with: "Buy groceries")
        todoManager.addTodo(with: "Do laundry")
        
        let jsonFileManagerCache = JSONFileManagerCache()
        jsonFileManagerCache.save(todos: todoManager.todos)
        let loadedTodos = jsonFileManagerCache.load()
        XCTAssertNotNil(loadedTodos)
    }
}

final class JSONFileManagerCacheTests: XCTestCase {
    func testSaveLoadTodos() {
        let jsonFileManagerCache = JSONFileManagerCache()
        jsonFileManagerCache.save(todos: [Todo(title: "Walk the dog")])
        let loadedTodos = jsonFileManagerCache.load()
        XCTAssertNotNil(loadedTodos)
    }
}

final class InMemoryCacheTests: XCTestCase {
    func testSaveLoadTodos() {
        let inMemoryCache = InMemoryCache(todos: [Todo(title: "Walk the dog")])
        inMemoryCache.save(todos: [Todo(title: "Buy groceries")])
        let loadedTodos = inMemoryCache.load()
        XCTAssertNotNil(loadedTodos)
    }
}
