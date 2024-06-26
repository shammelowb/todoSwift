import Foundation

enum TodoError: Error {
        case indexOutOfBounds
}

struct Todo {
    let id: UUID
    let title: String
    var isCompleted: Bool

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
    }
}

extension Todo: CustomStringConvertible {
    var description: String {
        return self.title
    }
}

extension Todo: Codable{}

protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}


final class JSONFileManagerCache: Cache {
    let fm = FileManager.default

    func save(todos: [Todo]) {
        do {
            let currentDirectoryURL = URL(fileURLWithPath: fm.currentDirectoryPath)
            let fileURL = currentDirectoryURL.appendingPathComponent("todo.json")

            let encoder = JSONEncoder()
            let data = try encoder.encode(todos)
            // options: [.atomicWrite] ensures data integrity. Temporary written to a file before to target file.
            try data.write(to: fileURL, options: [.atomicWrite])
        }catch {
            print("Failed to save todods: \(error)")
        }
    }

    func load() -> [Todo]? {
        do {
            let currentDirectoryURL = URL(fileURLWithPath: fm.currentDirectoryPath)
            let fileURL = currentDirectoryURL.appendingPathComponent("todo.json")

            guard fm.fileExists(atPath: fileURL.path) else {
                print("Todo file does not exist.")
                return nil
            }

            let data = try Data(contentsOf: fileURL)

            let decoder = JSONDecoder()
            let todos = try decoder.decode([Todo].self, from: data)
            return todos
        } catch {
            print("Failed to load todos: \(error)")
            return nil
        }
    }
}



final class InMemoryCache: Cache {
    var tempTodos: [Todo]

    init(todos: [Todo]) {
        tempTodos = [Todo]()
    }

    func save(todos: [Todo]) {
        self.tempTodos = todos    
    }

    func load() -> [Todo]? {
        return tempTodos
    }
}

final class TodoManager {
    var jsonFileManagerCache: JSONFileManagerCache
    var todos: [Todo]

    init() {
        self.todos = [Todo]()
        self.jsonFileManagerCache = JSONFileManagerCache()
        if let savedTodos = jsonFileManagerCache.load() {
            self.todos = savedTodos
        }
        if !self.todos.isEmpty {
            self.listTodos()
        }
    }

    func addTodo(with title: String) {
        todos.append(Todo(title: title))
        jsonFileManagerCache.save(todos: todos)
    }
    
    func listTodos() {
        print("📝 Your todos: ")
        for (index, todo) in todos.enumerated() {
            print("\(index + 1). \(todo.isCompleted ? "✅" : "❌") \(todo)")
        }
    }


    func toggleCompletion(forTodoAtIndex index: Int) throws {
        guard index >= 0 && index < todos.count else {
            throw TodoError.indexOutOfBounds
        }
        todos[index].isCompleted = todos[index].isCompleted ? false : true  
        jsonFileManagerCache.save(todos: todos)
    }

    func deleteTodo(atIndex index: Int) throws {
        guard index >= 0 && index < todos.count else {
            throw TodoError.indexOutOfBounds
        }
        todos.remove(at: index)
        jsonFileManagerCache.save(todos: todos)
    }
    
}


final class App {
    enum Command: String {
        case add, list, toggle, delete, exit
    }

    var command: Command
    let todoManager: TodoManager
    
    init() {
        todoManager = TodoManager()
        command = Command.list
    }

    func commandFromUser() {
        var command: String? = ""
        command = readLine()
        if let instruction = command {
            switch(instruction) {
                case "add": 
                self.command = Command.add
                case "list": 
                self.command = Command.list
                case "toggle": 
                self.command = Command.toggle
                case "delete": 
                self.command = Command.delete
                case "exit": self.command = Command.exit
                default: break
            }
        }   
    }

    func executeCommands() {
        switch(self.command) {  
        case .add:
            print("Enter todo title: ")
            let title = readLine() ?? ""
            todoManager.addTodo(with: title)
        case .list:
            todoManager.listTodos()
        case .toggle:
            print("Enter the number of the todo to toggle: ")
            let index = Int(readLine() ?? "1") ?? -1
            do {
                try todoManager.toggleCompletion(forTodoAtIndex: index - 1)
            }catch TodoError.indexOutOfBounds {
                print("Error: Todo item at the specified index does not exist.")
                break
            } catch {
                print("An unexpected error occured.")
                break
            }
            print("🔄 Todo completion status toggled!")
        case .delete:
            print("Enter the number of the todo to delete: ")
            let index = Int(readLine() ?? "1") ?? -1
            do {
                try todoManager.deleteTodo(atIndex: index - 1)
            }catch TodoError.indexOutOfBounds {
                print("Error: Todo item at the specified index does not exist.")
                break
            } catch {
                print("An unexpected error occured.")
                break
            }
        default: break
        }
    }

    func run() {
        print("\n🌟 Welcome to TODO CLI! 🌟\n")
        repeat {
            print("What would you like to do? (add, list, toggle, delete, exit): ")
            commandFromUser()
            executeCommands()
        } while self.command != Command.exit
        print("👋 Thanks for using Todo CLI! See you next time!")
    }
}

func main() {
    let app = App()
    app.run()
}

main()
