import SwiftUI

struct ExerciseLoggerView: View {
    let exerciseName: String
    
    @State private var weight: Double?
    @State private var reps: Int?
    @State private var personalRecord: Double = 0.0
    @State private var showHistorySheet = false // Para abrir el historial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- BLOQUE 1: PR (RÉCORD PERSONAL) ---
            HStack {
                VStack(alignment: .leading) {
                    Text("TU RÉCORD (PR)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(personalRecord > 0 ? "\(personalRecord, specifier: "%.1f")" : "--")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.orange)
                        
                        Text("kg")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundStyle(personalRecord > 0 ? Color.yellow : Color.gray.opacity(0.3))
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)

            // --- BLOQUE 2: REGISTRAR SERIE ---
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peso")
                        .font(.caption2).foregroundStyle(.secondary)
                    TextField("kg", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption2).foregroundStyle(.secondary)
                    TextField("0", value: $reps, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button(action: saveEntry) {
                    Text("Guardar")
                        .bold()
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 20)
                        .background(canSave ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                .disabled(!canSave)
                .padding(.top, 16)
            }
            .padding(.horizontal)
            
            // --- BLOQUE 3: BOTÓN HISTORIAL ---
            Button(action: { showHistorySheet = true }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Ver Historial por Días")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .foregroundStyle(.primary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .onAppear(perform: updateData)
        
        // --- HOJA DE HISTORIAL (Sheet) ---
        .sheet(isPresented: $showHistorySheet) {
            HistoryDetailListView(exerciseName: exerciseName)
                .presentationDetents([.medium, .large]) // Se puede deslizar a mitad o pantalla completa
        }
    }
    
    var canSave: Bool {
        return weight != nil && reps != nil
    }
    
    func saveEntry() {
        guard let w = weight, let r = reps else { return }
        HistoryManager.shared.saveLog(exerciseName: exerciseName, weight: w, reps: r)
        
        // Limpiar y actualizar PR
        withAnimation {
            reps = nil
            updateData()
        }
    }
    
    func updateData() {
        personalRecord = HistoryManager.shared.getPersonalRecord(for: exerciseName)
    }
}

// --- VISTA SECUNDARIA: EL HISTORIAL AGRUPADO POR DÍAS ---
struct HistoryDetailListView: View {
    let exerciseName: String
    @State private var logs: [ExerciseLog] = []
    @Environment(\.dismiss) var dismiss // Para cerrar la ventana
    
    var body: some View {
        NavigationStack {
            List {
                if logs.isEmpty {
                    ContentUnavailableView("Sin historial", systemImage: "dumbbell", description: Text("Completa tu primera serie para verla aquí."))
                } else {
                    // Agrupar logs por fecha (Día)
                    let groupedLogs = Dictionary(grouping: logs) { log in
                        Calendar.current.startOfDay(for: log.date)
                    }
                    // Ordenar las fechas (de más reciente a antigua)
                    let sortedDates = groupedLogs.keys.sorted(by: >)
                    
                    ForEach(sortedDates, id: \.self) { date in
                        Section(header: Text(formatDate(date))) {
                            ForEach(groupedLogs[date]!) { log in
                                HStack {
                                    Text("\(log.reps) reps")
                                        .bold()
                                    Spacer()
                                    Text("\(log.weight, specifier: "%.1f") kg")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .onDelete { indexSet in
                                // Lógica simple de borrado para la vista
                                deleteLog(at: indexSet, for: date)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historial: \(exerciseName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cerrar") { dismiss() }
            }
            .onAppear {
                logs = HistoryManager.shared.loadLogs(for: exerciseName)
            }
        }
    }
    
    // Función auxiliar para formatear la fecha bonita
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Ej: "8 ene 2024"
        formatter.timeStyle = .none
        
        if Calendar.current.isDateInToday(date) { return "Hoy" }
        if Calendar.current.isDateInYesterday(date) { return "Ayer" }
        return formatter.string(from: date)
    }
    
    func deleteLog(at offsets: IndexSet, for date: Date) {
        // Encontrar los logs reales en el array principal para borrarlos
        // Esta es una implementación simplificada para la UI
        let logsToDelete = offsets.map { Dictionary(grouping: logs) { Calendar.current.startOfDay(for: $0.date) }[date]![$0] }
        
        // Borrar uno a uno (no es lo más eficiente pero funciona seguro con IndexSet)
        var currentLogs = HistoryManager.shared.loadLogs(for: exerciseName)
        currentLogs.removeAll { log in logsToDelete.contains(where: { $0.id == log.id }) }
        
        // Guardar cambios
        if let encoded = try? JSONEncoder().encode(currentLogs) {
            UserDefaults.standard.set(encoded, forKey: "history_\(exerciseName)")
        }
        
        // Recargar vista
        logs = HistoryManager.shared.loadLogs(for: exerciseName)
    }
}
