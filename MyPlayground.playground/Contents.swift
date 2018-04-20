import Foundation

let test = [99, 75, -65, 50, -50, -49, -10, 49, 40, -25, -25, -29, -20, -20, -10, -10]

test.reduce(0, +)


func powerSet<T>(_ set: [T]) -> [[T]] {
    var result: [[T]] = [[]]
    for x in set {
        for r in result {
            var t = r
            t = t + [x]
            result.append(t)
        }
    }
    return result
}

powerSet([1,2,3,4])

func combo<T>(_ elements: [T], _ taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count > 0 && taking > 0 else { return [[]] }
    
    if taking == 1 {
        return elements.map {[$0]}
    }
    
    var combinations = [[T]]()
    for (index, element) in elements.enumerated() {
        var reducedElements = elements
        reducedElements.removeFirst(index + 1)
        combinations += combo(reducedElements, taking - 1).map {[element] + $0}
    }
    
    return combinations
}

combo([1,2,3,4], 2)


