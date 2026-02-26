import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Cabecera (Se mantiene igual)
                VStack(alignment: .leading) {
                    Text("Gym Tracker")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                    Text("Mis Rutinas")
                        .font(.largeTitle)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView {
                    // OPTIMIZACIÓN: LazyVStack carga solo lo que ves en pantalla
                    LazyVStack(spacing: 16) {
                        ForEach(appRoutines) { routine in
                            NavigationLink(destination: RoutineListView(routine: routine)) {
                                RoutineCard(routine: routine)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct RoutineCard: View {
    let routine: Routine
    
    // Función auxiliar para color
    var cardColor: Color {
        switch routine.color {
        case "Blue": return .blue
        case "Purple": return .purple
        case "Orange": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(routine.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                
                Text(routine.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                
                HStack {
                    Image(systemName: "dumbbell.fill")
                    Text("\(routine.exercises.count) ejercicios")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 4)
            }
            
            Spacer()
            
            Image(systemName: routine.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(20)
        .background(
            LinearGradient(colors: [cardColor, cardColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        // OPTIMIZACIÓN: Renderiza la tarjeta como una capa única antes de la sombra (Ahorra GPU)
        .compositingGroup()
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
