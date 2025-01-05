import SwiftUI

struct ParentalGateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var operation: MathOperation = .addition
    @State private var correctAnswer = 0
    @State private var answer = ""
    @State private var showError = false
    let onSuccess: () -> Void
    
    init(onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
        generateQuestion()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Parental Gate")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Sign in requires parental permission.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Divider()
                .background(Color.gray)
                .frame(height: 1)
                .padding(.horizontal)
            
            Text("Please solve the problem to proceed:")
                .padding(.top, 40)
            
            Text("\(num1) \(operation.symbol()) \(num2) = ?")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Enter answer", text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.horizontal)
                .padding(.bottom, 10)
                        
            if showError {
                Text("Incorrect answer. Try again.")
                    .foregroundColor(.red)
            }
            
            Button(action: verifyAnswer) {
                Text("Submit")
                    .padding(4)
                    .padding(.horizontal)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 24)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .onAppear {
            generateQuestion() // Ensure the first question is generated
        }
    }
    
    private func generateQuestion() {
        num1 = Int.random(in: 11...50)
        num2 = Int.random(in: 1...10) // Avoid division by zero
        operation = MathOperation.allCases.randomElement()!
        correctAnswer = operation.apply(num1, num2)
    }
    
    private func verifyAnswer() {
        guard let userAnswer = Int(answer) else {
            showError = true
            return
        }
        
        if userAnswer == correctAnswer {
            dismiss()
            onSuccess()
        } else {
            showError = true
            answer = ""
            generateQuestion() // Generate a new question if the answer is wrong
        }
    }
}

#Preview {
    ParentalGateView(onSuccess: {})
}
