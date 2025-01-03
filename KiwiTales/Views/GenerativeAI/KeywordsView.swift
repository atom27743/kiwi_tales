//
//  KeywordsView.swift
//  KiWi
//
//  Created by Takumi Otsuka on 9/6/24.
//


import SwiftUI

struct KeywordsView: View {
    @ObservedObject var viewModel: GenerateStoryViewModel
    @State private var keyboardOffset: CGFloat = 0
    @FocusState private var focusedField: Field?
    
    enum Field {
        case first, second, third
    }
    
    var body: some View {
        VStack(spacing: 34) {
            TextField("e.g. Princess", text: Binding(
                get: { viewModel.keywords[safe: 0] ?? "" },
                set: { viewModel.keywords[safe: 0] = $0 }
            ))
            .textFieldStyle(SoftInnerShadowTextFieldStyle())
            .focused($focusedField, equals: .first)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .second
            }
            
            TextField("e.g. Stinky", text: Binding(
                get: { viewModel.keywords[safe: 1] ?? "" },
                set: { viewModel.keywords[safe: 1] = $0 }
            ))
            .textFieldStyle(SoftInnerShadowTextFieldStyle())
            .focused($focusedField, equals: .second)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .third
            }
            
            TextField("e.g. Flower", text: Binding(
                get: { viewModel.keywords[safe: 2] ?? "" },
                set: { viewModel.keywords[safe: 2] = $0 }
            ))
            .textFieldStyle(SoftInnerShadowTextFieldStyle())
            .focused($focusedField, equals: .third)
            .submitLabel(.done)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 44)
        .padding(.bottom, keyboardOffset)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    // Only move up when the last TextField is focused
                    if focusedField == .third {
                        withAnimation {
                            keyboardOffset = keyboardFrame.height + 34
                        }
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    keyboardOffset = 0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set(newValue) {
            if indices.contains(index) {
                self[index] = newValue!
            } else if let newValue = newValue {
                self.append(newValue)
            }
        }
    }
}

struct SoftInnerShadowTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
                    .softInnerShadow()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 2)
                    )
            )
            .softInnerShadow()
            .padding(4)
            .foregroundStyle(colorScheme == .dark ? Color.black : Color.gray)
            .font(.system(size: 18, weight: .regular))
    }
}
