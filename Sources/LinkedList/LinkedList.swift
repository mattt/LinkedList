/// A doubly-linked list data structure
/// optimized for efficient insertion and removal operations.
///
/// ```swift
/// var list = LinkedList<Int>()
/// list.append(1)
/// list.append(2)
/// list.append(3)
///
/// // Insert at specific position
/// list.insert(10, at: 1)
///
/// // Remove elements
/// let removed = list.remove(at: 2)
///
/// // Iterate through elements
/// for element in list {
///     print(element)
/// }
/// ```
///
/// ## Performance
///
/// This implementation provides efficient O(1) operations
/// for insertion and removal at the beginning and end,
/// with O(n) operations for random access.
///
/// - **Append/Prepend**: O(1)
/// - **Insert/Remove at index**: O(n)
/// - **Random access**: O(n)
/// - **Space complexity**: O(n)
///
/// ## Thread Safety
///
/// `LinkedList` provides value semantics and copy-on-write behavior,
/// making it safe to use across multiple threads
/// when `Element` conforms to `Sendable`.
///
/// - Parameter Element: The type of elements stored in the list.
///   Must be `Sendable` for thread safety.
@frozen
public struct LinkedList<Element> {
    @usableFromInline
    final class ID: @unchecked Sendable {
        @usableFromInline
        init() {}
    }
    @usableFromInline
    var id = ID()

    @usableFromInline
    final class Node: @unchecked Sendable {
        var value: Element
        var next: Node?
        weak var previous: Node?

        init(value: Element, next: Node? = nil, previous: Node? = nil) {
            self.value = value
            self.next = next
            self.previous = previous
        }

        func copy() -> (head: Node, tail: Node) {
            let newHead = Node(value: value)
            if let next = self.next {
                let copiedRest = next.copy()
                newHead.next = copiedRest.head
                copiedRest.head.previous = newHead
                return (head: newHead, tail: copiedRest.tail)
            } else {
                return (head: newHead, tail: newHead)
            }
        }
    }

    // MARK: - Properties

    private var head: Node?
    private var tail: Node?

    /// The number of elements in the list.
    ///
    /// - Complexity: O(1)
    public private(set) var count: Int = 0

    // MARK: - Initialization

    /// Creates an empty linked list.
    ///
    /// Use this initializer to create a new,
    /// empty linked list that you can populate with elements
    /// using the various insertion methods.
    ///
    /// ```swift
    /// let list = LinkedList<Int>()
    /// ```
    public init() {}

    /// Creates a linked list from a sequence of elements.
    ///
    /// This initializer builds the list
    /// by appending each element from the sequence.
    ///
    /// ```swift
    /// let numbers = [1, 2, 3, 4, 5]
    /// let list = LinkedList(numbers)
    /// ```
    ///
    /// - Parameter elements: A sequence of elements to include in the list.
    /// - Complexity: O(n) where n is the number of elements in the sequence.
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        if let linkedList = elements as? LinkedList<Element> {
            self = linkedList
            return
        }

