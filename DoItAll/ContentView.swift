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
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showSortOptions: Bool = false
    @State private var expandedSections: Set<ItemType> = Set(ItemType.allCases)
    @State private var isShowingSelectEntry = false
    
    private let titleLimit = 50
    
    var body: some View {
        NavigationStack {
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
            settingsButton()
        }
        .navigationDestination(for: ItemEntity.self) { item in
            navigationDestination(for: item)
        }
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder
    private func navigationDestination(for item: ItemEntity) -> some View {
        let itemType = ItemType(rawValue: item.type ?? "") ?? .journalType
        let isVisible = !viewModel.isItemHidden(item) || viewModel.selectedItem == item

        if isVisible {
            destinationView(for: itemType, item: item)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var authAlertMessage: some View {
        if let error = viewModel.authError {
            Text(error.errorDescription ?? "An error occurred")
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
            FreeFormView(mode: item.freeWritingEntry == nil ? .edit : .view,
                         entry: item.getOrCreateFreeWritingEntry(context: viewContext)
            )
            
        case .lifeAdminType:
            LifeAdminView(entry: item.getOrCreateAdminEntry(context: viewContext))
            
        case .generalNoteType:
            NoteListView(entry: item.getOrCreateChecklistEntry(context: viewContext))
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
    
    private var rowHeight: CGFloat {
        viewModel.currentSortOption == .type ? 80 : 100
    }
    
    @ViewBuilder
    private var itemsList: some View {
        if viewModel.items.isEmpty {
            PlaceHolderContentView()
        } else {
            listViewContent
        }
    }
    
    private var listViewContent: some View {
        Group {
            if viewModel.currentSortOption == .type {
                groupedList
                    .cornerRadius(10)
            } else {
                simpleList
            }
        }
    }
    
    @ViewBuilder
    private var groupedList: some View {
        List {
            ForEach(viewModel.sortedItemTypes, id: \.self) { type in
                Section {
                    VStack(spacing: 0) {
                        groupHeader(for: type)
                            .padding(.horizontal, 8)
                        
                        if expandedSections.contains(type) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [themeManager.selectedTheme.primaryColour.opacity(0.6),
                                                 themeManager.selectedTheme.secondaryColour.opacity(0.4),
                                                 themeManager.selectedTheme.primaryColour.opacity(0.6)],
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
                    .cornerRadius(10)
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
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
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
    private func listRow(for item: ItemEntity) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    @ViewBuilder
    private func groupedListRow(for item: ItemEntity) -> some View {
        if viewModel.isItemHidden(item) {
            hiddenGroupedListRow(for: item)
        } else {
            normalListRow(for: item)
        }
    }
    
    private func hiddenListRow(for item: ItemEntity) -> some View {
        Button {
            viewModel.handleHiddenItemTap(item)
        } label: {
            hiddenRowContent(for: item)
        }
        .frame(height: rowHeight)
        .padding(.leading, viewModel.currentSortOption == .type ? -16 : -8)
        .padding(.trailing, viewModel.currentSortOption == .type ? 0 : 10)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
        .listRowBackground(rowBackground(for: item))
        .listRowSeparator(.hidden)
        .background(glassBackground(for: item))
    }
    
    private func hiddenRowContent(for item: ItemEntity) -> some View {
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
    
    // Normal row
    private func normalListRow(for item: ItemEntity) -> some View {
        NavigationLink(value: item) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    rowContent(for: item)
                    if viewModel.currentSortOption == .type {
                        Spacer()
                            .frame(width: 18)
                    }
                }
                .contentShape(Rectangle())
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
    
    private func normalGroupedListRow(for item: ItemEntity) -> some View {
        Button {
            viewModel.selectedItem = item
        } label: {
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    rowContent(for: item)
                    Spacer()
                        .frame(width: 18)
                }
                .contentShape(Rectangle())
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
    
    private func hiddenGroupedListRow(for item: ItemEntity) -> some View {
        Button {
            viewModel.handleHiddenItemTap(item)
        } label: {
            hiddenGroupedRowContent(for: item)
        }
        .frame(height: rowHeight)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
    
    private func hiddenGroupedRowContent(for item: ItemEntity) -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                rowContent(for: item)
            }
            .contentShape(Rectangle())
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
                .allowsHitTesting(true)
            }
            .zIndex(1)
        }
        .background(
            GeometryReader { geometry in
                GlassMorphicBackground()
                    .frame(width: UIScreen.screenWidth, height: rowHeight)
                    .offset(x: -geometry.frame(in: .global).minX)
                    .id(item.id)
            }
                .frame(height: rowHeight)
        )
    }
    
    @ViewBuilder
    private func rowBackground(for item: ItemEntity) -> some View {
        Color.clear
    }
    
    @ViewBuilder
    private func rowContentNotHidden(for item: ItemEntity) -> some View {
        if viewModel.isItemHidden(item) {
            HStack(spacing: 0) {
                rowContent(for: item)
                
                if viewModel.currentSortOption == .type {
                    Spacer()
                        .frame(width: 18)
                }
            }
            .contentShape(Rectangle())
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
            .contentShape(Rectangle())
        }
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
    
    @ViewBuilder
    private func settingsButton() -> some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                FloatingMenuButton(
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
        .offset(y: viewModel.isScrolling ? 200 : 0)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isScrolling)
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private func rowContent(for item: ItemEntity) -> some View {
        HStack {
            if viewModel.currentSortOption == .dateCreated {
                Image(systemName: item.itemType.iconName)
                    .font(.system(size: viewModel.isItemHidden(item) ? 16 : 20, weight: .medium))
                    .foregroundStyle(themeManager.selectedTheme.iconColour)
                    .frame(width: viewModel.isItemHidden(item) ? 24 : 28)
                    .opacity(viewModel.isItemHidden(item) ? 0 : 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                switch item.itemType {
                    
                case .journalType:
                    let journalEntry = item.journalEntry
                    let content = journalEntry?.content ?? ""
                    
                    Text(String(content.prefix(titleLimit)))
                        .lineLimit(1)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    Text(journalEntry?.createdDate?.funFormatString ?? "")
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    
                case .shoppingListType:
                    let shoppingList = item.shoppingEntry
                    let content: String = {
                        if let itemsSet = shoppingList?.items as? Set<ShoppingItem>,
                           let first = itemsSet.first {
                            return first.name ?? ""
                        } else if let itemsArray = shoppingList?.items?.allObjects as? [ShoppingItem],
                                  let first = itemsArray.first {
                            return first.name ?? ""
                        } else {
                            return ""
                        }
                    }()
                    Text(String(content))
                        .lineLimit(1)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    Text(item.createdAt?.funFormatString ?? Date().funFormatString)
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    
                case .freeFormType:
                    let freeForm = item.freeWritingEntry
                    Text(freeForm?.title ?? item.title ?? "No title")
                        .lineLimit(1)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    Text(item.createdAt?.funFormatString ?? Date().funFormatString)
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    
                case .lifeAdminType:
                    let lifeAdmin = item.taskItemEntry
                    Text(lifeAdmin?.entryType ?? item.title ?? "No title")
                        .lineLimit(1)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                    Text(item.createdAt?.funFormatString ?? Date().funFormatString)
                        .font(.caption2)
                        .foregroundStyle(themeManager.selectedTheme.secondaryTextColour ?? .secondary)
                    
                case .generalNoteType:
                    let checklist = item.checkListEntry
                    let firstNote: String = {
                        if let itemsSet = checklist?.items as? Set<CheckListItem>,
                           let first = itemsSet.sorted(by: { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }).first {
                            return first.note ?? ""
                        } else if let itemsArray = checklist?.items?.allObjects as? [CheckListItem],
                                  let first = itemsArray.sorted(by: { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }).first {
                            return first.note ?? ""
                        } else if let title = checklist?.title, !title.isEmpty {
                            return title
                        } else {
                            return "No title"
                        }
                    }()
                    Text(verbatim: firstNote)
                        .lineLimit(1)
                        .font(viewModel.currentSortOption == .type ? .subheadline : .headline)
                        .foregroundStyle(themeManager.selectedTheme.primaryTextColour ?? .primary)
                }
            }
            .opacity(viewModel.isItemHidden(item) ? 0 : 1)
        }
        .opacity(viewModel.isItemHidden(item) ? 0.01 : 1)
        .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
        .padding(.horizontal, 5)
    }
    
    
    private func longPressGesture(for item: ItemEntity) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                viewModel.handleLongPress(for: item)
            }
    }
    
    private func deleteItem(_ item: ItemEntity) {
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

