import Foundation
import Testing

@testable import LinkedList

@Test("Empty list initialization")
func testEmptyInitialization() throws {
    let list = LinkedList<Int>()
    #expect(list.isEmpty)
    #expect(list.count == 0)
    #expect(list.first == nil)
    #expect(list.last == nil)
}

@Test("Sequence initialization")
func testSequenceInitialization() throws {
    let array = [1, 2, 3, 4, 5]
    let list = LinkedList(array)

    #expect(list.count == 5)
    #expect(list.first == 1)
    #expect(list.last == 5)
    #expect(Array(list) == array)
}

@Test("Array literal initialization")
func testArrayLiteralInitialization() throws {
    let list: LinkedList<Int> = [1, 2, 3, 4, 5]

    #expect(list.count == 5)
    #expect(list.first == 1)
    #expect(list.last == 5)
}

@Test("Append operations")
func testAppend() throws {
    var list = LinkedList<Int>()

    list.append(1)
    #expect(list.count == 1)
    #expect(list.first == 1)
    #expect(list.last == 1)

    list.append(2)
    #expect(list.count == 2)
    #expect(list.first == 1)
    #expect(list.last == 2)

    list.append(3)
    #expect(list.count == 3)
    #expect(list.first == 1)
    #expect(list.last == 3)
}

@Test("Prepend operations")
func testPrepend() throws {
    var list = LinkedList<Int>()

    list.prepend(3)
    #expect(list.count == 1)
    #expect(list.first == 3)
    #expect(list.last == 3)

    list.prepend(2)
    #expect(list.count == 2)
    #expect(list.first == 2)
    #expect(list.last == 3)

    list.prepend(1)
    #expect(list.count == 3)
    #expect(list.first == 1)
    #expect(list.last == 3)
}

@Test("Insert at index")
func testInsertAtIndex() throws {
    var list = LinkedList([1, 3])

    list.insert(2, at: 1)
    #expect(list.count == 3)
    #expect(Array(list) == [1, 2, 3])

    list.insert(0, at: 0)
    #expect(Array(list) == [0, 1, 2, 3])

    list.insert(4, at: 4)
    #expect(Array(list) == [0, 1, 2, 3, 4])
}

@Test("Remove at index")
func testRemoveAtIndex() throws {
    var list = LinkedList([1, 2, 3, 4, 5])

    let removed = list.remove(at: 2)
    #expect(removed == 3)
    #expect(list.count == 4)
    #expect(Array(list) == [1, 2, 4, 5])

    let first = list.remove(at: 0)
    #expect(first == 1)
    #expect(Array(list) == [2, 4, 5])

    let last = list.remove(at: 2)
    #expect(last == 5)
    #expect(Array(list) == [2, 4])
}

@Test("Remove first and last")
func testRemoveFirstAndLast() throws {
    var list = LinkedList([1, 2, 3])

    let first = list.removeFirst()
    #expect(first == 1)
    #expect(list.count == 2)
    #expect(Array(list) == [2, 3])

    let last = list.removeLast()
    #expect(last == 3)
    #expect(list.count == 1)
    #expect(Array(list) == [2])

    let remaining = list.removeFirst()
    #expect(remaining == 2)
    #expect(list.isEmpty)
}

@Test("Remove all")
func testRemoveAll() throws {
    var list = LinkedList([1, 2, 3, 4, 5])

    list.removeAll()
    #expect(list.isEmpty)
    #expect(list.count == 0)
    #expect(list.first == nil)
    #expect(list.last == nil)
}

@Test("Element access")
func testElementAccess() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    #expect(list[safe: 0] == 1)
    #expect(list[safe: 2] == 3)
    #expect(list[safe: 4] == 5)
    #expect(list[safe: 5] == nil)
    #expect(list[safe: -1] == nil)
}

@Test("Update element")
func testUpdateElement() throws {
    var list = LinkedList([1, 2, 3, 4, 5])

    list[2] = 10
    #expect(list[safe: 2] == 10)
    #expect(Array(list) == [1, 2, 10, 4, 5])
}

