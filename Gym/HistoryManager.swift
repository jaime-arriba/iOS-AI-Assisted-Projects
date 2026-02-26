import Foundation
import SwiftUI

struct ExerciseLog: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let weight: Double
    let reps: Int
    let note: String
}

class HistoryManager {
    static let shared = HistoryManager()
    
    // CACHÉ RAM: Acceso instantáneo a los datos
    private var cache: [String: [ExerciseLog]] = [:]
    
    // COLA DE TRABAJO: Para guardar en segundo plano sin bloquear la pantalla
    private let saveQueue = DispatchQueue(label: "com.gymtracker.saveQueue", qos: .utility)
    
    private init() {}
    
    // --- LECTURA (Rápida) ---
    func loadLogs(for exerciseName: String) -> [ExerciseLog] {
        // 1. Si está en RAM, devolvemos al instante (0.0001ms)
        if let cachedLogs = cache[exerciseName] {
            return cachedLogs
        }
        // 2. Si no, leemos disco (solo pasa la primera vez)
        let logs = loadFromDisk(for: exerciseName)
        cache[exerciseName] = logs
        return logs
    }
    
    func getPersonalRecord(for exerciseName: String) -> Double {
        // Usamos la caché, así que este cálculo es inmediato
        let logs = loadLogs(for: exerciseName)
        return logs.map { $0.weight }.max() ?? 0.0
    }
    
    // --- ESCRITURA (Segura y en Segundo Plano) ---
    func saveLog(exerciseName: String, weight: Double, reps: Int, note: String = "") {
        let newLog = ExerciseLog(date: Date(), weight: weight, reps: reps, note: note)
        
        // 1. Actualizamos la caché YA para que el usuario lo vea al instante
        var currentLogs = cache[exerciseName] ?? loadFromDisk(for: exerciseName)
        currentLogs.insert(newLog, at: 0)
        cache[exerciseName] = currentLogs
        
        // 2. Guardamos en disco en segundo plano (Invisible para el usuario)
        saveQueue.async { [weak self] in
            self?.saveToDisk(logs: currentLogs, for: exerciseName)
        }
    }
    
    func deleteLog(at offsets: IndexSet, exerciseName: String, currentLogs: inout [ExerciseLog]) {
        // Borramos de la lista visual
        for index in offsets.sorted(by: >) {
            if currentLogs.indices.contains(index) {
                currentLogs.remove(at: index)
            }
        }
        
        // Actualizamos caché
        let updatedLogs = currentLogs
        cache[exerciseName] = updatedLogs
        
        // Guardamos en disco en segundo plano
        saveQueue.async { [weak self] in
            self?.saveToDisk(logs: updatedLogs, for: exerciseName)
        }
    }
    
    // --- PRIVADO ---
    private func loadFromDisk(for exerciseName: String) -> [ExerciseLog] {
        if let data = UserDefaults.standard.data(forKey: "history_\(exerciseName)"),
           let logs = try? JSONDecoder().decode([ExerciseLog].self, from: data) {
            return logs
        }
        return []
    }
    
    private func saveToDisk(logs: [ExerciseLog], for exerciseName: String) {
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: "history_\(exerciseName)")
        }
    }
}