        self.init()
        for element in elements {
            append(element)
        }
    }

    // MARK: - Private Methods

    /// Ensures copy-on-write semantics
    /// by copying the list if it's shared
    private mutating func ensureUnique() {
        if let head = head, !isKnownUniquelyReferenced(&self.head) {
            let (newHead, newTail) = head.copy()
            self.head = newHead
            self.tail = newTail
            self.id = ID()
        }
    }

    /// Returns the node at the specified index.
    ///
    /// - Parameter index: The position of the node to retrieve.
    /// - Returns: The node at the specified index, or `nil` if the index is out of bounds.
    /// - Complexity: O(n) where n is the number of elements in the list.
    private func node(at position: Int) -> Node? {
        guard position >= 0 && position < count else { return nil }

        if position < count / 2 {
            // Traverse from head
            var current = head
            for _ in 0..<position {
                current = current?.next
            }
            return current
        } else {
            // Traverse from tail
            var current = tail
            for _ in 0..<(count - 1 - position) {
                current = current?.previous
            }
            return current
        }
    }

    // MARK: - Public Interface

    /// A Boolean value indicating whether the list is empty.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        count == 0
    }

    /// The first element in the list.
    ///
    /// - Complexity: O(1)
    public var first: Element? {
        head?.value
    }

    /// The last element in the list.
    ///
    /// - Complexity: O(1)
    public var last: Element? {
        tail?.value
    }

    /// Appends an element to the end of the list.
    ///
    /// This method adds a new element to the end of the list,
    /// making it the new last element.
    ///
    /// ```swift
    /// var list = LinkedList<Int>()
    /// list.append(1)
    /// list.append(2)
    /// // list now contains [1, 2]
    /// ```
    ///
    /// - Parameter element: The element to append to the list.
    /// - Complexity: O(1)
    public mutating func append(_ element: Element) {
        ensureUnique()

        let newNode = Node(value: element)
        if let tail = tail {
            tail.next = newNode
            newNode.previous = tail
        } else {
            head = newNode
        }
        tail = newNode
        count += 1
    }

    /// Appends the elements of a sequence to the end of the list.
    ///
    /// - Parameter newElements: The elements to append.
    /// - Complexity: O(m) where m is the length of `newElements`.
    public mutating func append<S: Sequence>(contentsOf newElements: __owned S)
    where S.Element == Element {
        let elements = Array(newElements)
        if !elements.isEmpty {
            replaceSubrange(endIndex..<endIndex, with: elements)
        }
    }

    /// Prepends an element to the beginning of the list.
    ///
    /// This method adds a new element to the beginning of the list,
    /// making it the new first element.
    ///
    /// ```swift
    /// var list = LinkedList<Int>()
    /// list.append(2)
    /// list.prepend(1)
    /// // list now contains [1, 2]
    /// ```
    ///
    /// - Parameter element: The element to prepend to the list.
    /// - Complexity: O(1)
    public mutating func prepend(_ element: Element) {
        ensureUnique()

        let newNode = Node(value: element)
        if let head = head {
            head.previous = newNode
            newNode.next = head
        } else {
            tail = newNode
        }
        head = newNode
        count += 1
    }

    /// Prepends the elements of a sequence to the beginning of the list.
    ///
    /// - Parameter newElements: The elements to prepend.
    /// - Complexity: O(m) where m is the length of `newElements`.
    public mutating func prepend<S: Sequence>(contentsOf newElements: __owned S)
    where S.Element == Element {
        let elements = Array(newElements)
        if !elements.isEmpty {
            replaceSubrange(startIndex..<startIndex, with: elements)
        }
    }

    /// Inserts an element at the specified position.
    ///
    /// This method inserts a new element at the specified index,
    /// shifting existing elements to accommodate the new element.
    ///
    /// ```swift
    /// var list = LinkedList([1, 3])
    /// list.insert(2, at: 1)
    /// // list now contains [1, 2, 3]
    /// ```
    ///
    /// - Parameters:
    ///   - element: The element to insert.
    ///   - index: The position at which to insert the element.
    /// - Complexity: O(n) where n is the number of elements in the list.
    /// - Precondition: `index >= 0 && index <= count`
    public mutating func insert(_ element: Element, at position: Int) {
        precondition(position >= 0 && position <= count, "Index out of bounds")
        let index = self.index(startIndex, offsetBy: position)
        insert(element, at: index)
    }

    public mutating func insert<C>(contentsOf newElements: __owned C, at position: Int)
    where C: Collection, C.Element == Element {
        precondition(position >= 0 && position <= count, "Index out of bounds")
        let index = self.index(startIndex, offsetBy: position)
        insert(contentsOf: newElements, at: index)
    }

    /// Removes and returns the element at the specified position.
    ///
    /// This method removes the element at the specified index
    /// and returns it, adjusting the list structure accordingly.
    ///
    /// ```swift
    /// var list = LinkedList([1, 2, 3])
    /// let removed = list.remove(at: 1)  // Returns 2
    /// // list now contains [1, 3]
    /// ```
    ///
    /// - Parameter index: The position of the element to remove.
    /// - Returns: The removed element.
    /// - Complexity: O(n) where n is the number of elements in the list.
    /// - Precondition: `index >= 0 && index < count`
    @discardableResult
    public mutating func remove(at position: Int) -> Element {
        precondition(position >= 0 && position < count, "Index out of bounds")
        let index = self.index(startIndex, offsetBy: position)
        return remove(at: index)
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        precondition(bounds.lowerBound >= 0, "Lower bound cannot be negative.")
        precondition(bounds.upperBound <= count, "Upper bound is out of bounds.")
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        removeSubrange(start..<end)
    }

    /// Removes and returns the first element in the list.
    ///
    /// This method removes the first element and returns it,
    /// making the second element (if any) the new first element.
    ///
    /// ```swift
    /// var list = LinkedList([1, 2, 3])
    /// let first = list.removeFirst()  // Returns 1
    /// // list now contains [2, 3]
    /// ```
    ///
    /// - Returns: The first element in the list.
    /// - Complexity: O(1)
    /// - Precondition: The list must not be empty.
    @discardableResult
    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "Cannot remove from an empty list")

        ensureUnique()

        let value = head!.value
        head = head?.next
        head?.previous = nil

        if head == nil {
            tail = nil
        }

        count -= 1
        return value
    }

    /// Removes and returns the last element in the list.
    ///
    /// This method removes the last element and returns it,
    /// making the second-to-last element (if any) the new last element.
    ///
    /// ```swift
    /// var list = LinkedList([1, 2, 3])
    /// let last = list.removeLast()  // Returns 3
    /// // list now contains [1, 2]
    /// ```
    ///
    /// - Returns: The last element in the list.
    /// - Complexity: O(1)
    /// - Precondition: The list must not be empty.
    @discardableResult
    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "Cannot remove from an empty list")

        ensureUnique()

        let value = tail!.value
        tail = tail?.previous
        tail?.next = nil

        if tail == nil {
            head = nil
        }

        count -= 1
        return value
    }

    /// Removes and returns the first element of the collection.
    ///
    /// - Returns: The first element of the collection if the collection
    ///   is not empty; otherwise, `nil`.
    /// - Complexity: O(1)
    @discardableResult
    public mutating func popFirst() -> Element? {
        if isEmpty { return nil }
        return removeFirst()
    }

    /// Removes and returns the last element of the collection.
    ///
    /// - Returns: The last element of the collection if the collection
    ///   is not empty; otherwise, `nil`.
    /// - Complexity: O(1)
    @discardableResult
    public mutating func popLast() -> Element? {
        if isEmpty { return nil }
        return removeLast()
    }

    /// Removes all elements from the list.
    ///
    /// This method removes all elements, leaving the list empty.
    ///
    /// ```swift
    /// var list = LinkedList([1, 2, 3])
    /// list.removeAll()
    /// // list is now empty
    /// ```
    ///
    /// - Complexity: O(1)
    public mutating func removeAll() {
        head = nil
        tail = nil
        count = 0
    }

    /// Accesses the element at the specified position.
    ///
    /// - Parameter index: A valid index of the collection.
    /// - Returns: The element at the specified position.
    /// - Complexity: O(1) for adjacent access, O(n) for random access.
    /// - Precondition: `index` must be a valid index.
    public subscript(_ index: Index) -> Element {
        get {
            precondition(index.isMember(of: self), "Index is from another list")
            guard let node = index.node else {
                fatalError("Index out of bounds")
            }
            return node.value
        }
        set {
            precondition(index.isMember(of: self), "Index is from another list")
            guard index.node != nil else {
                fatalError("Index out of bounds")
            }
            ensureUnique()
            // After ensureUnique(), we need to find the corresponding node in the new list
            if let newNode = self.node(at: index.position) {
                newNode.value = newValue
            } else {
                fatalError("Index out of bounds after copy-on-write")
            }
        }
    }

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: The integer position of the element to access.
    /// - Returns: The element at the specified position.
    /// - Complexity: O(n)
    /// - Precondition: `position` must be a valid index.
    public subscript(_ position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "Index out of bounds")
            let index = self.index(startIndex, offsetBy: position)
            return self[index]
        }
        set {
            precondition(position >= 0 && position < count, "Index out of bounds")
            let index = self.index(startIndex, offsetBy: position)
            self[index] = newValue
        }
    }

    /// Returns the element at the specified position,
    /// or `nil` if the index is out of bounds.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// let element = list[safe: 1]  // Returns 2
    /// ```
    ///
    /// - Parameter position: The position of the element to retrieve.
    /// - Returns: The element at the specified position, or `nil` if the index is out of bounds.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public subscript(safe position: Int) -> Element? {
        guard position >= 0, position < count else { return nil }
        return node(at: position)?.value
    }

    /// Returns a new list containing the elements in the specified range.
    ///
    /// This method creates a new list containing elements
    /// from the specified range of indices.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3, 4, 5])
    /// let sublist = list[1..<4]
    /// // sublist contains [2, 3, 4]
    /// ```
    ///
    /// - Parameter bounds: The range of indices to include in the new list.
    /// - Returns: A new list containing the elements in the specified range.
    /// - Complexity: O(n) where n is the number of elements in the range.
    /// - Precondition: `bounds.lowerBound >= 0 && bounds.upperBound <= count`
    public subscript(_ bounds: Range<Int>) -> LinkedList<Element> {
        get {
            precondition(bounds.lowerBound >= 0, "Lower bound cannot be negative.")
            precondition(bounds.upperBound <= count, "Upper bound is out of bounds.")
            return sublist(from: bounds.lowerBound, to: bounds.upperBound)
        }
        set {
            precondition(bounds.lowerBound >= 0, "Lower bound cannot be negative.")
            precondition(bounds.upperBound <= count, "Upper bound is out of bounds.")
            let start = index(startIndex, offsetBy: bounds.lowerBound)
            let end = index(startIndex, offsetBy: bounds.upperBound)
            replaceSubrange(start..<end, with: newValue)
        }
    }

    /// Returns a new list containing the elements in the specified range.
    ///
    /// This method creates a new list containing elements
    /// from the specified range of indices.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3, 4, 5])
    /// let sublist = list.sublist(from: 1, to: 4)
    /// // sublist contains [2, 3, 4]
    /// ```
    ///
    /// - Parameters:
    ///   - from: The starting index of the range.
    ///   - to: The ending index of the range (exclusive).
    /// - Returns: A new list containing the elements in the specified range.
    /// - Complexity: O(n) where n is the number of elements in the range.
    /// - Precondition: `from >= 0 && to <= count && from <= to`
    public func sublist(from start: Int, to end: Int) -> LinkedList<Element> {
        precondition(
            start >= 0 && end <= count && start <= end, "Invalid range")

        var result = LinkedList<Element>()
        var current = node(at: start)

        for _ in start..<end {
            if let node = current {
                result.append(node.value)
                current = node.next
            }
        }

        return result
    }

    /// Reverses the order of elements in the list.
    ///
    /// This method modifies the list in place,
    /// reversing the order of all elements.
    ///
    /// ```swift
    /// var list = LinkedList([1, 2, 3])
    /// list.reverse()
    /// // list now contains [3, 2, 1]
    /// ```
    ///
    /// - Complexity: O(n) where n is the number of elements in the list.
    public mutating func reverse() {
        ensureUnique()

        var current = head
        var previous: Node? = nil

        while let node = current {
            let next = node.next
            node.next = previous
            node.previous = next
            previous = node
            current = next
        }

        let temp = head
        head = tail
        tail = temp
    }

    /// Returns a new list with elements in reverse order.
    ///
    /// This method creates a new list with elements
    /// in reverse order without modifying the original list.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// let reversed = list.reversed()
    /// // reversed contains [3, 2, 1]
    /// // list remains [1, 2, 3]
    /// ```
    ///
    /// - Returns: A new list with elements in reverse order.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func reversed() -> LinkedList<Element> {
        var result = LinkedList<Element>()
        var current = tail

        while let node = current {
            result.append(node.value)
            current = node.previous
        }

        return result
    }
}

