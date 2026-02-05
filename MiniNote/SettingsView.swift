import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var notes: [Note]
    let saveNotes: () -> Void
    let hapticSuccess: () -> Void
    let hapticWarning: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var showExporter = false
    @State private var showImporter = false
    @State private var backupDoc = BackupDocument()
    @State private var showImportReplaceAlert = false
    @State private var importedNotes: [Note] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Yedekleme") {
                    Button {
                        prepareExport()
                        showExporter = true
                    } label: {
                        Label("Yedekle (JSON)", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImporter = true
                    } label: {
                        Label("İçe Aktar (JSON)", systemImage: "square.and.arrow.down")
                    }
                }

                Section("Veri") {
                    Button(role: .destructive) {
                        notes.removeAll()
                        saveNotes()
                        hapticWarning()
                    } label: {
                        Label("Tüm Notları Sil", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: backupDoc,
                contentType: .json,
                defaultFilename: "MiniNote_Backup"
            ) { result in
                if case .success = result {
                    hapticSuccess()
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json]
            ) { result in
                handleImport(result)
            }
            .alert("İçe aktarılan notlar bulundu", isPresented: $showImportReplaceAlert) {
                Button("Değiştir", role: .destructive) {
                    notes = importedNotes
                    saveNotes()
                    hapticSuccess()
                }
                Button("Birleştir") {
                    mergeImported()
                    saveNotes()
                    hapticSuccess()
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Mevcut notlarını tamamen değiştirebilir veya birleştirebilirsin.")
            }
        }
    }

    private func prepareExport() {
        do {
            let data = try JSONEncoder().encode(notes)
            backupDoc = BackupDocument(data: data)
        } catch {
            // basitçe ignore; istersen alert ekleriz
            backupDoc = BackupDocument(data: Data())
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Note].self, from: data)

            importedNotes = decoded
            showImportReplaceAlert = true
        } catch {
            // istersen burada hata alert’i ekleyebiliriz
            hapticWarning()
        }
    }

    private func mergeImported() {
        // aynı id varsa üstüne yazma; yoksa ekle
        var existingIDs = Set(notes.map { $0.id })
        for n in importedNotes {
            if !existingIDs.contains(n.id) {
                notes.append(n)
                existingIDs.insert(n.id)
            }
        }
        // En yeni üstte kalsın
        notes.sort { $0.createdAt > $1.createdAt }
    }
}

