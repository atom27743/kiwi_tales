//
//  Configurations.swift
//  KiWiTales
//
//  Created by Takumi Otsuka on 9/22/24.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        
        switch object {
            case let value as T:
                return value
            case let string as String:
                guard let value = T(string) else { fallthrough }
                return value
            default:
                throw Error.invalidValue
        }
    }
}

enum Tokens {
    static var huggingface: String {
        return try! Configuration.value(for: .init("ATOM_HUGGINGFACE_TOKEN"))
    }
    
    static var atom: String {
        return try! Configuration.value(for: .init("ATOM_ID"))
    }
    
    static var personal: String {
        return try! Configuration.value(for: .init("PERSONAL_HUGGINGFACE_TOKEN"))
    }
}