// MARK: - Sequence

/// Sequence conformance for LinkedList.
///
/// This allows iteration over all elements in the list,
/// enabling the use of `for...in` loops and sequence operations.
extension LinkedList: Sequence {
    public struct Iterator: IteratorProtocol {
        private var current: Node?

        fileprivate init(node: Node?) {
            self.current = node
        }

        public mutating func next() -> Element? {
            guard let node = current else { return nil }
            let value = node.value
            current = node.next
            return value
        }
    }

    /// Creates an iterator for traversing elements in the list.
    ///
    /// The iterator visits elements in order from first to last,
    /// providing predictable traversal order.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// for element in list {
    ///     print(element)
    /// }
    /// ```
    ///
    /// - Returns: An iterator that yields elements in order.
    /// - Complexity: O(1) to create, O(n) total iteration time.
    public func makeIterator() -> Iterator {
        Iterator(node: head)
    }
}

// MARK: - Collection

/// Collection conformance for LinkedList.
///
/// This provides basic collection functionality
/// and enables the use of collection algorithms.
extension LinkedList: BidirectionalCollection, MutableCollection {
    /// A position in the linked list.
    ///
    /// Index values correspond to positions
    /// in the sequence of elements.
    public struct Index: Comparable {
        private weak var listID: ID?
        fileprivate weak var node: Node?
        fileprivate let position: Int

