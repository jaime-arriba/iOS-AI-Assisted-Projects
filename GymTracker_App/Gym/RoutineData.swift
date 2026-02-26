import Foundation

// 1. Estructura del Ejercicio (Optimizada con Hashable y Sendable)
// Hashable: Permite a SwiftUI detectar cambios más rápido.
// Sendable: Permite pasar estos datos entre hilos sin riesgo (vital para el HistoryManager).
struct Exercise: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let name: String
    let sets: String
    let reps: String
    let notes: String
    let mainImageName: String
    let alternativeName: String?
    let alternativeImageName: String?
    
    // Inicializador personalizado para flexibilidad
    init(id: UUID = UUID(), name: String, sets: String, reps: String, notes: String, mainImageName: String, alternativeName: String? = nil, alternativeImageName: String? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.notes = notes
        self.mainImageName = mainImageName
        self.alternativeName = alternativeName
        self.alternativeImageName = alternativeImageName
    }
}

// 2. Estructura de la Rutina (Optimizada)
struct Routine: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageName: String
    let color: String
    let exercises: [Exercise]
    
    init(id: UUID = UUID(), title: String, subtitle: String, imageName: String, color: String, exercises: [Exercise]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.color = color
        self.exercises = exercises
    }
}

// --- DATOS DE LAS RUTINAS (Global Constants - Acceso O(1)) ---

// A. RUTINA ESPALDA Y BÍCEPS
let backBicepsExercises: [Exercise] = [
    Exercise(
        name: "1. Jalón al pecho",
        sets: "4 series", reps: "10-12 reps",
        notes: "Agarre neutro. Mantén una buena técnica para estimular los dorsales.",
        mainImageName: "jalon_pecho"
    ),
    Exercise(
        name: "2. Remo en T",
        sets: "3 series", reps: "8-10 reps",
        notes: "Pesadas y controladas. Estimula espalda superior.",
        mainImageName: "remo_t",
        alternativeName: "Remo sentado (agarre abierto)", alternativeImageName: "remo_t_alt"
    ),
    Exercise(
        name: "3. Pull over",
        sets: "2 series", reps: "Dropset",
        notes: "Para terminar el entrenamiento con un último estímulo al dorsal.",
        mainImageName: "pullover"
    ),
    Exercise(
        name: "4. Vuelos posteriores",
        sets: "3 series", reps: "10-12 reps",
        notes: "Enfocado en el deltoides posterior. Recomendable en máquina.",
        mainImageName: "vuelos_posteriores_maq",
        alternativeName: "Tirón a la cara (Facepull)", alternativeImageName: "vuelos_posteriores_polea"
    ),
    Exercise(
        name: "5. Remo cerrado",
        sets: "2 series", reps: "10 reps aprox",
        notes: "El Remo sentado por excelencia para el dorsal.",
        mainImageName: "remo_cerrado",
        alternativeName: "Remo con mancuernas", alternativeImageName: "remo_cerrado_alt"
    ),
    Exercise(
        name: "6. Curl predicador",
        sets: "2 series", reps: "10 reps aprox",
        notes: "Trabajaremos la cabeza corta del bíceps.",
        mainImageName: "curl_predicador",
        alternativeName: "Curl araña", alternativeImageName: "curl_arana"
    ),
    Exercise(
        name: "7. Curl martillo",
        sets: "2 series", reps: "10 reps aprox",
        notes: "Peso exigente. Trabajaremos el Bíceps y el braquial.",
        mainImageName: "curl_martillo"
    ),
    Exercise(
        name: "8. Curl bayesian",
        sets: "2 series", reps: "10 reps aprox",
        notes: "Trabajaremos la cabeza larga del bíceps.",
        mainImageName: "curl_bayesian",
        alternativeName: "Curl banco inclinado", alternativeImageName: "curl_inclinado"
    )
]

// B. RUTINA PECHO, HOMBRO Y TRÍCEPS
let chestTricepsExercises: [Exercise] = [
    Exercise(
        name: "1. Press inclinado",
        sets: "3 series", reps: "10-12 reps",
        notes: "Enfoque zona superior. Mancuernas, multipower o máquina.",
        mainImageName: "press_inclinado"
    ),
    Exercise(
        name: "2. Press plano",
        sets: "3 series", reps: "6-8 reps",
        notes: "Estimula todo el pectoral. Banca, máquina o mancuernas.",
        mainImageName: "press_plano"
    ),
    Exercise(
        name: "3. Elevaciones frontales",
        sets: "3 series", reps: "8 reps",
        notes: "O Press Militar. Enfocado en deltoides anterior.",
        mainImageName: "elevaciones_frontales"
    ),
    Exercise(
        name: "4. Aperturas",
        sets: "3 series", reps: "10-12 reps",
        notes: "Ejercicio analítico. Aprieta bien y siente el estímulo.",
        mainImageName: "aperturas"
    ),
    Exercise(
        name: "5. Press francés",
        sets: "4 series", reps: "10-12 reps",
        notes: "Con barra o mancuernas. Mantén buena técnica.",
        mainImageName: "press_frances"
    ),
    Exercise(
        name: "6. Extensiones en polea",
        sets: "3 series", reps: "10-12 reps",
        notes: "Con barra o cuerda. Última serie dropset opcional.",
        mainImageName: "extensiones_polea"
    ),
    Exercise(
        name: "7. Elevaciones laterales",
        sets: "4 series", reps: "12 reps",
        notes: "Preferible en polea, pero puedes usar mancuernas.",
        mainImageName: "elevaciones_laterales"
    )
]

// C. RUTINA PIERNA
let legExercises: [Exercise] = [
    Exercise(
        name: "1. Sentadilla",
        sets: "3 series", reps: "10 reps",
        notes: "Después de calentar. Mantén buena técnica.",
        mainImageName: "sentadilla",
        alternativeName: "Prensa o Hack", alternativeImageName: "sentadilla_alt"
    ),
    Exercise(
        name: "2. Peso muerto",
        sets: "2 series efectivas", reps: "Aproximación previa",
        notes: "Céntrate en llevar los glúteos atrás.",
        mainImageName: "peso_muerto",
        alternativeName: "Peso muerto con barra", alternativeImageName: "peso_muerto_barra"
    ),
    Exercise(
        name: "3. Hip thrust",
        sets: "3 series", reps: "8-10 reps",
        notes: "Muy importante para glúteos. Barra o máquina.",
        mainImageName: "hip_thrust"
    ),
    Exercise(
        name: "4. Extensiones Cuádriceps",
        sets: "3 series", reps: "10-12 reps",
        notes: "Haz el recorrido completo y aprieta.",
        mainImageName: "extensiones_cuadriceps"
    ),
    Exercise(
        name: "5. Curl de isquiotibiales",
        sets: "3 series", reps: "10-12 reps",
        notes: "Controla la fase excéntrica.",
        mainImageName: "curl_femoral",
        alternativeName: "Curl femoral sentado", alternativeImageName: "curl_femoral_sentado"
    )
]

// LISTA MAESTRA
let appRoutines: [Routine] = [
    Routine(title: "Espalda y Bíceps", subtitle: "Tracción y Brazos", imageName: "figure.strengthtraining.traditional", color: "Blue", exercises: backBicepsExercises),
    Routine(title: "Pecho, Hombro, Tríceps", subtitle: "Empuje Completo", imageName: "figure.core.training", color: "Purple", exercises: chestTricepsExercises),
    Routine(title: "Día de Pierna", subtitle: "Cuádriceps, Femoral y Glúteo", imageName: "figure.run", color: "Orange", exercises: legExercises)
]
