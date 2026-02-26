import Foundation
import SwiftData

// 1. La Rutina
@Model
final class WorkoutRoutine {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.exercises = []
    }
}

// 2. El Ejercicio
@Model
final class WorkoutExercise {
    var name: String
    var orderIndex: Int
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet]
    var routine: WorkoutRoutine? // Relación inversa opcional
    
    init(name: String, orderIndex: Int) {
        self.name = name
        self.orderIndex = orderIndex
        self.sets = []
    }
}

// 3. La Serie (Set)
@Model
final class ExerciseSet {
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var date: Date
    var exercise: WorkoutExercise? // Relación inversa opcional
    
    init(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
        self.date = Date()
    }
}