        fileprivate init(listID: ID, node: Node?, position: Int) {
            self.listID = listID
            self.node = node
            self.position = position
        }

        fileprivate func isMember(of list: LinkedList) -> Bool {
            listID === list.id
        }

        public static func < (lhs: Index, rhs: Index) -> Bool {
            lhs.position < rhs.position
        }

        public static func == (lhs: Index, rhs: Index) -> Bool {
            lhs.position == rhs.position
        }
    }

    /// The position of the first element in the collection.
    ///
    /// If the list is empty, `startIndex` equals `endIndex`.
    public var startIndex: Index {
        Index(listID: id, node: head, position: 0)
    }

    /// The position one past the last element in the collection.
    ///
    /// If the list is empty, `endIndex` equals `startIndex`.
    public var endIndex: Index {
        Index(listID: id, node: nil, position: count)
    }

    /// Returns the index after the given index.
    ///
    /// - Parameter i: A valid index of the collection.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Index) -> Index {
        precondition(i.isMember(of: self), "Index is from another list")
        guard let node = i.node else {
            return Index(listID: id, node: nil, position: i.position + 1)
        }
        return Index(listID: id, node: node.next, position: i.position + 1)
    }

    /// Returns the index before the given index.
    ///
    /// - Parameter i: A valid index of the collection.
    /// - Returns: The index value immediately before `i`.
    public func index(before i: Index) -> Index {
        precondition(i.isMember(of: self), "Index is from another list")
        precondition(i.position > 0, "Cannot get index before startIndex")
        if i.position == count {
            return Index(listID: id, node: tail, position: count - 1)
        } else {
            return Index(listID: id, node: i.node?.previous, position: i.position - 1)
        }
    }

    public mutating func swapAt(_ i: Index, _ j: Index) {
        precondition(i.isMember(of: self), "Index i is from another list")
        precondition(j.isMember(of: self), "Index j is from another list")
        guard i != j else { return }

        ensureUnique()

        // After ensureUnique(), we need to find the corresponding node in the new list
        if let nodeI = self.node(at: i.position),
            let nodeJ = self.node(at: j.position)
        {
            let temp = nodeI.value
            nodeI.value = nodeJ.value
            nodeJ.value = temp
        } else {
            fatalError("Index out of bounds after copy-on-write")
        }
    }
}

