//
//  ContentViewExtension.swift
//  DoItAll
//
//  Created by Marc Harvey on 04/05/2026.
//

import SwiftUI

extension ContentView {
    
    @ViewBuilder
    public func sectionCard(for type: ItemType) -> some View {
        let isExpanded = expandedSections.contains(type)
        let theme = themeManager.selectedTheme
        let items = viewModel.groupedItems[type] ?? []

        GroupHeader(
            type: type,
            isExpanded: Binding(
                get: { self.expandedSections.contains(type) },
                set: { isOpen in
                    withAnimation {
                        if isOpen { self.expandedSections.insert(type) }
                        else { self.expandedSections.remove(type) }
                    }
                }
            )
        )
        .padding(.horizontal, 8)
        .background(
            cardGradient(isExpanded: isExpanded, theme: theme)
                .cornerRadius(10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .padding(.horizontal, 10)
        .padding(.top, 10)

        if isExpanded {
            let itemsArray = items
            
            ForEach(itemsArray, id: \.objectID) { item in
                let isLast = item.objectID == itemsArray.last?.objectID
                
                itemRow(item: item, isLast: isLast)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .background(
                        cardGradient(isExpanded: true, theme: themeManager.selectedTheme)
                            // If you don't have a custom corner extension, use a standard clip
                            .cornerRadius(isLast ? 10 : 0)
                    )
                    .padding(.horizontal, 10)
            }
        }
    }
    
    @ViewBuilder
    public func itemRow(item: ItemEntity, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            groupedListRow(for: item)
                .padding(.horizontal, 15)
                .frame(minHeight: 44)
                .background(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            
            if !isLast {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.separator))
                    .padding(.horizontal, 15)
            }
        }
    }
    
    
    public func expansionDivider(theme: BackgroundTheme) -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(
                LinearGradient(
                    colors: [theme.primaryColour.opacity(0.6), theme.secondaryColour.opacity(0.4), theme.primaryColour.opacity(0.6)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .transition(.opacity.combined(with: .scale(scale: 1.0, anchor: .top)))
    }

    public func cardGradient(isExpanded: Bool, theme: BackgroundTheme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.primaryColour.opacity(isExpanded ? 0.15 : 0.1),
                theme.secondaryColour.opacity(isExpanded ? 0.1 : 0.05)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public var scrollTrackingElement: some View {
        Color.clear
            .frame(height: 0)
            .background(
                GeometryReader { geometry in
                    let raw = geometry.frame(in: .named("scroll")).minY
                    let rounded = (raw / 10).rounded() * 10 
                    return Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: rounded
                    )
                }
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    public func hiddenOverlay(for item: ItemEntity) -> some View {
        let theme = themeManager.selectedTheme
        
        HStack {
            HiddenIndicatorView(onLongPress: {
                viewModel.handleLongPress(for: item)
            })
            .frame(height: rowHeight)
            .padding(.trailing, 5)
            
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.secondaryTextColour ?? .secondary)
                Spacer()
            }
            .frame(height: rowHeight)
        }
    }

    @ViewBuilder
    public func hiddenRowBackground(for item: ItemEntity) -> some View {
        GeometryReader { geometry in
            GlassMorphicBackground()
                .frame(width: UIScreen.screenWidth, height: rowHeight)
                .offset(x: -geometry.frame(in: .global).minX)
                .id(item.id)
        }
        .frame(height: rowHeight)
    }
    
    @ViewBuilder
    public func rowVariant(for item: ItemEntity, sortOption: SortOption) -> some View {
        if sortOption == .type {
            typeGroupedRow(for: item)
        } else {
            navigationRow(for: item)
        }
    }

    private func typeGroupedRow(for item: ItemEntity) -> some View {
        Button {
            viewModel.navigationPath.append(
                ItemNavigationDestination(itemID: item.objectID, itemType: item.itemType)
            )
        } label: {
            typeGroupedRowLabel(for: item)
        }
        .buttonStyle(.plain)
    }

    private func typeGroupedRowLabel(for item: ItemEntity) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                rowContent(for: item)
                Spacer()
                    .frame(width: 18)
            }
            .contentShape(.rect)
            .frame(height: rowHeight)
        }
    }

    private func navigationRow(for item: ItemEntity) -> some View {
        NavigationLink(value: ItemNavigationDestination(itemID: item.objectID, itemType: item.itemType)) {
            navigationRowLabel(for: item)
        }
    }

    private func navigationRowLabel(for item: ItemEntity) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                rowContent(for: item)
            }
            .contentShape(.rect)
            .frame(height: rowHeight)

            if item.objectID != viewModel.items.last?.objectID {
                rowSeparator
            }
        }
    }

    private var rowSeparator: some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundStyle(Color(UIColor.separator))
    }

    private func listRowInsets(for sortOption: SortOption) -> EdgeInsets {
        EdgeInsets(
            top: 0,
            leading: 10,
            bottom: 0,
            trailing: sortOption == .type ? -5 : 10
        )
    }
}

//#Preview {
//    ContentViewExtension()
//}
