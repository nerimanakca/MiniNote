import SwiftUI
import UIKit


struct EditNoteView: View {
    let note: Note
    let onSave: (String, NoteCategory) -> Void
    
    @State private var category: NoteCategory
    @State private var text: String
    @Environment(\.dismiss) private var dismiss

    init(note: Note, onSave: @escaping (String, NoteCategory) -> Void) {
        self.note = note
        self.onSave = onSave
        _text = State(initialValue: note.text)
        _category = State(initialValue: note.category)
    }

    var body: some View {
        Form {
            Button("Kopyala") {
                UIPasteboard.general.string = text
            }
            
            Picker("Kategori", selection: $category) {
                ForEach(NoteCategory.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }

            TextField("Not", text: $text, axis: .vertical)
                .lineLimit(5...12)

            Button("Kaydet") {
                let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty else { return }
                onSave(t, category)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .navigationTitle("Düzenle")
    }
}