@Test("Sublist operations")
func testSublist() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    let sublist = list[1..<4]
    #expect(sublist.count == 3)
    #expect(Array(sublist) == [2, 3, 4])
}

@Test("Reverse operations")
func testReverse() throws {
    var list = LinkedList([1, 2, 3, 4, 5])

    // Test the reversed() method first (non-mutating)
    let reversed = list.reversed()
    #expect(Array(reversed) == [5, 4, 3, 2, 1])
    #expect(Array(list) == [1, 2, 3, 4, 5])  // Original unchanged

    // Test the reverse() method (mutating)
    #expect(list.count == 5)
    list.reverse()
    #expect(list.count == 5)
    #expect(Array(list) == [5, 4, 3, 2, 1])
}

@Test("Sequence operations")
func testSequenceOperations() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    // Test iteration
    var elements: [Int] = []
    for element in list {
        elements.append(element)
    }
    #expect(elements == [1, 2, 3, 4, 5])

    // Test contains
    #expect(list.contains(3))
    #expect(!list.contains(10))
}

@Test("Collection operations")
func testCollectionOperations() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    #expect(list[list.startIndex] == 1)

    let secondIndex = list.index(after: list.startIndex)
    #expect(list[secondIndex] == 2)

    let thirdIndex = list.index(after: secondIndex)
    #expect(list[thirdIndex] == 3)
}

@Test("BidirectionalCollection operations")
func testBidirectionalCollectionOperations() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    let lastIndex = list.index(before: list.endIndex)
    #expect(list[lastIndex] == 5)

    let fourthIndex = list.index(before: lastIndex)
    #expect(list[fourthIndex] == 4)

    var currentIndex = list.endIndex
    var reversedElements: [Int] = []
    while currentIndex != list.startIndex {
        currentIndex = list.index(before: currentIndex)
        reversedElements.append(list[currentIndex])
    }
    #expect(reversedElements == [5, 4, 3, 2, 1])
}

@Test("Safe subscript access")
func testSafeSubscript() throws {
    let list = LinkedList([10, 20, 30])
    #expect(list[safe: 0] == 10)
    #expect(list[safe: 1] == 20)
    #expect(list[safe: 2] == 30)
    #expect(list[safe: 3] == nil)
    #expect(list[safe: -1] == nil)

    let emptyList = LinkedList<Int>()
    #expect(emptyList[safe: 0] == nil)
}

@Test("Functional operations")
func testFunctionalOperations() throws {
    let list = LinkedList([1, 2, 3, 4, 5])

    // Test map
    let doubled = list.map { $0 * 2 }
    #expect(Array(doubled) == [2, 4, 6, 8, 10])

    // Test filter
    let evens = list.filter { $0 % 2 == 0 }
    #expect(Array(evens) == [2, 4])

    // Test compactMap
    let strings = LinkedList(["1", "2", "abc", "3"])
    let numbers = strings.compactMap { Int($0) }
    #expect(Array(numbers) == [1, 2, 3])

    // Test reduce
    let sum = list.reduce(0, +)
    #expect(sum == 15)
}

@Test("Equatable conformance")
func testEquatable() throws {
    let list1 = LinkedList([1, 2, 3])
    let list2 = LinkedList([1, 2, 3])
    let list3 = LinkedList([1, 2, 4])

    #expect(list1 == list2)
    #expect(list1 != list3)
    #expect(list1 != LinkedList<Int>())
}

@Test("Hashable conformance")
func testHashable() throws {
    let list1 = LinkedList([1, 2, 3])
    let list2 = LinkedList([1, 2, 3])
    let list3 = LinkedList([1, 2, 4])

    let set = Set([list1, list2, list3])
    #expect(set.count == 2)  // list1 and list2 should hash to same value
}

