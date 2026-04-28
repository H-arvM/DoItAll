//
//  SystemBackgroundModifier.swift
//  DoItAll
//
//  Created by Marc Harvey on 28/04/2026.
//

import Foundation
import SwiftUI

extension Color {
    static var systemBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor.systemBackground
        })
    }
}
