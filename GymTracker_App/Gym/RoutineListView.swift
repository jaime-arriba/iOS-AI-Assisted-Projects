import SwiftUI

struct RoutineListView: View {
    let routine: Routine
    
    var body: some View {
        List(routine.exercises) { exercise in
            // OPTIMIZACIÓN: Pasamos 'allExercises' para que los botones Siguiente/Anterior funcionen
            NavigationLink(destination: ExerciseDetailView(exercise: exercise, allExercises: routine.exercises)) {
                HStack(spacing: 15) {
                    // Miniatura
                    Image(exercise.mainImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        // Placeholder eficiente
                        .overlay {
                            if UIImage(named: exercise.mainImageName) == nil {
                                Image(systemName: "photo")
                                    .foregroundStyle(.gray)
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .lineLimit(1)
                        HStack {
                            Text(exercise.sets)
                            Text("•")
                            Text(exercise.reps)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(routine.title)
    }
}
