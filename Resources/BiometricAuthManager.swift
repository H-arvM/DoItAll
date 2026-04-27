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

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Biometrics not available/allowed — go straight to passcode
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
                        case .userFallback, .authenticationFailed, .biometryLockout:
                            // Any of these — fall back to passcode
                            self.authenticateWithPasscode(reason: reason, completion: completion)
                        default:
                            self.authenticateWithPasscode(reason: reason, completion: completion)
                        }
                    } else {
                        // Unknown error — still try passcode
                        self.authenticateWithPasscode(reason: reason, completion: completion)
                    }
                }
            }
        }
    }

    private func authenticateWithPasscode(reason: String, completion: @escaping (Result<Void, BiometricError>) -> Void) {
        let context = LAContext()

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
                        case .authenticationFailed:
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
