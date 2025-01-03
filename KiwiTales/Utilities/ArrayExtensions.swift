import Foundation

extension Array {
    /// Safely access array elements with bounds checking
    /// - Parameter index: The index to access
    /// - Returns: The element at the specified index if it exists, nil otherwise
    func safeElement(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
} 