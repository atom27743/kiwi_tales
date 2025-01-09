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
    @Published var isParentalGateCompleted = false
    
    static let shared = ParentalGateViewModel()
    
    private init() {
        isParentalGateCompleted = UserDefaults.standard.bool(forKey: "ParentalGateCompleted")
        print("🔒 ParentalGate - Initial State: \(isParentalGateCompleted)")
    }
    
    func requireParentalGate(for action: @escaping () -> Void) {
        print("🔒 ParentalGate - Checking completion state: \(isParentalGateCompleted)")
        if isParentalGateCompleted {
            print("🔒 ParentalGate - Already completed, executing action directly")
            action()
        } else {
            print("🔒 ParentalGate - Not completed, showing gate view")
            self.gateAction = action
            self.showParentalGate = true
        }
    }
    
    func parentalGateSucceeded() {
        print("🔒 ParentalGate - Successfully completed!")
        isParentalGateCompleted = true
        UserDefaults.standard.set(true, forKey: "ParentalGateCompleted")
        if let action = gateAction {
            print("🔒 ParentalGate - Executing stored action")
            action()
        }
        gateAction = nil
    }
}
