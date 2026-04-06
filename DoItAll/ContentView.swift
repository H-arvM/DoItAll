//
//  ContentView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import CoreData
import LocalAuthentication
import MapKit
import Combine
import UserNotifications
import CoreData

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = 0
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct ContentView: View {
    
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showSortOptions: Bool = false
    @State private var expandedSections: Set<ItemType> = Set(Item.allcases)
    @State private var scrollOffSet: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isScrolling: Bool = false
    @State private var hideButtonsWorkItem: DispatchWorkItem?
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.journalText, ascending: true)], animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeBackgroundView(theme: themeManager.selectedTheme)
                
                itemsList
                floatingButtonOverlay
            }
            /// Only navigate directly to if not hidden or if authenticated
            .navigationDestination(for: Item.self) { item in
                if !viewModel.isItemHidden(item) || viewModel.selectedItem == item {
                    destinationView(for: ItemType(rawValue: item.type) ?? .typeA, item: item)
                }
            }
            .navigationDestination(item: $viewModel.selectedItem) { item in
                destinationView(for: ItemType(rawValue: item.type) ?? .typeA, item: item)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SelectEntryView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(themeManager.selectedTheme.iconColour)
                    }
                }
            }
        }
        .alert("Authentication required", isPresented: $viewModel.showAuthAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            if let error = viewModel.authError {
                Text(error.errorDescription ?? "An erroor occured")
            }
        }
        .fullScreenCover(isPresented: $viewModel.showOnboarding) {
            content: {
                OnboardingView(isPresented: $viewModel.showOnboarding, dontShowAgain: $viewModel.hasSeenOnboarding)
            }
        }
        .onAppear {
            viewModel.setupViewModel()
            viewModel.checkOnboarding()
            viewModel.loadItems() /// Refresh items when view appears
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JournalEntrySaved"))) { _ in
            /// Refresh the list when a journal entry is saved
            viewModel.loadItems()
        }
        .onChange(of: viewModel.items) { _, _ in
        }
        .confirmationDialog("Sort by", isPresented: $showSortOptions, titleVisibility: .visible) {
            ForEach(SortOption.AllCases, id: \.self) { option in
                Button {
                    withAnimation {
                        viewModel.setSortOption(option)
                    }
                } label: {
                    HStack {
                        Image(systemName: option.systemImage)
                        Text(option.rawValue)
                        if viewModel.currentSortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: ViewBuilders
    private var rowHeight: CGFloat {
        viewModel.currentSortOption == .type ? 50 : 70
    }
    
    @ViewBuilder
    private itemsList: some View {
        if viewModel.currentSortOption == .type {
            groupedList
                .cornerRadius(10)
        } else {
            simpleList
        }
    }
    
    @ViewBuilder
    private var groupedList: some View {
        List {
            ForEach(viewModel.sortedItemTypes, id: \.self) { type in
                Section {
                    VStack(spacing: 0) {
                        groupedHeader(for: type)
                            .padding(.horizontal, 8)
                        
                        if expandedOptions.contains(type) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [themeManager.selectedTheme.primaryColour.opacity(0.6),
                                                 themeManager.selectedTheme.secondaryColour.opacity(0.4),
                                                 themeManager.selectedTheme.primaryColour.opacity(0.6),
                                                 startPoint: .leading,
                                                 endPoint: .trailing
                                    )
                                )
                                .transition(.opacity.combined(with: .scale(scale: 1.0, anchor: .top)))
                            
                            ForEach(viewModel.groupedItems[type] ?? [], id: \.objectID) { item in
                                if viewModel.isItemHidden(item) {
                                    /// Hidden rows don't need swipe to delete
                                    groupedListRow(for: item)
                                        .id(item.objectID)
                                        .padding(.horizontal, 15)
                                } else {
                                    SwipeToDeleteRow(onDelete: {
                                        deleteItem(item) }) {
                                            groupedListRow(for: item)
                                                .id(item.objectID)
                                                .padding(.horizontal, 15)
                                                .background(Color(UIColor.systemBackground))
                                                .contentShape(.rect)
                                        }
                                }
                                if item != viewModel.groupedItems[type]?.last {
                                    Rectangle()
                                        .frame(height: 0.5)
                                        .foregroundStyle(Color(UIColor.separator))
                                        .padding(.horizontal, 15)
                                }
                            }
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [themeManager.selectedTheme.primaryColour.opacity(expandedSections.contains(type) ? 0.15 : 0.1),
                                     themeManager.selectedTheme.secondaryColour.opacity(expandedSections.contains(type) ? 0.1 : 0.05)
                                    ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.separator), lineWidth: 0.5)
                    )
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            
            Color.clear
                .frame(height: 0)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .name("scroll")).minY
                        )
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .coordinateSpace("scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            handleScroll(offset: value)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transition(.opacity)
    }
    
    @ViewBuilder
    private var simpleList: some View {
        List(viewModel.items) { item in
            if viewModel.isItemHidden(item) {
                /// Hidden row
                listRow(for: item)
            } else {
                SwipeToDeleteRow(onDelete: { deleteItem(item) }) {
                    listRow(for: item)
                }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .name("scroll")).minY
                )
            }
        )
        .coordinateSpace("scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            handleScroll(offset: value)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transition(.opacity)
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func groupHeader(for type: ItemType) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if expandedSections.contains(type) {
                    expandedSections.remove(type)
                } else {
                    expandedSections.insert(type)
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: type.iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
                    .frame(width: 30)
                
                Text(type.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    .rotationEffect(.degrees(expandedSections.contains(type) ? 0 : -90))
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func listRow(for item: Item) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    @ViewBuilder
    private func groupedListRow(for item: Item) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenGroupedListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    private func hiddenListRow(for item: Item) -> some View {
        Button {
            viewModel.handleHiddenItemTap(item)
        } label: {
            hiddenRowContent(for: item)
        }
        .frame(height: rowHeight)
        .padding(.leading, viewModel.currentSortOption == .type ? -16 : -8)
        .padding(.trailing, viewModel.currentSortOption == .type ? 0 : 10)
        .buttonStyle(.plain)
        .contentShape(.rect)
        .listRowInsets(EdgeInsets())
        .listRowBackground(rowBackground(for: item))
        .listRowSeparator(.hidden)
        .background(glassBackground(for: item)
    }
    
    private func hiddenRowContent(for item: Item) -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                rowContent(for: item)
            }
            .contentShape(.rect)
            .frame(height: rowHeight)
            
            hiddenIndicatorIcon(for: item)
                .frame(height: rowHeight)
                .zIndex(1)
                .allowsHitTesting(true)
            
            navigationArrow(for: item)
                .zIndex(2)
                .allowsHitTesting(true)
        }
    }
    
    // Normal row
    private func normalListRow(for item: Item) -> some View {
        NavigationLink(value: item) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    rowContent(for: item)
                    if viewModel.currentSortOption == .type {
                        Spacer()
                            .frame(width: 18)
                    }
                }
                .contentShape(.rect)
                .frame(height: rowHeight)
                
                if item.objectID != viewModel.items.last?.objectID && viewModel.currentSortOption == .dateCreated {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color(UIColor.separator))
                }
            }
        }
        .simultaneousGesture(longPressGesture(for: item))
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 10,
            bottom: 0,
            trailing: viewModel.currentSortOption == .type ? -5 : 10)
        )
        .listRowBackground(rowBackground(for: item))
        .listRowSeparator(.hidden)
    }
    
    private func normaleGroupedListRow(for item: Item) -> some View {
        Button {
            viewModel.selectedItem = item
        } label: {
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    rowContent(for: item)
                    Spacer()
                        .frame(width: 18)
                }
                .contentShape(.rect)
                .frame(height: rowHeight)
                
                VStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(height: rowHeight)
                .padding(.trailing, 5)
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(longPressGesture(for: item))
    }
    
    private func hiddenGroupedListRow(for item: Item) -> some View {
        Button{
            viewModel.handleHiddenItemTap(item)
        } label: {
            hiddenGroupRowContent(for: item)
        }
        .frame(height: rowHeight)
        .buttonStyle(.plain)
        .content(.rect)
    }
    
    private func hiddenGroupedRowContent(for item: Item) -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                rowContent(for: item)
            }
            .contentShape(.rect)
            .frame(height: rowHeight)
            .allowsHitTesting(true)
            
            HStack {
                VStack {
                    Spacer()
                    HiddenIndicatorView(onLongPress: {
                        viewModel.handleLongPress(for: item)
                    })
                    Spacer()
                }
                .frame(height: rowHeight)
                .padding(.trailing, 5)
                
                VStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(height: rowHeight)
                .allowsHitTesting(true))
            }
            .zIndex(1)
        }
        .background(
            GeometryReader { geometry in
                GlassmoprhicBackground()
                    .frame(width: UIScreen.screenWidth, height: rowHeight)
                    .offset(x: -geometry.frame(in: .global).minX)
                    .id(item.id)
            }
                .frame(height: rowHeight)
        )
    }
    
    @ViewBuilder
    private func rowBackground(for item: Item) -> some View {
        Color.clear
    }
    
    @ViewBuilder
    private func rowContentNotHidden(for item: Item) -> some View {
        if viewModel.isItemHidden(item) {
            HStack(spacing: 0) {
                rowContent(for: item)
                
                if viewModel.currentSortOption == .type {
                    Spacer
                        .frame(width: 18)
                }
            }
            .contentShape(.rect)
            .allowsHitTesting(true)
        } else {
            HStack(spacing: 0) {
                NavigationLink(value: item) {
                    rowContent(for: item)
                        .padding(.trailing, 12)
                }
                .simultaneousGesture(longPressGesture(for: item))
                
                if viewModel.currentSortOption == .type {
                    Spacer()
                        .frame(width: 18)
                }
            }
            .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    private func navigationArrow(for item: Item) -> some View {
        if viewModel.isItemHidden(item) {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .frame(height: rowHeight)
        }
    }
    
    @ViewBuilder
    private func hiddenIndicatorIcon(for item: Item) -> some View {
        if viewModel.isItemHidden(item) {
            VStack {
                Spacer()
                HiddenIndicatorView(onLongPress: {
                    viewModel.handleLongPress(for: item)
                })
                Spacer()
            }
            .padding(.leading, 20)
            .frame(height: rowHeight)
        }
    }
    
    @ViewBuilder
    private func glassBackground(for item: Item) -> some View {
        GeometryReader { geometry in
            if viewModel.isItemHidden(item) {
                GlassMorphicBackground()
                    .frame(width: UIScreen.screenWidth, height: rowHeight)
                    .offset(x: -geometry.frame(in: .global).minX)
                    .id(item.id)
            }
        }
        .frame(height: rowHeight)
    }
    
    @ViewBuilder
    private func floatingButtonOverlay(for item: Item) -> some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                FloatingArrowButton(
                    showSortOptions: $showSortOptions,
                    currentSortOption: viewModel.currentSortOption,
                    onToggleSort: {
                        let allOptions = SortOption.allCases
                        if let currentIndex = allOptions.firstIndex(of: viewModel.currentSortOption) {
                            let nextIndex = (currentIndex + 1) % allOptions.count
                            viewModel.setSortOption(allOptions[nextIndex])
                        }
                    }
                )
                .padding(.leading, 20)
                .padding(.bottom, 20)
                Spacer()
            }
        }
        .offset(y: isScrolling ? 200 : 0)
        .animation(.easeInOut(duration: 0.3), value: isScrolling)
        .ignoresSafeArea(.keyboard)
    }
    
    
    // TODO: Point AI here and have update the CoreData models and consider all the other entryTypes too
    @ViewBuilder
    private func rowContent(for item: Item) -> some View {
        HStack {
            if viewModel.currentSortOption == .dateCreated {
                Image(systemName: item.itemType.iconName)
                    .font(.system(size: viewModel.isItemHidden(item) ? 16 : 20, weight: .medium))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
                    .frame(width: viewModel.isItemHidden(item) ? 24 : 28)
                    .opacity(viewModel.isItemHidden(item) ? 0 : 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if item.itemType == .typeA, let journalEntry == item.journalEntry {
                    Text(journalEntry.title)
                        .font(viewModel.currentSortOption == .type ? .subheadline : headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    
                    Text(journalEntry.createdAt.funFormatString)
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                } else {
                    Text(item.title)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    
                    Text(item.createdAt.funFormatString)
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                }
            }
            .opacity(viewModel.isItemHidden(item) ? 0 : 1)
        }
        .opacity(viewModel.isItemHidden(item) ? 0.01 : 1)
        .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
        .padding(.horizontal, 5)
    }
    
    // TODO: All emptyViews for now. WIll have them navigate properly later
    @ViewBuilder
    private func destinationView(for type: ItemType, item: Item) -> some View {
        switch type {
        case .journal:
            if let journalEntry = item.journalText {
                EmptyView()
            }
//        case .freeForm
//            if let freeform = item. {
//            
//        }
    }
        
        
        
        

    
    // MARK: Helper methods
    
    private func handleScroll(offset: CGFloat) {
        let delta = offset - lastScrollOffset
        
        if abs(delta) > 5 {
            withAnimation {
                isScrolling = true
            }
        }
        
        lastScrollOffset = offset
        
        hideButtonsWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation {
                isScrolling = true
            }
        }
        hideButtonsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func longPressGesture(for item: Item) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3) /// May need to tweak this after real device test
            .onEnded { _ in
                viewModel.handleLongPress(for: item)
            }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
            viewModel.loadItems()
        }
    }
    
    
    
    
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