@Test("Codable conformance")
func testCodable() throws {
    let original = LinkedList([1, 2, 3, 4, 5])

    let encoder = JSONEncoder()
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(LinkedList<Int>.self, from: data)

    #expect(original == decoded)
}

@Test("String representations")
func testStringRepresentations() throws {
    let list = LinkedList([1, 2, 3])

    #expect(list.description == "LinkedList(1, 2, 3)")
    #expect(list.debugDescription.contains("LinkedList(count: 3)"))
    #expect(list.debugDescription.contains("1"))
    #expect(list.debugDescription.contains("2"))
    #expect(list.debugDescription.contains("3"))
}

@Test("Copy-on-write semantics")
func testCopyOnWrite() throws {
    var list1 = LinkedList([1, 2, 3])
    var list2 = list1

    // Modify list2, should not affect list1
    list2.append(4)
    #expect(list1.count == 3)
    #expect(list2.count == 4)
    #expect(Array(list1) == [1, 2, 3])
    #expect(Array(list2) == [1, 2, 3, 4])

    // Modify list1, should not affect list2
    list1.prepend(0)
    #expect(list1.count == 4)
    #expect(list2.count == 4)
    #expect(Array(list1) == [0, 1, 2, 3])
    #expect(Array(list2) == [1, 2, 3, 4])
}

@Test("Edge cases")
func testEdgeCases() throws {
    var list = LinkedList<Int>()

    // Test operations on empty list
    #expect(list.isEmpty)
    #expect(list.count == 0)

    // Test single element operations
    list.append(1)
    #expect(list.first == 1)
    #expect(list.last == 1)
    #expect(list.count == 1)

    let removed = list.removeFirst()
    #expect(removed == 1)
    #expect(list.isEmpty)
}

@Test("Performance characteristics")
func testPerformance() throws {
    var list = LinkedList<Int>()

    // Test O(1) operations
    for i in 1...1000 {
        list.append(i)
    }
    #expect(list.count == 1000)

    // Test O(1) removal
    for _ in 1...500 {
        _ = list.removeFirst()
    }
    #expect(list.count == 500)

    // Test O(1) prepend
    for i in (1...100).reversed() {
        list.prepend(i)
    }
    #expect(list.count == 600)
}

@Test("Identifiable operations")
func testIdentifiableOperations() throws {
    // Skip this test if Identifiable is not available
    guard #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) else {
        return
    }

    struct TestItem: Identifiable, Equatable {
        let id: UUID
        let value: String
    }

    let id1 = UUID()
    let id2 = UUID()
    let id3 = UUID()

    var list = LinkedList<TestItem>()
    list.append(TestItem(id: id1, value: "First"))
    list.append(TestItem(id: id2, value: "Second"))
    list.append(TestItem(id: id1, value: "Duplicate"))
    list.append(TestItem(id: id2, value: "Another Second"))

    // Test first(id:)
    let first = list.first(id: id1)
    #expect(first?.value == "First")

    // Test all(id:)
    let all = list.all(id: id1)
    #expect(all.count == 2)
    #expect(all[0].value == "First")
    #expect(all[1].value == "Duplicate")

    let all2 = list.all(id: id2)
    #expect(all2.count == 2)
    #expect(all2[0].value == "Second")
    #expect(all2[1].value == "Another Second")

    // Test contains(id:)
    #expect(list.contains(id: id1))
    #expect(list.contains(id: id2))
    #expect(!list.contains(id: id3))

    // Test removeFirst(id:)
    let removed = list.removeFirst(id: id1)
    #expect(removed?.value == "First")
    #expect(list.count == 3)

    // Test removeAll(id:)
    let removedAll = list.removeAll(id: id2)
    #expect(removedAll.count == 2)
    #expect(removedAll.map(\.value) == ["Second", "Another Second"])
    #expect(list.count == 1)
    #expect(list.first?.value == "Duplicate")

    // Test updateFirst(id:)
    let updated = list.updateFirst(id: id1) { item in
        TestItem(id: item.id, value: "Updated")
    }
    #expect(updated)
    #expect(list.first(id: id1)?.value == "Updated")

    // Test filtered(by:)
    let filtered = list.filtered(by: Set([id1, id2]))
    #expect(filtered.count == 1)

    // Test indexedByID()
    let dict = list.indexedByID()
    #expect(dict.count == 1)
    #expect(dict[id1]?.value == "Updated")

    // Test groupedByID()
    let grouped = list.groupedByID()
    #expect(grouped.count == 1)
    #expect(grouped[id1]?.count == 1)
}

