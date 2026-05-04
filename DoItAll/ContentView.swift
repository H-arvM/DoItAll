//
//  ContentView.swift
//  DoItAll
//
//  Created by Marc Harvey on 30/08/2025.
//

import SwiftUI
import LocalAuthentication
import MapKit
import Combine
import UserNotifications
import CoreData

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject public var viewModel = ContentViewModel()
    @StateObject public var themeManager = ThemeManager.shared
    @State public var showSortOptions: Bool = false
    @State public var expandedSections: Set<ItemType> = Set(ItemType.allCases)
    @State public var isShowingSelectEntry = false
    
    private let titleLimit = 50
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            mainContent
        }
        .alert("Authentication required", isPresented: $viewModel.showAuthAlert) {
            Button("Ok", role: .cancel) { }
        } message: {
            authAlertMessage
        }
        .fullScreenCover(isPresented: $viewModel.showOnboarding) {
            OnboardingView(isPresented: $viewModel.showOnboarding, dontShowAgain: $viewModel.hasSeenOnboarding)
        }
        .fullScreenCover(isPresented: $isShowingSelectEntry) {
            SelectEntryTypeView()
        }
        .onAppear {
            viewModel.setupViewModel()
            viewModel.checkOnboarding()
            viewModel.loadItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JournalEntrySaved"))) { _ in
            viewModel.loadItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LifeAdminEntrySaved"))) { _ in
            viewModel.loadItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FreeFormEntrySaved"))) { _ in
            viewModel.loadItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShoppingEntrySaved"))) { _ in
            viewModel.loadItems()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CheckListEntrySaved"))) { _ in
            viewModel.loadItems()
        }
        .confirmationDialog("Sort by", isPresented: $showSortOptions, titleVisibility: .visible) {
            sortOptionsContent
        }
    }
    
    private var mainContent: some View {
        ZStack {
            ThemeBackgroundView(theme: themeManager.selectedTheme)
            itemsList
            SettingsButton(viewModel: viewModel)
        }
        .navigationDestination(for: ItemNavigationDestination.self) { destination in
            if let item = try? viewContext.existingObject(with: destination.itemID) as? ItemEntity {
                destinationView(for: destination.itemType, item: item)
            }
        }
        .toolbar {
            toolbarContent
        }
    }
    
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isShowingSelectEntry = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
            }
        }
    }
    
    @ViewBuilder
    private var itemsList: some View {
        if viewModel.items.isEmpty {
            PlaceHolderContentView()
        } else {
            listViewContent
        }
    }
    
    public var listViewContent: some View {
        Group {
            if viewModel.currentSortOption == .type {
                groupedList
                    .cornerRadius(10)
            } else {
                simpleList
            }
        }
    }
    
    public var groupedList: some View {
        List {
            ForEach(viewModel.sortedItemTypes, id: \.self) { type in
                Section {
                    sectionCard(for: type)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            
            scrollTrackingElement
        }
        .coordinateSpace(name: "scroll")
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transition(.opacity)
    }
        
    @ViewBuilder
    private var simpleList: some View {
        List(viewModel.items) { item in
            if viewModel.isItemHidden(item) {
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
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
        )
        .coordinateSpace(name: "scroll")
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transition(.opacity)
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func listRow(for item: ItemEntity) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    @ViewBuilder
    public func groupedListRow(for item: ItemEntity) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenGroupedListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    public func hiddenListRow(for item: ItemEntity) -> some View {
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
        .background(glassBackground(for: item))
    }
    
    public func hiddenRowContent(for item: ItemEntity) -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                rowContent(for: item)
            }
            .contentShape(Rectangle())
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
    
    private func normalListRow(for item: ItemEntity) -> some View {
        rowVariant(for: item, sortOption: viewModel.currentSortOption)
            .simultaneousGesture(longPressGesture(for: item))
            .listRowInsets(rowInsets(for: viewModel.currentSortOption))                .listRowBackground(rowBackground(for: item))
            .listRowSeparator(.hidden)
    }
    
    private func hiddenGroupedListRow(for item: ItemEntity) -> some View {
        Button {
            viewModel.handleHiddenItemTap(item)
        } label: {
            hiddenGroupedRowContent(for: item)
        }
        .frame(height: rowHeight)
        .buttonStyle(.plain)
        .contentShape(.rect)
    }
    
    private func hiddenGroupedRowContent(for item: ItemEntity) -> some View {
        ZStack(alignment: .leading) {
            rowContent(for: item)
                .contentShape(Rectangle())
                .frame(height: rowHeight)
                .allowsHitTesting(true)
            
            hiddenOverlay(for: item)
                .zIndex(1)
        }
        .background(hiddenRowBackground(for: item))
    }
    
    @ViewBuilder
    private func rowBackground(for item: ItemEntity) -> some View {
        Color.clear
    }
    
    @ViewBuilder
    private func navigationArrow(for item: ItemEntity) -> some View {
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
    private func hiddenIndicatorIcon(for item: ItemEntity) -> some View {
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
    private func glassBackground(for item: ItemEntity) -> some View {
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
    
    public func rowContent(for item: ItemEntity) -> some View {
        let theme = themeManager.selectedTheme
        let isHidden = viewModel.isItemHidden(item)
        
        return HStack {
            if viewModel.currentSortOption == .dateCreated {
                Image(systemName: item.itemType.iconName)
                    .font(.system(size: isHidden ? 16 : 20, weight: .medium))
                    .foregroundStyle(theme.iconColour)
                    .frame(width: isHidden ? 24 : 28)
                    .opacity(isHidden ? 0 : 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                switch item.itemType {
                case .journalType:
                    let content = item.journalEntry?.content ?? ""
                    themedTextStack(
                        title: String(content.prefix(titleLimit)),
                        subtitle: item.journalEntry?.createdDate?.funFormatString
                    )
                    
                case .shoppingListType:
                    let content = viewModel.getShoppingListContent(item.shoppingEntry)
                    themedTextStack(
                        title: content,
                        subtitle: item.createdAt?.funFormatString ?? Date().funFormatString
                    )
                    
                case .freeFormType:
                    themedTextStack(
                        title: item.freeWritingEntry?.title ?? item.title ?? "No title",
                        subtitle: item.createdAt?.funFormatString ?? Date().funFormatString
                    )
                    
                case .lifeAdminType:
                    themedTextStack(
                        title: item.taskItemEntry?.entryType ?? item.title ?? "No title",
                        subtitle: item.createdAt?.funFormatString ?? Date().funFormatString
                    )
                    
                case .generalNoteType:
                    themedTextStack(
                        title: viewModel.getChecklistContent(item.checkListEntry),
                        subtitle: nil
                    )
                }
            }
            .opacity(isHidden ? 0 : 1)
        }
        .opacity(isHidden ? 0.01 : 1)
        .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
        .padding(.horizontal, 5)
        .background(Color.clear)
    }

    @ViewBuilder
    private func themedTextStack(title: String, subtitle: String?) -> some View {
        let theme = themeManager.selectedTheme
        
        Text(title)
            .lineLimit(1)
            .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
            .foregroundStyle(theme.primaryTextColour ?? .primary)
        
        if let subtitle = subtitle {
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(theme.secondaryTextColour ?? .secondary)
        }
    }
    
    @ViewBuilder
    private var sortOptionsContent: some View {
        ForEach(SortOption.allCases, id: \.self) { option in
            Button {
                withAnimation {
                    viewModel.setSortOption(option)
                }
            } label: {
                Text(option.rawValue)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for type: ItemType, item: ItemEntity) -> some View {
        switch type {
        case .journalType:
            JournalView(
                mode: item.journalEntry == nil ? .edit : .view,
                entry: item.getOrCreateJournalEntry(context: viewContext)
            )
            
        case .shoppingListType:
            ShoppingListView(entry: item.getOrCreateShoppingEntry(context: viewContext))
            
        case .freeFormType:
            FreeFormView(
                mode: item.freeWritingEntry == nil ? .edit : .view,
                entry: item.getOrCreateFreeWritingEntry(context: viewContext)
            )
           
        case .lifeAdminType:
            LifeAdminView(entry: item.getOrCreateAdminEntry(context: viewContext))
          
        case .generalNoteType:
            NoteListView(entry: item.getOrCreateChecklistEntry(context: viewContext))
        }
    }
    
    private func longPressGesture(for item: ItemEntity) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                viewModel.handleLongPress(for: item)
            }
    }
    
    public func deleteItem(_ item: ItemEntity) {
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
            viewModel.loadItems()
        }
    }
    
    public var rowHeight: CGFloat {
        viewModel.currentSortOption == .type ? 80 : 100
    }
    
    @ViewBuilder
    private var authAlertMessage: some View {
        if let error = viewModel.authError {
            Text(error.errorDescription ?? "An error occurred")
        }
    }
    
    private func rowInsets(for sortOption: SortOption) -> EdgeInsets {
        EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: sortOption == .type ? -5 : 10)
    }
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

