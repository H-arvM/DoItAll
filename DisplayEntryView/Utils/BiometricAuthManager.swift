//
//  BiometricAuthManager.swift
//  DoItAll
//
//  Created by Marc Harvey on 05/03/2026.
//

import Foundation
import LocalAuthentication
import Combine

class BiometricAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    enum BiometricError: LocalizedError {
        case authenticationFailed
        case userCancel
        case userFallback
        case biometricNotAvailable
        case biometricNotEnrolled
        case other(Error)
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed:
                return "Authentication failed. Please try again"
            case .userCancel:
                return "Authentication was cancelled"
            case .userFallback:
                return "Fallback authentication method selected"
            case .biometricNotAvailable:
                return "Biometric authentication is not available on this device"
            case .biometricNotEnrolled:
                return "No biometric authentication is enrolled. Please set up FaceID or TouchID"
            case .other(let error):
                return error.localizedDescription
            }
        }
    }
    
    func authenticateUser(reason: String, completion: @escaping (Result<Void, BiometricError>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        /// Try biometic auth first
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authenticateWithPasscode(reason: reason, completion: completion)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(.success(()))
                } else {
                    if let error = error as? LAError {
                        switch error.code {
                        case .userCancel, .appCancel, .systemCancel:
                            completion(.failure(.userCancel))
                        case .userFallback:
                            self.authenticateUser(reason: reason, completion: completion)
                        case .authenticationFailed:
                            self.authenticateWithPasscode(reason: reason, completion: completion)
                        default:
                            completion(.failure(.other(error)))
                        }
                    } else if let error = error {
                        completion(.failure(.other(error)))
                    }
                }
            }
        }
    }
    
    private func authenticateWithPasscode(reason: String, completion: @escaping (Result<Void, BiometricError>) -> Void ) {
        let context = LAContext()
        var error: NSError?
        
        /// Check if device passcode is available
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error as NSError? {
                completion(.failure(.other(error)))
            }
            return
        }
        
        /// Perform authentication with passcode
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(.success(()))
                } else {
                    if let error = error as? LAError {
                        switch error.code {
                        case .userCancel, .appCancel, .systemCancel:
                            completion(.failure(.userCancel))
                        case.authenticationFailed:
                            completion(.failure(.authenticationFailed))
                        default:
                            completion(.failure(.other(error)))
                        }
                    } else if let error = error {
                        completion(.failure(.other(error)))
                    }
                }
            }
        }
    }
    
    func resetAuthentication() {
        isAuthenticated = false
    }
}