@Test("RangeReplaceableCollection operations")
func testRangeReplaceableCollection() throws {
    var list = LinkedList([1, 2, 3])

    // Test popFirst()
    #expect(list.popFirst() == 1)
    #expect(Array(list) == [2, 3])

    // Test popLast()
    #expect(list.popLast() == 3)
    #expect(Array(list) == [2])

    list.append(3)
    list.append(4)

    // Test removeSubrange
    list.removeSubrange(1..<2)
    #expect(Array(list) == [2, 4])

    // Test insert(contentsOf:at:)
    list.insert(contentsOf: [5, 6], at: 1)
    #expect(Array(list) == [2, 5, 6, 4])
}

@Test("Subscript setters")
func testSubscriptSetters() throws {
    var list = LinkedList([1, 2, 3, 4, 5])

    // Test Int-based subscript setter
    list[2] = 10
    #expect(Array(list) == [1, 2, 10, 4, 5])

    // Test Range<Int>-based subscript setter
    list[1..<3] = [8, 9]
    #expect(Array(list) == [1, 8, 9, 4, 5])
}

@Test("Optimized LinkedList initialization")
func testLinkedListInitialization() throws {
    let originalList = LinkedList([1, 2, 3])
    let newList = LinkedList(originalList)

    #expect(newList.count == 3)
    #expect(Array(newList) == [1, 2, 3])
    #expect(newList == originalList)
}

@Test("Append contents of sequence")
func testAppendContentsOf() {
    var list = LinkedList([1, 2])
    list.append(contentsOf: [3, 4, 5])
    #expect(Array(list) == [1, 2, 3, 4, 5])
    #expect(list.count == 5)

    var emptyList = LinkedList<Int>()
    emptyList.append(contentsOf: [1, 2, 3])
    #expect(Array(emptyList) == [1, 2, 3])
    #expect(emptyList.count == 3)
}

@Test("Prepend contents of sequence")
func testPrependContentsOf() {
    var list = LinkedList([4, 5])
    list.prepend(contentsOf: [1, 2, 3])
    #expect(Array(list) == [1, 2, 3, 4, 5])
    #expect(list.count == 5)

    var emptyList = LinkedList<Int>()
    emptyList.prepend(contentsOf: [1, 2, 3])
    #expect(Array(emptyList) == [1, 2, 3])
    #expect(emptyList.count == 3)
}

@Test("MutableCollection swapAt")
func testSwapAt() {
    var list = LinkedList([1, 2, 3, 4, 5])

    // --- First swap ---
    let firstIndex = list.startIndex
    let thirdIndex = list.index(list.startIndex, offsetBy: 2)
    list.swapAt(firstIndex, thirdIndex)
    #expect(Array(list) == [3, 2, 1, 4, 5])

    // --- Second swap ---
    // Indices must be re-calculated after mutation.
    let secondIndexAfterFirstSwap = list.index(after: list.startIndex)
    let lastIndexAfterFirstSwap = list.index(before: list.endIndex)
    list.swapAt(secondIndexAfterFirstSwap, lastIndexAfterFirstSwap)
    #expect(Array(list) == [3, 5, 1, 4, 2])

    // --- Third swap (same index) ---
    // Re-calculate index again.
    let firstIndexAfterSecondSwap = list.startIndex
    list.swapAt(firstIndexAfterSecondSwap, firstIndexAfterSecondSwap)
    #expect(Array(list) == [3, 5, 1, 4, 2])
}
