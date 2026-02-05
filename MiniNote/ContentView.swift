import SwiftUI
import UIKit

enum NoteCategory: String, CaseIterable, Codable, Identifiable {
    case school = "Okul"
    case work = "İş"
    case personal = "Kişisel"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .school: return "graduationcap"
        case .work: return "briefcase"
        case .personal: return "person"
        }
    }
}

struct Note: Identifiable, Codable {
    let id: UUID
    let text: String
    let createdAt: Date
    let category: NoteCategory

    init(id: UUID = UUID(), text: String, createdAt: Date = .now, category: NoteCategory = .personal) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.category = category
    }
}

struct ZenQuote: Codable {
    let q: String  // quote
    let a: String  // author
}
    
struct ContentView: View {
    
    @State private var todayQuote: ZenQuote? = nil
    @State private var quoteLoading = false
    @State private var quoteError: String? = nil

    private let impact = UIImpactFeedbackGenerator(style: .light)
    private let notify = UINotificationFeedbackGenerator()

    private func hapticTap() {
        impact.impactOccurred()
    }

    private func hapticSuccess() {
        notify.notificationOccurred(.success)
    }

    private func hapticWarning() {
        notify.notificationOccurred(.warning)
    }

    private var todayCount: Int {
        let cal = Calendar.current
        return filteredNotes.filter { cal.isDateInToday($0.createdAt) }.count
    }
    

    private var totalCount: Int { notes.count }
    private var visibleCount: Int { filteredNotes.count }

    private var filteredNotes: [Note] {
        // 1) kategori filtresi
        var result = notes
        if let f = selectedFilter {
            result = result.filter { $0.category == f }
        }
        
        // 2) arama filtresi
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            result = result.filter { $0.text.localizedCaseInsensitiveContains(q) }
        }
        
