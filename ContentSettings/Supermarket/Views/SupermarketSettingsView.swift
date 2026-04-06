//
//  SupermarketSettingsView.swift
//  DoItAll
//
//  Created by Marc Harvey on 31/03/2026.
//

import SwiftUI

struct SupermarketSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SupermarketSettingsViewModel()
    
    var body: some View {
        List {
            favouriteSupermarketSection
            geofenceSettingsSection
            notificationsSection
        }
        .navigationTitle("Supermarket Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showSupermarketsMap) {
            SupermarketsMapView()
        }
        .sheet(isPresented: $viewModel.showRadiusPicker) {
            radiusPickerSheet
        }
        .sheet(isPresented: $viewModel.showPausePicker) {
            pausePickerSheet
        }
    }
    
    @ViewBuilder
    var favouriteSupermarketSection: some View {
        Section {
            if let favourite = viewModel.favouriteSupermarket {
                favouriteSupermarketContent(favourite)
            } else {
                noFavouriteContent
            }
        } header: {
            Text("Favourite Supermarket")
        }
    }
    
    @ViewBuilder
    var geofenceSettingsSection: some View {
        Section {
            Button(action: {
                viewModel.showRadiusPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notification Radius")
                            .font(.body)
                            .foregroundStyle(viewModel.primaryTextColour)
                        Text("\(Int(viewModel.geofenceRadius)) metres")
                            .font(.caption)
                            .foregroundStyle(viewModel.secondaryTextColor)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Geofence Settings")
        } footer: {
            Text("You'll recieve a notification when you come within this distance of your favourite supermarket")
        }
    }
    
    @ViewBuilder
    var notificationsSection: some View {
        Section {
            if viewModel.isPaused {
                pausedNotificationsContent
            } else {
                pauseNotificationButton
            }
        } header: {
            Text("Notifications")
        } footer: {
            if !viewModel.isPaused {
                Text("Pause notfications for a set period of time")
            }
        }
    }
    
    @ViewBuilder
    func favouriteSupermarketContent(_ favourite: Supermarket) -> some View {
        HStack(spacing: 16) {
            supermarketIcon
            
            VStack(alignment: .center, spacing: 4) {
                Text(favourite.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.primaryTextColour)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        
        removeFavouriteButton
        changeFavouriteButton
    }
    
    @ViewBuilder
    var noFavouriteContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 50)) /// Todo adjust later on
                .foregroundStyle(viewModel.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("No favourite set")
                .font(.headline)
                .foregroundStyle(viewModel.primaryTextColour)
            
            Text("Set a favourite supermarket to recieve notifications when you're ready")
                .font(.caption)
                .foregroundStyle(viewModel.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            setFavouriteButton
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20) /// Adjust this later on too
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    var pausedNotificationsContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .foregroundStyle(.orange)
                Text("Notifications Paused")
                    .font(.body)
                Spacer()
            }
            
            if let pauseDate = viewModel.pausedUntilDate {
                Text("Until \(pauseDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(viewModel.secondaryTextColor)
            }
            
            Button(action: {
                viewModel.resumeNotifications()
            }) {
                Text("Resume notifications")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(viewModel.primaryTextColour)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
     .padding(.vertical, 4)
    }
}

extension SupermarketSettingsView {
    @ViewBuilder
    var supermarketIcon: some View {
        ZStack{
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
                .frame(width: 60, height: 60)
            
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
    
    
    @ViewBuilder
    var removeFavouriteButton: some View {
        Button(role: .destructive) {
            viewModel.removeFavourite()
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Remove favourite")
                    .font(.system(size: 15, weight: .regular))
            }
        }
    }
    
    @ViewBuilder
    var changeFavouriteButton: some View {
        Button(role: .destructive) {
            viewModel.showSupermarketsMap = true
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Change favourite")
                    .font(.system(size: 15, weight: .regular))
            }
        }
    }
    
    @ViewBuilder
    var setFavouriteButton: some View {
        Button(role: .destructive) {
            viewModel.showSupermarketsMap = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Set Favourite Supermarket")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.green, .green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing)
            )
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    var pauseNotificationButton: some View {
        Button(role: .destructive) {
            viewModel.showPausePicker = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pause Notifications")
                        .font(.body)
                        .foregroundStyle(viewModel.primaryTextColour)
                    Text("Temporarily disable Notifications")
                        .font(.caption)
                        .foregroundStyle(viewModel.secondaryTextColor)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    var radiusPickerSheet: some View {
        RadiusPickerView(
            selectedRadius: Binding(
                get: { viewModel.geofenceRadius },
                set: { viewModel.updateRadius($0) }
            ),
            radiusOptions: viewModel.radiusOptions
        )
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
    
    var pausePickerSheet: some View {
        PausePickerView(
            onSelectDuration: { duration in
                viewModel.pauseNotifications(for: duration)
            }
        )
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
    
}

#Preview {
    SupermarketSettingsView()
}
