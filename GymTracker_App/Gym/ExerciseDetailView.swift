import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    let allExercises: [Exercise]
    
    // CONTROL DE ESTADO
    @State private var navExercise: Exercise?
    @Environment(\.dismiss) var dismiss
    
    // CALCULADOS (Eficientes)
    var currentExercise: Exercise { navExercise ?? exercise }
    
    var currentIndex: Int {
        allExercises.firstIndex(where: { $0.id == currentExercise.id }) ?? 0
    }
    
    var previousExercise: Exercise? {
        if currentIndex > 0 { return allExercises[currentIndex - 1] }
        return nil
    }
    
    var nextExercise: Exercise? {
        if currentIndex < allExercises.count - 1 { return allExercises[currentIndex + 1] }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- CABECERA ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentExercise.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.primary)
                            // Optimización: Animación suave al cambiar texto
                            .transaction { transaction in transaction.animation = nil }
                        
                        HStack {
                            Label(currentExercise.sets, systemImage: "number.square.fill")
                            Spacer()
                            Label(currentExercise.reps, systemImage: "repeat.circle.fill")
                        }
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 5)
                    }
                    .padding(.horizontal)
                    
                    // --- IMAGEN ---
                    Image(currentExercise.mainImageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .overlay {
                            if UIImage(named: currentExercise.mainImageName) == nil {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2))
                                    Text("Imagen no encontrada:\n\(currentExercise.mainImageName)")
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.red)
                                }
                                .padding(.horizontal)
                            }
                        }

                    // --- NOTAS ---
                    VStack(alignment: .leading) {
                        Label("TIPS & NOTAS", systemImage: "lightbulb.fill")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.orange)
                        
                        Text(currentExercise.notes)
                            .font(.body)
                            .padding(.top, 2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // --- ALTERNATIVA ---
                    if let altName = currentExercise.alternativeName {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("ALTERNATIVA", systemImage: "arrow.triangle.swap")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.blue)
                            Text(altName).font(.headline)
                            if let altImage = currentExercise.alternativeImageName {
                                Image(altImage).resizable().scaledToFit().cornerRadius(8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Divider().padding(.vertical)
                    
                    // --- LOGGER (Historial) ---
                    ExerciseLoggerView(exerciseName: currentExercise.name)
                    
                }
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
            .id(currentExercise.id) // Fuerza el refresco limpio al cambiar ejercicio
            
            // --- BARRA INFERIOR ---
            VStack {
                Divider()
                HStack {
                    // BOTÓN ANTERIOR
                    if let prev = previousExercise {
                        Button(action: {
                            // Optimización: Curva de animación estándar de iOS
                            withAnimation(.easeInOut(duration: 0.3)) {
                                navExercise = prev
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Anterior")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .foregroundStyle(.primary)
                    } else {
                        Spacer().frame(maxWidth: .infinity)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // BOTÓN SIGUIENTE
                    if let next = nextExercise {
                        Button(action: {
                            // Optimización: Curva de animación estándar de iOS
                            withAnimation(.easeInOut(duration: 0.3)) {
                                navExercise = next
                            }
                        }) {
                            HStack {
                                Text("Siguiente")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                    } else {
                        Text("Fin de Rutina")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(.regularMaterial)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .padding(.leading, 8)
            }
        }
    }
}
