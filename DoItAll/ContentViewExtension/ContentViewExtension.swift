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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        if isOpen { self.expandedSections.insert(type) }
                        else      { self.expandedSections.remove(type) }
                    }
                }
            )
        )
        .padding(.horizontal, 8)
        .background(
            ZStack {
                RoundedCorner(radius: 10, corners: isExpanded ? [.topLeft, .topRight] : .allCorners)
                    .fill(.ultraThinMaterial)
                    .opacity(0.85)

                cardGradient(isExpanded: isExpanded, theme: theme)
                    .clipShape(RoundedCorner(radius: 10, corners: isExpanded ? [.topLeft, .topRight] : .allCorners))
                    .opacity(0.6)
            }
        )
        .padding(.horizontal, 10)
        .padding(.top, 10)

        if isExpanded {
            let itemsArray = items

            ForEach(itemsArray, id: \.objectID) { item in
                let isLast = item.objectID == itemsArray.last?.objectID

                itemRow(item: item, isLast: isLast)
                    .background(
                        ZStack {
                            RoundedCorner(radius: isLast ? 10 : 0, corners: [.bottomLeft, .bottomRight])
                                .fill(.thinMaterial)
                                .opacity(0.75)

                            cardGradient(isExpanded: true, theme: theme)
                                .clipShape(RoundedCorner(radius: isLast ? 10 : 0, corners: [.bottomLeft, .bottomRight]))
                                .opacity(0.5)
                        }
                    )
                    .overlay(
                        VStack {
                            if item.objectID != itemsArray.first?.objectID {
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundStyle(Color.white.opacity(0.15))
                            }
                            Spacer()
                        }
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
            if !isLast {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.separator))
                    .padding(.horizontal, 15)
            }
        }
    }
    
    public func cardGradient(isExpanded: Bool, theme: BackgroundTheme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.primaryColour.opacity(isExpanded ? 0.25 : 0.15),
                theme.secondaryColour.opacity(isExpanded ? 0.18 : 0.08)
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
                    let raw     = geometry.frame(in: .named("scroll")).minY
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
    public func hiddenGroupedOverlay(for item: ItemEntity) -> some View {
        let theme = themeManager.selectedTheme

        HStack {
            HiddenIndicatorView(onLongPress: {
                viewModel.handleLongPress(for: item)
            })
            .frame(height: rowHeight)
            .padding(.trailing, 5)
            .padding(.leading, 10)

            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.secondaryTextColour ?? .secondary)
                Spacer()
                    
            }
            .padding(.trailing, 10)
            .frame(height: rowHeight)
        }
    }

    @ViewBuilder
    public func hiddenRowBackground(for item: ItemEntity, isGrouped: Bool = false) -> some View {
        if isGrouped {
            GlassMorphicBackground()
                .frame(height: rowHeight)
                .id(item.id)
        } else {
            GeometryReader { geometry in
                GlassMorphicBackground()
                    .frame(width: UIScreen.screenWidth, height: rowHeight)
                    .offset(x: -geometry.frame(in: .global).minX)
                    .id(item.id)
            }
            .frame(height: rowHeight)
        }
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
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
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

    private struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    private struct AnyShape: Shape {
        private let _path: (CGRect) -> Path

        init<S: Shape>(_ shape: S) {
            _path = { rect in shape.path(in: rect) }
        }

        func path(in rect: CGRect) -> Path { _path(rect) }
    }
}

//#Preview {
//    ContentViewExtension()
//}
