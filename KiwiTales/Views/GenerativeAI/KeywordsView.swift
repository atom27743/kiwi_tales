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
    
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    enum Field {
        case first, second, third
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 50 : 34) {
            keywordTextField(placeholder: "e.g. Princess",
                           index: 0,
                           field: .first,
                           nextField: .second)
            
            keywordTextField(placeholder: "e.g. Stinky",
                           index: 1,
                           field: .second,
                           nextField: .third)
            
            keywordTextField(placeholder: "e.g. Flower",
                           index: 2,
                           field: .third,
                           nextField: nil)
            
            Spacer()
        }
        .padding(.horizontal, isIPad ? 100 : 16)
        .padding(.top, isIPad ? 60 : 44)
        .padding(.bottom, keyboardOffset)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    if focusedField == .third {
                        withAnimation {
                            keyboardOffset = keyboardFrame.height + (isIPad ? 50 : 34)
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
    
    private func keywordTextField(placeholder: String, index: Int, field: Field, nextField: Field?) -> some View {
        TextField(placeholder, text: Binding(
            get: { viewModel.keywords[safe: index] ?? "" },
            set: { viewModel.keywords[safe: index] = $0 }
        ))
        .textFieldStyle(SoftInnerShadowTextFieldStyle())
        .focused($focusedField, equals: field)
        .submitLabel(nextField != nil ? .next : .done)
        .font(.system(size: isIPad ? 24 : 17))
        .frame(maxWidth: isIPad ? 600 : .infinity)
        .onSubmit {
            if let next = nextField {
                focusedField = next
            }
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