// MARK: - RangeReplaceableCollection

extension LinkedList: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(
        _ subrange: Range<Index>,
        with newElements: __owned C
    ) where C: Collection, Element == C.Element {
        precondition(
            subrange.lowerBound.isMember(of: self) && subrange.upperBound.isMember(of: self),
            "Range contains indices from another list"
        )

        if subrange.lowerBound == startIndex,
            subrange.upperBound == endIndex,
            let linkedList = newElements as? LinkedList<Element>
        {
            self = linkedList
            return
        }

        let lowerBoundPosition = subrange.lowerBound.position
        let upperBoundPosition = subrange.upperBound.position

        ensureUnique()

        let removedCount = upperBoundPosition - lowerBoundPosition

        var newHead: Node?
        var newTail: Node?
        var newCount = 0
        var iterator = newElements.makeIterator()
        if let first = iterator.next() {
            let node = Node(value: first)
            newHead = node
            newTail = node
            newCount = 1
            while let next = iterator.next() {
                let newNode = Node(value: next)
                newTail!.next = newNode
                newNode.previous = newTail
                newTail = newNode
                newCount += 1
            }
        }

        defer {
            count = count - removedCount + newCount
        }

        let before = node(at: lowerBoundPosition - 1)
        let after = node(at: upperBoundPosition)

        if newHead == nil {  // Deleting
            if let before = before {
                before.next = after
                after?.previous = before
            } else {  // Deleting from the start
                head = after
                after?.previous = nil
            }
            if after == nil {  // Deleting until the end
                tail = before
            }
            return
        }

        // Inserting or replacing
        if let before = before {
            before.next = newHead
            newHead?.previous = before
        } else {  // Inserting at the start
            head = newHead
        }

        newTail?.next = after
        after?.previous = newTail

        if after == nil {  // Inserting at the end
            tail = newTail
        }
    }
}

