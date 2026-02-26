import SwiftUI
import SwiftData

@main
struct Gym: App { // El nombre 'GymApp' puede variar según cómo llamaste al proyecto
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkoutRoutine.self) // ¡ESTO ES CLAVE!
    }
}
