import Foundation

enum MathOperation: CaseIterable {
    case addition, subtraction, multiplication, division, modulus
    
    func apply(_ lhs: Int, _ rhs: Int) -> Int {
        switch self {
        case .addition: return lhs + rhs
        case .subtraction: return lhs - rhs
        case .multiplication: return lhs * rhs
        case .division: return lhs / rhs
        case .modulus: return lhs % rhs
        }
    }
    
    func symbol() -> String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        case .modulus: return "%"
        }
    }
}

class ParentalGateViewModel: ObservableObject {
    @Published var showParentalGate = false
    @Published var gateAction: (() -> Void)?
    
    static let shared = ParentalGateViewModel()
    
    private init() {}
    
    func requireParentalGate(for action: @escaping () -> Void) {
        self.gateAction = action
        self.showParentalGate = true
    }
    
    func parentalGateSucceeded() {
        if let action = gateAction {
            action()
        }
        gateAction = nil
    }
}