// MARK: - Functional Operations

/// Functional programming operations for LinkedList.
///
/// These operations provide ways to transform and filter linked lists
/// while preserving the list structure.
extension LinkedList {
    /// Returns a new linked list with transformed elements.
    ///
    /// This method creates a new list with elements transformed
    /// by the provided closure.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// let doubled = list.map { $0 * 2 }
    /// // Result: [2, 4, 6]
    /// ```
    ///
    /// - Parameter transform: A closure that transforms each element.
    /// - Returns: A new linked list with transformed elements.
    /// - Complexity: O(n) where n is the number of elements.
    /// - Throws: Rethrows any error thrown by the transform closure.
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> LinkedList<T> {
        var result = LinkedList<T>()
        for element in self {
            try result.append(transform(element))
        }
        return result
    }

    /// Returns a new linked list with transformed and filtered elements.
    ///
    /// This method creates a new list by applying a transformation
    /// that may return `nil`, effectively filtering out elements
    /// where the transformation returns `nil`.
    ///
    /// ```swift
    /// let list = LinkedList(["1", "2", "abc", "3"])
    /// let numbers = list.compactMap { Int($0) }
    /// // Result: [1, 2, 3]
    /// ```
    ///
    /// - Parameter transform: A closure that transforms each element,
    ///   returning an optional result.
    /// - Returns: A new linked list containing only elements
    ///   where the transform returned a non-nil value.
    /// - Complexity: O(n) where n is the number of elements.
    /// - Throws: Rethrows any error thrown by the transform closure.
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> LinkedList<T> {
        var result = LinkedList<T>()
        for element in self {
            if let transformedElement = try transform(element) {
                result.append(transformedElement)
            }
        }
        return result
    }

    /// Returns a new linked list containing only elements
    /// that satisfy the predicate.
    ///
    /// This method creates a new list by filtering elements
    /// based on the provided predicate.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3, 4, 5])
    /// let evens = list.filter { $0 % 2 == 0 }
    /// // Result: [2, 4]
    /// ```
    ///
    /// - Parameter predicate: A closure that evaluates each element.
    /// - Returns: A new linked list containing only elements
    ///   where the predicate returned `true`.
    /// - Complexity: O(n) where n is the number of elements.
    /// - Throws: Rethrows any error thrown by the predicate closure.
    public func filter(_ predicate: (Element) throws -> Bool) rethrows -> LinkedList<Element> {
        var result = LinkedList<Element>()
        for element in self {
            if try predicate(element) {
                result.append(element)
            }
        }
        return result
    }

    /// Returns the result of combining the elements of the list
    /// using the given closure.
    ///
    /// This method reduces the list to a single value
    /// by applying the closure to each element and an accumulated value.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3, 4])
    /// let sum = list.reduce(0, +)
    /// // Result: 10
    /// ```
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - nextPartialResult: A closure that combines an accumulating value
    ///     and an element of the list into a new accumulating value.
    /// - Returns: The final accumulated value.
    /// - Complexity: O(n) where n is the number of elements.
    /// - Throws: Rethrows any error thrown by the nextPartialResult closure.
    public func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Element) throws -> Result
    ) rethrows -> Result {
        var result = initialResult
        for element in self {
            result = try nextPartialResult(result, element)
        }
        return result
    }
}

// MARK: - CustomStringConvertible

/// String representation conformance for LinkedList.
///
/// Provides a readable string representation
/// showing all elements in the list.
extension LinkedList: CustomStringConvertible {
    /// A textual representation of the linked list.
    ///
    /// The description shows all elements in the list in a compact format,
    /// useful for debugging and logging.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// print(list)  // "LinkedList(1, 2, 3)"
    /// ```
    public var description: String {
        "LinkedList(\(lazy.map { "\($0)" }.joined(separator: ", ")))"
    }
}

