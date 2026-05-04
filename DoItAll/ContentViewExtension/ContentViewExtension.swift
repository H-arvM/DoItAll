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
        
        VStack(spacing: 0) {
            GroupHeader(
                type: type,
                isExpanded: Binding(
                    get: { self.expandedSections.contains(type) },
                    set: { isOpen in
                        if isOpen { self.expandedSections.insert(type) }
                        else { self.expandedSections.remove(type) }
                    }
                )
            )
            .padding(.horizontal, 8)
            
            if isExpanded {
                expansionDivider(theme: theme)
                
                let items = viewModel.groupedItems[type] ?? []
                ForEach(items, id: \.objectID) { item in
                    itemRow(item: item, isLast: item == items.last)
                }
            }
        }
        .background(cardGradient(isExpanded: isExpanded, theme: theme))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 0.5))
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
    }

    @ViewBuilder
    public func itemRow(item: ItemEntity, isLast: Bool) -> some View {
        Group {
            if viewModel.isItemHidden(item) {
                groupedListRow(for: item)
                    .padding(.horizontal, 15)
            } else {
                SwipeToDeleteRow(onDelete: { deleteItem(item) }) {
                    groupedListRow(for: item)
                        .padding(.horizontal, 15)
                        .background(Color.clear)
                        .contentShape(.rect)
                }
            }
        }
        .id(item.objectID)
        
        if !isLast {
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color(.separator))
                .padding(.horizontal, 15)
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
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .named("scroll")).minY
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