        return result
    }
        @ViewBuilder
        private func filterChip(
            title: String,
            systemImage: String,
            isSelected: Bool,
            action: @escaping () -> Void
        ) -> some View {
            Button {
                hapticTap()
                action()
            } label: {
                Label(title, systemImage: systemImage)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        isSelected
                        ? Color.indigo.opacity(0.22)
                        : Color.secondary.opacity(0.10)
                    )
                    .overlay(
                        Capsule().stroke(isSelected ? Color.indigo.opacity(0.35) : Color.clear, lineWidth: 1)
                    )

                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }

    @State private var notes: [Note] = []
    @State private var newText: String = ""
    @State private var showingAdd = false
    @State private var query: String = ""
    @State private var selectedCategory: NoteCategory = .personal
    @State private var selectedFilter: NoteCategory? = nil // nil = Tümü
    @State private var showingSettings = false

    private var navigationTitleText: String {
        if let f = selectedFilter {
            return f.rawValue
        }
        return "Notlar"
    }

    private var summaryTitle: String {
        if let f = selectedFilter { return "\(f.rawValue) Özeti" }
        return "Genel Özet"
    }

    @ViewBuilder
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(summaryTitle)
                .font(.headline)

            HStack(spacing: 12) {
                summaryPill(title: "Toplam", value: "\(totalCount)", systemImage: "tray.full")
                summaryPill(title: "Görünen", value: "\(visibleCount)", systemImage: "list.bullet")
                summaryPill(title: "Bugün", value: "\(todayCount)", systemImage: "calendar")
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.indigo.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func summaryPill(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private struct NoteRow: View {
        let note: Note

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: note.category.icon)
                    .font(.headline)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(note.text)
                        .font(.headline)
                        .lineLimit(1)

                    Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
        }
    }

    private let storageKey = "notes_v2"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.14),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Günün Sözü")
                                    .font(.headline)
                                Spacer()
                                Button {
                                    hapticTap()
                                    fetchQuoteOfTheDay(force: true)
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .scrollContentBackground(.hidden)
                            }
                            .navigationTitle(navigationTitleText)
                            if quoteLoading {
                                ProgressView()
                            } else if let q = todayQuote {
                                Text("“\(q.q)”")
                                    .font(.subheadline)
                                Text("— \(q.a)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if let err = quoteError {
                                Text(err)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Yükleniyor…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.indigo.opacity(0.18), lineWidth: 1)
                        )

                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .tint(.indigo)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    Section {
                        summaryCard
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                filterChip(
                                    title: "Tümü",
                                    systemImage: "tray.full",
                                    isSelected: selectedFilter == nil
                                ) {
                                    selectedFilter = nil
                                    query = ""
                                }
                                
                                ForEach(NoteCategory.allCases) { cat in
                                    filterChip(
                                        title: cat.rawValue,
                                        systemImage: cat.icon,
                                        isSelected: selectedFilter == cat
                                    ) {
                                        selectedFilter = cat
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    if filteredNotes.isEmpty {
                        ContentUnavailableView(
                            "Sonuç yok",
                            systemImage: "magnifyingglass",
                            description: Text("Farklı bir filtre veya arama deneyebilirsin.")
                        )
                    } else {
                        ForEach(filteredNotes) { note in
                            NavigationLink {
                                EditNoteView(note: note) { updatedText, updatedCategory in
                                    if let i = notes.firstIndex(where: { $0.id == note.id }) {
                                        notes[i] = Note(
                                            id: note.id,
                                            text: updatedText,
                                            createdAt: note.createdAt,
                                            category: updatedCategory
                                        )
                                        saveNotes()
                                    }
                                }
                            } label: {
                                NoteRow(note: note)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteNote(note)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    UIPasteboard.general.string = note.text
                                    hapticSuccess()
                                } label: {
                                    Label("Kopyala", systemImage: "doc.on.doc")
                                }
                                .tint(.blue)
                                
                                ShareLink(item: note.text) {
                                    Label("Paylaş", systemImage: "square.and.arrow.up")
                                }
                                .tint(.green)
                            }
                        }
                    }
                }
                .searchable(text: $query, prompt: "Notlarda ara")
                .navigationTitle(navigationTitleText)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            hapticTap()
                            showingAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAdd) {
                    NavigationStack {
                        Form {
                            Picker("Kategori", selection: $selectedCategory) {
                                ForEach(NoteCategory.allCases) { cat in
                                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                                }
                            }
                            
                            TextField("Not yaz…", text: $newText, axis: .vertical)
                                .lineLimit(3...8)
                        }
                        .navigationTitle("Yeni Not")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Vazgeç") {
                                    newText = ""
                                    selectedCategory = .personal
                                    showingAdd = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Kaydet") {
                                    let t = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !t.isEmpty else { return }
                                    
                                    notes.insert(Note(text: t, category: selectedCategory), at: 0)
                                    saveNotes()
                                    hapticSuccess()
                                    
                                    newText = ""
                                    selectedCategory = .personal
                                    showingAdd = false
                                }
                                .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(
                    notes: $notes,
                    saveNotes: { saveNotes() },
                    hapticSuccess: { hapticSuccess() },
                    hapticWarning: { hapticWarning() }
                )
            }
            .onAppear { loadNotes()
                fetchQuoteOfTheDay()
            }
        }
    }
    private func deleteNote(_ note: Note) {
        if let i = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: i)
            saveNotes()
            hapticWarning()
        }
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Save error:", error)
        }
    }
    private let quoteDateKey = "quote_date"
    private let quoteTextKey = "quote_text"
    private let quoteAuthorKey = "quote_author"

    private func todayString() -> String {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func loadCachedQuoteIfToday() -> Bool {
        let savedDate = UserDefaults.standard.string(forKey: quoteDateKey)
        guard savedDate == todayString() else { return false }

        let q = UserDefaults.standard.string(forKey: quoteTextKey)
        let a = UserDefaults.standard.string(forKey: quoteAuthorKey)
        guard let q, let a else { return false }

        todayQuote = ZenQuote(q: q, a: a)
        return true
    }

    private func cacheQuote(_ quote: ZenQuote) {
        UserDefaults.standard.set(todayString(), forKey: quoteDateKey)
        UserDefaults.standard.set(quote.q, forKey: quoteTextKey)
        UserDefaults.standard.set(quote.a, forKey: quoteAuthorKey)
    }

    private func fetchQuoteOfTheDay(force: Bool = false) {
        if !force, loadCachedQuoteIfToday() { return }

        quoteLoading = true
        quoteError = nil

        Task {
            do {
                let url = URL(string: "https://zenquotes.io/api/today")!
                let (data, _) = try await URLSession.shared.data(from: url)

                // ZenQuotes /today -> JSON array, first element is the quote
                let arr = try JSONDecoder().decode([ZenQuote].self, from: data)
                guard let first = arr.first else { throw URLError(.badServerResponse) }

                await MainActor.run {
                    todayQuote = first
                    cacheQuote(first)
                    quoteLoading = false
                }
            } catch {
                await MainActor.run {
                    quoteLoading = false
                    quoteError = "Söz alınamadı"
                }
            }
        }
    }

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("Load error:", error)
        }
    }
}