// MARK: - ExpressibleByArrayLiteral

/// Array literal support for linked lists.
///
/// This allows creating linked lists using array literal syntax.
extension LinkedList: ExpressibleByArrayLiteral {
    /// Creates a linked list from an array literal.
    ///
    /// This initializer enables convenient creation of linked lists
    /// using array literal syntax.
    ///
    /// ```swift
    /// let list: LinkedList<Int> = [1, 2, 3, 4, 5]
    /// ```
    ///
    /// - Parameter elements: The elements to include in the list.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - Equatable

extension LinkedList: Equatable where Element: Equatable {
    public static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return lhs.elementsEqual(rhs)
    }
}

// MARK: - Hashable

extension LinkedList: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        for element in self {
            hasher.combine(element)
        }
    }
}

// MARK: - Codable

extension LinkedList: Codable where Element: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode([Element].self)
        self.init(elements)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let elements = Array(self)
        try container.encode(elements)
    }
}

// MARK: - Identifiable

/// Convenience methods for linked lists with identifiable elements.
///
/// When Element conforms to Identifiable,
/// these extensions provide additional functionality
/// for working with elements by their unique identifiers.
extension LinkedList where Element: Identifiable {
    /// Returns the first element with the specified ID.
    ///
    /// This method searches through the list to find
    /// the first element whose ID matches the provided identifier.
    ///
    /// ```swift
    /// struct User: Identifiable {
    ///     let id: UUID
    ///     let name: String
    /// }
    ///
    /// let list = LinkedList([User(id: UUID(), name: "Alice"), User(id: UUID(), name: "Bob")])
    /// let user = list.first(where: { $0.id == someUUID })
    /// ```
    ///
    /// - Parameter id: The identifier to search for.
    /// - Returns: The first element with the matching ID, or `nil` if not found.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func first(id: Element.ID) -> Element? {
        for element in self {
            if element.id == id {
                return element
            }
        }
        return nil
    }

    /// Returns all elements with the specified ID.
    ///
    /// This method searches through the list to find
    /// all elements whose ID matches the provided identifier.
    ///
    /// ```swift
    /// let users = list.all(id: someUUID)
    /// ```
    ///
    /// - Parameter id: The identifier to search for.
    /// - Returns: An array of all elements with the matching ID.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func all(id: Element.ID) -> [Element] {
        var results: [Element] = []
        for element in self {
            if element.id == id {
                results.append(element)
            }
        }
        return results
    }

    /// Returns whether the list contains an element with the specified ID.
    ///
    /// This method provides an efficient way to check for the existence
    /// of elements with a specific ID without retrieving them.
    ///
    /// ```swift
    /// let hasUser = list.contains(id: someUUID)
    /// ```
    ///
    /// - Parameter id: The identifier to check for.
    /// - Returns: `true` if at least one element has the given ID, `false` otherwise.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func contains(id: Element.ID) -> Bool {
        return first(id: id) != nil
    }

    /// Removes the first element with the specified ID.
    ///
    /// This method removes the first occurrence of an element
    /// whose ID matches the provided identifier.
    ///
    /// ```swift
    /// let removed = list.removeFirst(id: someUUID)
    /// ```
    ///
    /// - Parameter id: The identifier of the element to remove.
    /// - Returns: The removed element, or `nil` if no element with the ID was found.
    /// - Complexity: O(n) where n is the number of elements in the list.
    @discardableResult
    public mutating func removeFirst(id: Element.ID) -> Element? {
        ensureUnique()

        var current = head
        while let node = current {
            if node.value.id == id {
                let prev = node.previous
                let next = node.next

                if let prev = prev {
                    prev.next = next
                } else {
                    head = next
                }

                if let next = next {
                    next.previous = prev
                } else {
                    tail = prev
                }

                count -= 1
                return node.value
            }
            current = node.next
        }

        return nil
    }

    /// Removes all elements with the specified ID.
    ///
    /// This method removes all occurrences of elements
    /// whose ID matches the provided identifier.
    ///
    /// ```swift
    /// let removed = list.removeAll(id: someUUID)
    /// ```
    ///
    /// - Parameter id: The identifier of the elements to remove.
    /// - Returns: An array of all removed elements.
    /// - Complexity: O(n) where n is the number of elements in the list.
    @discardableResult
    public mutating func removeAll(id: Element.ID) -> [Element] {
        ensureUnique()

        var removed: [Element] = []
        var current = head

        while let node = current {
            let next = node.next
            if node.value.id == id {
                removed.append(node.value)

                let prev = node.previous

                if let prev = prev {
                    prev.next = next
                } else {
                    head = next
                }

                if let next = next {
                    next.previous = prev
                } else {
                    tail = prev
                }

                count -= 1
            }
            current = next
        }

        return removed
    }

    /// Updates the first element with the specified ID.
    ///
    /// This method updates the first occurrence of an element
    /// whose ID matches the provided identifier.
    ///
    /// ```swift
    /// let updated = list.updateFirst(id: someUUID) { user in
    ///     User(id: user.id, name: "Updated Name")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - id: The identifier of the element to update.
    ///   - transform: A closure that transforms the element.
    /// - Returns: `true` if an element was found and updated, `false` otherwise.
    /// - Complexity: O(n) where n is the number of elements in the list.
    /// - Throws: Rethrows any error thrown by the transform closure.
    @discardableResult
    public mutating func updateFirst(id: Element.ID, _ transform: (Element) throws -> Element)
        rethrows -> Bool
    {
        ensureUnique()

        var current = head
        while let node = current {
            if node.value.id == id {
                node.value = try transform(node.value)
                return true
            }
            current = node.next
        }

        return false
    }

    /// Returns a new list containing only elements with the specified IDs.
    ///
    /// This method creates a new list containing only elements
    /// whose IDs are in the provided set of identifiers.
    ///
    /// ```swift
    /// let filtered = list.filtered(by: [id1, id2, id3])
    /// ```
    ///
    /// - Parameter ids: A set of identifiers to filter by.
    /// - Returns: A new list containing only elements with matching IDs.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func filtered(by ids: Set<Element.ID>) -> LinkedList<Element> {
        var result = LinkedList<Element>()
        for element in self {
            if ids.contains(element.id) {
                result.append(element)
            }
        }
        return result
    }

    /// Returns a dictionary mapping element IDs to their corresponding elements.
    ///
    /// This method creates a dictionary where keys are element IDs
    /// and values are the corresponding elements.
    /// If multiple elements have the same ID, only the last one is included.
    ///
    /// ```swift
    /// let dict = list.indexedByID()
    /// ```
    ///
    /// - Returns: A dictionary mapping element IDs to elements.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func indexedByID() -> [Element.ID: Element] {
        var dict: [Element.ID: Element] = [:]
        for element in self {
            dict[element.id] = element
        }
        return dict
    }

    /// Returns a dictionary mapping element IDs to arrays of elements.
    ///
    /// This method creates a dictionary where keys are element IDs
    /// and values are arrays of all elements with that ID.
    ///
    /// ```swift
    /// let dict = list.groupedByID()
    /// ```
    ///
    /// - Returns: A dictionary mapping element IDs to arrays of elements.
    /// - Complexity: O(n) where n is the number of elements in the list.
    public func groupedByID() -> [Element.ID: [Element]] {
        var dict: [Element.ID: [Element]] = [:]
        for element in self {
            dict[element.id, default: []].append(element)
        }
        return dict
    }
}

// MARK: - Sendable

extension LinkedList: Sendable where Element: Sendable {}

// MARK: - CustomDebugStringConvertible

/// Debug string representation conformance for LinkedList.
///
/// Provides detailed debugging information
/// including count and all elements.
extension LinkedList: CustomDebugStringConvertible {
    /// A detailed textual representation for debugging purposes.
    ///
    /// The debug description includes the count of elements
    /// and shows each element, useful for detailed inspection.
    ///
    /// ```swift
    /// let list = LinkedList([1, 2, 3])
    /// print(list.debugDescription)
    /// // LinkedList(count: 3) {
    /// //   1
    /// //   2
    /// //   3
    /// // }
    /// ```
    public var debugDescription: String {
        if isEmpty {
            return "LinkedList(empty)"
        }

        let elements = lazy.map { "\($0)" }.joined(separator: "\n  ")
        return "LinkedList(count: \(count)) {\n  " + elements + "\n}"
    }
}
