import SwiftUI
import SwiftData

struct RoutineDetailView: View {
    @Bindable var routine: WorkoutRoutine
    @Environment(\.modelContext) var modelContext
    @State private var workoutManager = WorkoutManager()
    @State private var showAddExercise = false
    @State private var newExerciseName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(routine.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                    Section(header: Text(exercise.name).font(.title3).bold()) {
                        ForEach(exercise.sets) { set in
                            HStack {
                                Text("Set \(getSetNumber(exercise: exercise, set: set))")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50, alignment: .leading)
                                
                                TextField("kg", value: Bindable(set).weight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 70)
                                
                                Text("kg  x")
                                
                                TextField("reps", value: Bindable(set).reps, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)
                                
                                Spacer()
                                
                                Button(action: {
                                    toggleSet(set)
                                }) {
                                    Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(set.isCompleted ? .green : .gray)
                                }
                                .buttonStyle(.plain) // Para que no active toda la celda
                            }
                        }
                        .onDelete { indexSet in
                             deleteSet(at: indexSet, from: exercise)
                        }
                        
                        Button("Añadir Serie") {
                            addSet(to: exercise)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // Temporizador Flotante
            if workoutManager.isTimerRunning {
                HStack {
                    Image(systemName: "timer")
                    Text("Descanso: \(workoutManager.formatTime(workoutManager.timeRemaining))")
                        .monospacedDigit()
                    Spacer()
                    Button("Saltar") { workoutManager.stopTimer() }
                        .foregroundStyle(.red)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding()
                .shadow(radius: 5)
            }
        }
        .navigationTitle(routine.name)
        .toolbar {
            Button("Nuevo Ejercicio") { showAddExercise = true }
        }
        .alert("Añadir Ejercicio", isPresented: $showAddExercise) {
            TextField("Nombre (ej: Press Banca)", text: $newExerciseName)
            Button("Añadir") { addExercise() }
            Button("Cancelar", role: .cancel) {}
        }
    }
    
    // Lógica interna de la vista
    func addExercise() {
        let order = routine.exercises.count
        let newEx = WorkoutExercise(name: newExerciseName, orderIndex: order)
        routine.exercises.append(newEx)
        newExerciseName = ""
    }
    
    func addSet(to exercise: WorkoutExercise) {
        // Copiar datos del set anterior si existe (Auto-fill)
        let lastWeight = exercise.sets.last?.weight ?? 0
        let lastReps = exercise.sets.last?.reps ?? 0
        let newSet = ExerciseSet(weight: lastWeight, reps: lastReps)
        exercise.sets.append(newSet)
    }
    
    func deleteSet(at offsets: IndexSet, from exercise: WorkoutExercise) {
        exercise.sets.remove(atOffsets: offsets)
    }
    
    func toggleSet(_ set: ExerciseSet) {
        withAnimation {
            set.isCompleted.toggle()
            if set.isCompleted {
                workoutManager.startRestTimer(seconds: 90) // 90 segundos de descanso
            }
        }
    }
    
    func getSetNumber(exercise: WorkoutExercise, set: ExerciseSet) -> Int {
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            return index + 1
        }
        return 0
    }
}
