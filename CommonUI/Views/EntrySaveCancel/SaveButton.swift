//
//  SaveButton.swift
//  DoItAll
//
//  Created by Marc Harvey on 29/04/2026.
//

import SwiftUI
import CoreData

protocol CoreDataSaveable: ObservableObject {
    func save(context: NSManagedObjectContext, completion: @escaping () -> Void)
}

struct SaveButton<ViewModel: CoreDataSaveable>: View {
    let viewModel: ViewModel
    let context: NSManagedObjectContext
    var onSave: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button {
            viewModel.save(context: context) {
                DispatchQueue.main.async {
                    onSave?()
                    dismiss()
                }
            }
        } label: {
            Text("Save")
                .font(.footnote)
                .foregroundStyle(themeManager.selectedTheme.primaryColour)
        }
    }
}

//
//#Preview {
//    SaveButton(viewModel: <#ViewModel#>, context: <#NSManagedObjectContext#>)
//}
