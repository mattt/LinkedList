# LinkedList

A doubly-linked list data structure for Swift
with value semantics and copy-on-write behavior.

Linked lists provide efficient `O(1)` insertion and removal
from the beginning or end of a sequence,
making them ideal for implementing queues, stacks, or
managing ordered lists that require frequent additions and removals at their extremities.

## Requirements

- Swift 6.0+ / Xcode 16+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mattt/LinkedList.git", from: "1.0.0")
]
```

## Usage

```swift
import LinkedList

// Create lists from sequences or array literals
var list: LinkedList<String> = ["Alice", "Bob"]

// Append and prepend elements in O(1)
list.append("Charlie")
list.prepend("Zoë")
// list is now ["Zoë", "Alice", "Bob", "Charlie"]

print(list.count)      // 4
print(list.first)    // "Zoë"
print(list.last)     // "Charlie"
print(list.isEmpty)  // false
```

### Insertion and Removal

Elements can be inserted or removed by position (an `Int`) or by a collection `Index`. Positional operations are convenient but have `O(n)` time complexity, as they may require traversing the list.

```swift
var list: LinkedList<String> = ["Alice", "Bob"]
list.prepend("Zoë")
list.append("Charlie")
// list is now ["Zoë", "Alice", "Bob", "Charlie"]

// Insert an element at a specific position (O(n))
list.insert("David", at: 2)
// list is now ["Zoë", "Alice", "David", "Bob", "Charlie"]

// Remove an element from a specific position (O(n))
let removed = list.remove(at: 3) // "Bob"
// list is now ["Zoë", "Alice", "David", "Charlie"]

// Remove elements from the ends (O(1))
let first = list.popFirst() // Optional("Zoë")
// list is now ["Alice", "David", "Charlie"]
let last = list.popLast()   // Optional("Charlie")
// list is now ["Alice", "David"]

// Insert and remove subranges
list.insert(contentsOf: ["Eve", "Frank"], at: 1)
// list is now ["Alice", "Eve", "Frank", "David"]
list.removeSubrange(1..<3)
// list is now ["Alice", "David"]

list.removeAll()
print(list.isEmpty) // true
```

### Element Access

```swift
let list: LinkedList<Int> = [10, 20, 30, 40, 50]

// Integer-based subscript access (O(n))
let element = list[2] // 30

// Safe, optional subscript access (O(n))
let safeElement = list[safe: 2] // Optional(30)
let invalid = list[safe: 10]    // nil

// Range-based subscript access (O(n))
let sublist = list[1..<4] // LinkedList([20, 30, 40])

// Collection subscript access
let firstElement = list[list.startIndex] // 10
let secondIndex = list.index(after: list.startIndex)
let secondElement = list[secondIndex] // 20
```

### Collection Integration

`LinkedList` conforms to `Sequence`, `BidirectionalCollection`, and `RangeReplaceableCollection`, enabling a wide range of standard library operations.

```swift
// Iterate forwards
for element in list {
    print(element)
}

// Iterate backwards
for element in list.reversed() {
    print(element)
}
```

### Functional Operations

Standard functional methods are available for transforming the list.

```swift
let list = LinkedList([1, 2, 3, 4, 5])

let doubled = list.map { $0 * 2 }        // [2, 4, 6, 8, 10]
let evens = list.filter { $0 % 2 == 0 }  // [2, 4]
let sum = list.reduce(0, +)              // 15
```

### Operations for Identifiable Elements

When the `Element` type conforms to `Identifiable`, a powerful set of methods becomes available for querying and manipulating the list based on element IDs.

```swift
struct User: Identifiable, Equatable {
    let id: UUID
    var name: String
}

let id1 = UUID(), id2 = UUID()
var users: LinkedList<User> = [
    User(id: id1, name: "Alice"),
    User(id: id2, name: "Bob"),
    User(id: id1, name: "Alicia")
]

// Find elements by ID
let alice = users.first(id: id1) // User(id: id1, name: "Alice")
let allID1 = users.all(id: id1)  // [User(id: id1, name: "Alice"), User(id: id1, name: "Alicia")]

// Check for existence
let hasBob = users.contains(id: id2) // true

// Mutate elements by ID
users.removeFirst(id: id1)
users.updateFirst(id: id2) { user in
    var updatedUser = user
    updatedUser.name = "Robert"
    return updatedUser
}

// Mutate with subscript
if let index = users.firstIndex(where: { $0.id == id2 }) {
    users[index].name = "Rob"
}

// Efficiently create lookup dictionaries
let userIndex = users.indexedByID() // [id2: User(id: id2, name: "Rob"), id1: User(id: id1, name: "Alicia")]
let userGroups = users.groupedByID() // [id2: [User(id: id2, name: "Rob")], id1: [User(id: id1, name: "Alicia")]]
```

## Performance

| Operation                    | Time Complexity | Space Complexity |
| ---------------------------- | --------------- | ---------------- |
| Access First / Last          | `O(1)`          | `O(1)`           |
| Append / Prepend Element     | `O(1)`          | `O(1)`           |
| Remove First / Last Element  | `O(1)`          | `O(1)`           |
| Remove All                   | `O(1)`          | `O(1)`           |
| Access by Index              | `O(n)`          | `O(1)`           |
| Insert / Remove at Index     | `O(n)`          | `O(1)`           |
| Reverse (in-place)           | `O(n)`          | `O(1)`           |
| Find / Remove by ID          | `O(n)`          | `O(1)`           |
| Construction (from Sequence) | `O(n)`          | `O(n)`           |
| Functional (`map`, `filter`) | `O(n)`          | `O(n)`           |

## Thread Safety

`LinkedList` provides value semantics with copy-on-write behavior,
making it safe to use across multiple threads
when the `Element` type conforms to `Sendable`.
Each list instance maintains its own copy of data when modified,
preventing race conditions.

## License

LinkedList is available under the MIT license.
See the [LICENSE](LICENSE) file for more info.
