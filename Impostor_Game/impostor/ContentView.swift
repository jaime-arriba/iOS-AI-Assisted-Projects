import SwiftUI
import Combine
import UIKit

// =========================================================
// MARK: - 1. SISTEMA DE DISEÑO (NEON - TAMAÑO AJUSTADO/STANDARD)
// =========================================================

struct AppTheme {
    // Fondos Oscuros (Deep OLED)
    static let bgDark = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let cardDark = Color(red: 0.10, green: 0.10, blue: 0.13)
    // Compatibilidad
    static let cardGrey = cardDark
    
    // Colores Neón Vibrantes
    static let neonBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let neonRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let neonGreen = Color(red: 0.2, green: 0.9, blue: 0.5)
    static let neonPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    static let neonGold = Color(red: 1.0, green: 0.8, blue: 0.2)
    
    // Fuentes Ajustadas (Más equilibradas, no tan grandes)
    static func fontTitle() -> Font { .system(size: 28, weight: .black, design: .rounded) } // Antes 36
    static func fontHeader() -> Font { .system(size: 20, weight: .bold, design: .rounded) } // Antes 22
    static func fontSubHeader() -> Font { .system(size: 16, weight: .semibold, design: .rounded) } // Antes 18
}

// =========================================================
// MARK: - 2. COMPONENTES UI
// =========================================================

struct NeonCard<Content: View>: View {
    let color: Color
    let content: Content
    
    init(color: Color = .gray, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        content
            .background(AppTheme.cardDark)
            .cornerRadius(18) // Radio un poco más sutil
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(color.opacity(0.8), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 0)
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        content
            .background(AppTheme.cardGrey)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

struct CircleBtn: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.subheadline) // Icono más pequeño
                .foregroundColor(.black)
                .frame(width: 28, height: 28) // Antes 32
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.6), radius: 4)
        }
    }
}

struct MainButton: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            Text(text)
                .font(.headline).bold().tracking(1) // Antes .title3 (más pequeño)
                .foregroundColor(.black)
                .padding(.vertical, 14) // Padding vertical controlado
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(20)
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
        }
    }
}

// =========================================================
// MARK: - 3. MODELO DE DATOS
// =========================================================

struct Player: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var role: String = "Ciudadano"
}

struct WordPack: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String
    var colorData: [CGFloat]
    var words: [String]
    var isSelected: Bool = false
    var isGenerated: Bool = false
    var isAdult: Bool = false
    
    var color: Color { Color(red: colorData[0], green: colorData[1], blue: colorData[2]) }
    
    static let availableIcons = [
        "shuffle", "person.2.fill", "globe.europe.africa.fill", "building.2.fill", "car.fill",
        "pawprint.fill", "fork.knife", "airplane", "sportscourt.fill", "lightbulb.fill",
        "gamecontroller.fill", "film.fill", "cart.fill", "briefcase.fill", "music.note",
        "star.fill", "heart.fill", "bolt.fill", "flame.fill", "snowflake",
        "leaf.fill", "flag.fill", "map.fill", "gift.fill", "mustache.fill",
        "house.fill", "banknote.fill", "laptopcomputer", "tv.fill", "figure.run",
        "exclamationmark.triangle.fill", "mouth.fill", "bed.double.fill"
    ]
    
    init(id: UUID = UUID(), name: String, icon: String, color: Color, words: [String], isSelected: Bool = false, isGenerated: Bool = false, isAdult: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        if let components = UIColor(color).cgColor.components, components.count >= 3 {
            self.colorData = [components[0], components[1], components[2]]
        } else { self.colorData = [0.5, 0.5, 0.5] }
        self.words = words
        self.isSelected = isSelected
        self.isGenerated = isGenerated
        self.isAdult = isAdult
    }
}

// =========================================================
// MARK: - 4. MOTOR DEL JUEGO (PERSISTENCIA BLINDADA)
// =========================================================

class GameEngine: ObservableObject {
    @Published var packs: [WordPack] = []
    @Published var players: [Player] = []
    
    // Configuración
    @Published var impostors: Int = 1
    @Published var hintEnabled: Bool = true
    @Published var mrWhiteEnabled: Bool = false
    @Published var isTimerEnabled: Bool = false
    @Published var debateDuration: Double = 3.0
    @Published var hapticsEnabled: Bool = true
    
    @Published var gameState: GameState = .splash
    @Published var currentSecretWord: String = ""
    @Published var currentCategory: String = ""
    @Published var currentPlayerIndex: Int = 0
    @Published var startingPlayerName: String = ""
    
    // CLAVES NUEVAS (V42) PARA LIMPIEZA
    private let saveKeyPacks = "v42_packs_data"
    private let saveKeyPlayers = "v42_players_data"
    private let saveKeyConfig = "v42_config_data"
    
    init() { loadState() }
    
    // --- GESTIÓN DE DATOS ---
    
    func addPlayer(name: String) {
        let clean = name.trimmingCharacters(in: .whitespaces)
        if !clean.isEmpty {
            players.append(Player(name: clean))
            saveState() // Guardar Inmediato
            updateDynamicPacks()
        }
    }
    
    func removePlayer(id: UUID) {
        players.removeAll { $0.id == id }
        saveState() // Guardar Inmediato
        updateDynamicPacks()
    }
    
    func removeAllPlayers() {
        players.removeAll()
        saveState()
        updateDynamicPacks()
    }
    
    // **FUNCIÓN CRÍTICA PARA QUE SE GUARDE LA SELECCIÓN**
    func togglePackSelection(id: UUID) {
        if let index = packs.firstIndex(where: { $0.id == id }) {
            packs[index].isSelected.toggle()
            saveState() // Guardar Inmediato tras seleccionar
        }
    }
    
    func createNewPack() {
        let newPack = WordPack(name: "Nuevo Mazo", icon: "pencil", color: .purple, words: ["Palabra 1", "Palabra 2"])
        let insertIndex = packs.lastIndex(where: { $0.isGenerated }) ?? -1
        packs.insert(newPack, at: insertIndex + 1)
        saveState() // Guardar Inmediato
    }
    
    func updatePack(_ updatedPack: WordPack) {
        if let index = packs.firstIndex(where: { $0.id == updatedPack.id }) {
            packs[index] = updatedPack
            saveState() // Guardar Inmediato
            updateDynamicPacks()
        }
    }
    
    func deletePack(id: UUID) {
        packs.removeAll { $0.id == id }
        saveState() // Guardar Inmediato
        updateDynamicPacks()
    }
    
    func resetPacksToDefaults() {
        self.packs = getDefaultPacks()
        saveState()
        updateDynamicPacks()
    }
    
    // --- IMPORT / EXPORT ---
    func exportPack(_ pack: WordPack) -> String {
        if let data = try? JSONEncoder().encode(pack), let str = String(data: data, encoding: .utf8) { return str }
        return ""
    }
    
    func importPack(from json: String) -> Bool {
        guard let data = json.data(using: .utf8), var pack = try? JSONDecoder().decode(WordPack.self, from: data) else { return false }
        pack.id = UUID(); pack.isGenerated = false; pack.isSelected = false
        let insertIndex = packs.lastIndex(where: { $0.isGenerated }) ?? -1
        packs.insert(pack, at: insertIndex + 1)
        saveState() // Guardar tras importar
        return true
    }
    
    // --- Lógica Dinámica ---
    func updateDynamicPacks() {
        // Guardamos selección de los dinámicos
        let wasPlayersSelected = packs.first(where: { $0.name == "👥 JUGADORES" })?.isSelected ?? false
        let wasAdultSelected = packs.first(where: { $0.name == "🔞 ALEATORIO +18" })?.isSelected ?? false
        let wasCleanSelected = packs.first(where: { $0.name == "🔀 ALEATORIO (Soft)" })?.isSelected ?? false
        
        // Quitamos los generados viejos
        var currentPacks = packs.filter { !$0.isGenerated }
        
        // Creamos nuevos
        if players.count >= 3 {
            let names = players.map { $0.name }
            let playersPack = WordPack(name: "👥 JUGADORES", icon: "person.2.fill", color: .pink, words: names, isSelected: wasPlayersSelected, isGenerated: true)
            currentPacks.insert(playersPack, at: 0)
        }
        
        let adultWords = currentPacks.filter { $0.isAdult }.flatMap { $0.words }.shuffled()
        let randomAdult = WordPack(name: "🔞 ALEATORIO +18", icon: "exclamationmark.triangle.fill", color: AppTheme.neonRed, words: adultWords.isEmpty ? ["Vacío"] : adultWords, isSelected: wasAdultSelected, isGenerated: true, isAdult: true)
        currentPacks.insert(randomAdult, at: 0)
        
        let cleanWords = currentPacks.filter { !$0.isAdult }.flatMap { $0.words }.shuffled()
        let randomClean = WordPack(name: "🔀 ALEATORIO (Soft)", icon: "shuffle", color: AppTheme.neonGreen, words: cleanWords.isEmpty ? ["Vacío"] : cleanWords, isSelected: wasCleanSelected, isGenerated: true, isAdult: false)
        currentPacks.insert(randomClean, at: 0)
        
        // Actualizamos UI
        self.packs = currentPacks
    }
    
    // --- PERSISTENCIA (EL NÚCLEO DEL ARREGLO) ---
    func loadState() {
        // Cargar Jugadores
        if let data = UserDefaults.standard.data(forKey: saveKeyPlayers), let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            self.players = decoded
        }
        
        // Cargar Config
        if let config = UserDefaults.standard.dictionary(forKey: saveKeyConfig) {
            if let t = config["isTimerEnabled"] as? Bool { self.isTimerEnabled = t }
            if let d = config["debateDuration"] as? Double { self.debateDuration = d }
            if let h = config["hintEnabled"] as? Bool { self.hintEnabled = h }
            if let w = config["mrWhiteEnabled"] as? Bool { self.mrWhiteEnabled = w }
            if let hap = config["hapticsEnabled"] as? Bool { self.hapticsEnabled = hap }
        }
        
        // Cargar Packs
        var loadedPacks: [WordPack] = []
        if let data = UserDefaults.standard.data(forKey: saveKeyPacks), let decoded = try? JSONDecoder().decode([WordPack].self, from: data) {
            loadedPacks = decoded
        }
        
        if loadedPacks.isEmpty {
            loadedPacks = getDefaultPacks()
        }
        
        self.packs = loadedPacks
        updateDynamicPacks()
    }
    
    func saveState() {
        // GUARDADO SÍNCRONO EN EL HILO PRINCIPAL
        // Esto congela la UI 1ms pero asegura que se escribe en disco SIEMPRE.
        let packsToSave = self.packs.filter { !$0.isGenerated }
        let playersToSave = self.players
        let configToSave: [String: Any] = [
            "isTimerEnabled": self.isTimerEnabled,
            "debateDuration": self.debateDuration,
            "hintEnabled": self.hintEnabled,
            "mrWhiteEnabled": self.mrWhiteEnabled,
            "hapticsEnabled": self.hapticsEnabled
        ]
        
        if let encPacks = try? JSONEncoder().encode(packsToSave) {
            UserDefaults.standard.set(encPacks, forKey: self.saveKeyPacks)
        }
        if let encPlayers = try? JSONEncoder().encode(playersToSave) {
            UserDefaults.standard.set(encPlayers, forKey: self.saveKeyPlayers)
        }
        UserDefaults.standard.set(configToSave, forKey: self.saveKeyConfig)
        
        // Forzar escritura inmediata (Legacy but safe)
        UserDefaults.standard.synchronize()
    }
    
    func getDefaultPacks() -> [WordPack] {
        return [
            WordPack(name: "🌍 Países", icon: "globe.europe.africa.fill", color: .blue, words: ["España", "Francia", "Italia", "Japón", "Brasil", "Egipto", "Estados Unidos", "China", "Rusia", "México", "Argentina", "Alemania", "Australia", "India", "Canadá", "Reino Unido"]),
            WordPack(name: "🏙️ Ciudades", icon: "building.2.fill", color: .cyan, words: ["Madrid", "Barcelona", "Nueva York", "Tokio", "París", "Londres", "Roma", "Dubái", "Los Ángeles", "Berlín", "Ámsterdam", "Venecia", "Sídney", "Río de Janeiro"]),
            WordPack(name: "✈️ Transporte", icon: "car.fill", color: .gray, words: ["Avión", "Helicóptero", "Submarino", "Globo Aerostático", "Patinete Eléctrico", "Tuk-tuk", "Tranvía", "Teleférico", "Yate", "Cohete", "Trineo", "Carruaje"]),
            WordPack(name: "🇪🇸 Youtubers", icon: "laptopcomputer", color: .purple, words: ["Ibai", "AuronPlay", "Rubius", "TheGrefg", "IlloJuan", "DJMaRiiO", "Jordi Wild", "Xokas", "Vegetta777", "Willyrex", "Cristinini", "Masi", "YoSoyPlex", "Nil Ojeda"]),
            WordPack(name: "🏆 Deportistas", icon: "figure.run", color: .orange, words: ["Rafa Nadal", "Fernando Alonso", "Carlos Sainz", "Carlos Alcaraz", "Pau Gasol", "Iker Casillas", "Andrés Iniesta", "Marc Márquez", "Sergio Ramos", "Alexia Putellas", "Cristiano Ronaldo", "Leo Messi"]),
            WordPack(name: "🎵 Música", icon: "music.note", color: .pink, words: ["Rosalía", "Quevedo", "Bad Bunny", "Shakira", "C. Tangana", "Aitana", "Karol G", "Bizarrap", "Taylor Swift", "Duki", "Rauw Alejandro", "Estopa"]),
            WordPack(name: "🦸 Superhéroes", icon: "bolt.fill", color: .indigo, words: ["Spider-Man", "Batman", "Iron Man", "Superman", "Wonder Woman", "Thor", "Hulk", "Capitán América", "Deadpool", "Wolverine", "Joker", "Thanos"]),
            WordPack(name: "Animales", icon: "pawprint.fill", color: .green, words: ["Ornitorrinco", "Narval", "Perezoso", "León", "Elefante", "Tiburón", "Mosquito", "Cucaracha", "Medusa", "Panda", "Tiranosaurio", "Unicornio"]),
            WordPack(name: "Comida", icon: "fork.knife", color: .red, words: ["Pizza con Piña", "Sushi", "Callos", "Brócoli", "Kebab", "Tofu", "Caviar", "Saltamontes", "Croqueta", "Churros", "Gazpacho", "Wasabi"]),
            WordPack(name: "🔥 Picante", icon: "flame.fill", color: .red, words: ["Tinder", "Striptease", "Kamasutra", "Gatillazo", "Trío", "Fetiche", "Sado", "Voyeur", "Orgasmo", "Afrodisíaco", "Lencería", "Desnudo"], isAdult: true),
            WordPack(name: "😈 Tabú", icon: "exclamationmark.triangle.fill", color: .purple, words: ["Drogas", "Alcohol", "Resaca", "Vómito", "Calabozo", "Infidelidad", "Cuernos", "Prostitución", "Soborno", "Contrabando", "Apuestas"], isAdult: true)
        ]
    }
    
    func startGame() -> String? {
        if players.count < 3 { return "Mínimo 3 jugadores." }
        let activePacks = packs.filter { $0.isSelected }
        if activePacks.isEmpty { return "Elige al menos un paquete." }
        let combinedWords = activePacks.flatMap { $0.words }
        if combinedWords.isEmpty { return "Los paquetes seleccionados están vacíos." }
        guard let randomWord = combinedWords.randomElement() else { return "Error interno." }
        currentSecretWord = randomWord
        if let originPack = packs.first(where: { !$0.isGenerated && $0.words.contains(randomWord) }) {
            currentCategory = originPack.name
        } else { currentCategory = activePacks.first?.name ?? "General" }
        let specialCount = impostors + (mrWhiteEnabled ? 1 : 0)
        if specialCount >= players.count { return "Demasiados roles especiales." }
        var roles: [String] = []
        roles += Array(repeating: "Impostor", count: impostors)
        if mrWhiteEnabled { roles.append("Mr. White") }
        let citizensCount = players.count - roles.count
        roles += Array(repeating: "Ciudadano", count: citizensCount)
        roles.shuffle()
        for i in 0..<players.count { players[i].role = roles[i] }
        startingPlayerName = players.randomElement()?.name ?? "???"
        currentPlayerIndex = 0
        withAnimation(.easeInOut) { gameState = .playing }
        return nil
    }
    
    func restartGame() { DispatchQueue.main.async { _ = self.startGame() } }
    func nextTurn() { if currentPlayerIndex < players.count - 1 { withAnimation(.spring()) { currentPlayerIndex += 1 } } else { withAnimation(.easeInOut) { gameState = .finished } } }
    func reset() { withAnimation { gameState = .menu } }
    func triggerHaptic() { if hapticsEnabled { let generator = UIImpactFeedbackGenerator(style: .medium); generator.impactOccurred() } }
}

enum GameState { case splash, menu, settings, playerSetup, packSelection, playing, finished }

// =========================================================
// MARK: - 5. VISTA PRINCIPAL
// =========================================================

struct ContentView: View {
    @StateObject private var engine = GameEngine()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            AppTheme.bgDark.ignoresSafeArea()
            ZStack {
                Circle().fill(AppTheme.neonBlue.opacity(0.08)).frame(width: 300).offset(x: -120, y: -200).blur(radius: 60)
                Circle().fill(AppTheme.neonPurple.opacity(0.08)).frame(width: 300).offset(x: 120, y: 200).blur(radius: 60)
            }
            Group {
                switch engine.gameState {
                case .splash: SplashView(engine: engine).transition(.opacity)
                case .menu: HomeMenuView(engine: engine).transition(.opacity)
                case .settings: SettingsView(engine: engine).transition(.move(edge: .trailing))
                case .playerSetup: PlayerSetupView(engine: engine).transition(.move(edge: .trailing))
                case .packSelection: PackSelectionView(engine: engine).transition(.move(edge: .trailing))
                case .playing: GameCardView(engine: engine).transition(.opacity)
                case .finished: ResultView(engine: engine).transition(.opacity)
                }
            }
        }
        .preferredColorScheme(.dark)
        // Guardado extra al cerrar/minimizar
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive { engine.saveState() }
        }
        .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    }
}

// =========================================================
// MARK: - 6. SPLASH SCREEN
// =========================================================

struct SplashView: View {
    @ObservedObject var engine: GameEngine
    @State private var animate = false
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                ZStack {
                    Circle().stroke(AppTheme.neonGold, lineWidth: 3).frame(width: 100, height: 100).shadow(color: AppTheme.neonGold.opacity(0.6), radius: 15)
                    Image(systemName: "theatermasks.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 60, height: 60).foregroundColor(.white)
                }
                .scaleEffect(animate ? 1.0 : 0.85).opacity(animate ? 1 : 0)
                Text("IMPOSTOR").font(AppTheme.fontTitle()).foregroundColor(.white).tracking(6).opacity(animate ? 1 : 0).shadow(color: AppTheme.neonGold.opacity(0.3), radius: 8).padding(.top)
                Spacer()
                VStack(spacing: 5) {
                    Text("CREATED BY").font(.caption2).fontWeight(.bold).foregroundColor(AppTheme.neonGold).tracking(2)
                    Text("JAIME DE ARRIBA").font(.subheadline).fontWeight(.heavy).foregroundColor(.white).tracking(1)
                }.padding(.bottom, 40).opacity(animate ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) { animate = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { withAnimation(.easeOut(duration: 0.5)) { engine.gameState = .menu } }
        }
    }
}

// =========================================================
// MARK: - 7. MENÚ PRINCIPAL
// =========================================================

struct HomeMenuView: View {
    @ObservedObject var engine: GameEngine
    @State private var errorMsg: String?
    @State private var showError = false
    @State private var showMrWhiteHelp = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("IMPOSTOR").font(AppTheme.fontHeader()).tracking(2).foregroundColor(.white)
                Spacer()
                Button(action: { engine.triggerHaptic(); engine.gameState = .settings }) {
                    Image(systemName: "gearshape.fill").font(.headline).foregroundColor(AppTheme.cardDark).padding(6).background(AppTheme.neonGold).clipShape(Circle()).shadow(color: AppTheme.neonGold.opacity(0.5), radius: 4)
                }
            }.padding(.horizontal, 25).padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Button(action: { engine.triggerHaptic(); engine.gameState = .playerSetup }) {
                        NeonCard(color: AppTheme.neonBlue) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("JUGADORES", systemImage: "person.2.fill").font(AppTheme.fontSubHeader()).foregroundColor(AppTheme.neonBlue)
                                    Text("\(engine.players.count) activos").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(AppTheme.neonBlue).font(.body)
                            }.padding(18) // Padding reducido
                        }
                    }
                    NeonCard {
                        VStack(spacing: 0) {
                            HStack {
                                Label("Impostores", systemImage: "eye.mask.fill").font(AppTheme.fontSubHeader()).foregroundColor(.white); Spacer(); HStack(spacing: 12) {
                                    CircleBtn(icon: "minus", color: AppTheme.neonRed) { if engine.impostors > 1 { engine.impostors -= 1; engine.saveState() } }
                                    Text("\(engine.impostors)").font(.headline).bold().foregroundColor(.white).frame(width: 20)
                                    CircleBtn(icon: "plus", color: AppTheme.neonRed) { if engine.impostors < engine.players.count - 1 { engine.impostors += 1; engine.saveState() } }
                                }
                            }.padding(18)
                            Divider().background(Color.white.opacity(0.1)).padding(.horizontal)
                            HStack { Label("Mr. White", systemImage: "mustache.fill").font(AppTheme.fontSubHeader()).foregroundColor(.white); Button(action: { showMrWhiteHelp = true }) { Image(systemName: "questionmark.circle").foregroundColor(.gray).font(.caption) }; Spacer(); Toggle("", isOn: $engine.mrWhiteEnabled).tint(AppTheme.neonGold).onChange(of: engine.mrWhiteEnabled) { _ in engine.saveState() } }.padding(18)
                            Divider().background(Color.white.opacity(0.1)).padding(.horizontal)
                            VStack(spacing: 12) { HStack { Label("Cronómetro", systemImage: "timer").font(AppTheme.fontSubHeader()).foregroundColor(.white); Spacer(); Toggle("", isOn: $engine.isTimerEnabled).tint(AppTheme.neonBlue).onChange(of: engine.isTimerEnabled) { _ in engine.saveState() } }; if engine.isTimerEnabled { HStack { Text("\(Int(engine.debateDuration)) min").font(.caption).bold().foregroundColor(AppTheme.neonBlue); Slider(value: $engine.debateDuration, in: 1...10, step: 1).accentColor(AppTheme.neonBlue).onChange(of: engine.debateDuration) { _ in engine.saveState() } } } }.padding(18)
                            Divider().background(Color.white.opacity(0.1)).padding(.horizontal)
                            HStack { Label("Pista Impostor", systemImage: "lightbulb.fill").font(AppTheme.fontSubHeader()).foregroundColor(.white); Spacer(); Toggle("", isOn: $engine.hintEnabled).tint(AppTheme.neonGreen).onChange(of: engine.hintEnabled) { _ in engine.saveState() } }.padding(18)
                        }
                    }
                    Button(action: { engine.triggerHaptic(); engine.gameState = .packSelection }) {
                        NeonCard(color: AppTheme.neonPurple) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label("PAQUETES", systemImage: "square.stack.3d.up.fill").font(AppTheme.fontSubHeader()).foregroundColor(AppTheme.neonPurple)
                                    Text("\(engine.packs.filter{$0.isSelected}.count) seleccionados").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(AppTheme.neonPurple).font(.body)
                            }.padding(18)
                        }
                    }
                }.padding(.horizontal, 20)
            }
            Spacer()
            MainButton(text: "JUGAR", color: AppTheme.neonGreen) { if let error = engine.startGame() { errorMsg = error; showError = true } }.padding(.horizontal, 40).padding(.bottom, 10)
        }
        .alert("¿Qué es Mr. White?", isPresented: $showMrWhiteHelp) { Button("Entendido", role: .cancel) { } } message: { Text("Es un impostor que NO sabe la palabra secreta. Gana si consigue adivinarla al final de la partida.") }
        .alert("Atención", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text(errorMsg ?? "") }
    }
}

// =========================================================
// MARK: - 7.5 AJUSTES DE APP
// =========================================================

struct SettingsView: View {
    @ObservedObject var engine: GameEngine
    @State private var showDeleteAlert = false
    @State private var showResetAlert = false
    var body: some View {
        VStack {
            HStack { Button(action: { engine.gameState = .menu }) { Image(systemName: "arrow.left").font(.headline).foregroundColor(.white).padding(8).background(AppTheme.cardDark).clipShape(Circle()) }; Spacer(); Text("AJUSTES").font(AppTheme.fontHeader()).tracking(2).foregroundColor(.white); Spacer() }.padding()
            ScrollView {
                VStack(spacing: 20) {
                    NeonCard(color: AppTheme.neonGold) { HStack { Label("Vibración (Haptics)", systemImage: "iphone.radiowaves.left.and.right").font(.body).bold().foregroundColor(.white); Spacer(); Toggle("", isOn: $engine.hapticsEnabled).tint(AppTheme.neonGold).onChange(of: engine.hapticsEnabled) { _ in engine.saveState() } }.padding(18) }
                    NeonCard(color: AppTheme.neonRed) {
                        VStack(spacing: 0) {
                            Button(action: { showDeleteAlert = true }) { HStack { Text("Borrar Jugadores").font(.body).bold().foregroundColor(AppTheme.neonRed); Spacer(); Image(systemName: "trash.fill").foregroundColor(AppTheme.neonRed) }.padding(18) }
                            Divider().background(Color.white.opacity(0.1)).padding(.horizontal)
                            Button(action: { showResetAlert = true }) { HStack { Text("Resetear Paquetes").font(.body).bold().foregroundColor(AppTheme.neonRed); Spacer(); Image(systemName: "arrow.counterclockwise.circle.fill").foregroundColor(AppTheme.neonRed) }.padding(18) }
                        }
                    }
                    VStack(spacing: 8) { Image(systemName: "theatermasks.fill").font(.system(size: 32)).foregroundColor(AppTheme.neonGold); Text("Impostor v4.2").font(.caption).bold().foregroundColor(.gray); Text("Created by Jaime de Arriba").font(.subheadline).foregroundColor(.white) }.padding(.top, 20)
                }.padding()
            }
        }
        .alert("¿Borrar Jugadores?", isPresented: $showDeleteAlert) { Button("Cancelar", role: .cancel) {}; Button("Borrar Todo", role: .destructive) { engine.removeAllPlayers() } }
        .alert("¿Resetear Paquetes?", isPresented: $showResetAlert) { Button("Cancelar", role: .cancel) {}; Button("Resetear", role: .destructive) { engine.resetPacksToDefaults() } }
    }
}

// =========================================================
// MARK: - 8. SELECCIÓN PAQUETES
// =========================================================

struct PackSelectionView: View {
    @ObservedObject var engine: GameEngine
    @State private var packToEdit: WordPack?
    @State private var showImportAlert = false
    @State private var importText = ""
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { engine.gameState = .menu }) { Image(systemName: "arrow.left").font(.headline).foregroundColor(.white).padding(8).background(AppTheme.cardDark).clipShape(Circle()) }
                Spacer()
                Text("PAQUETES").font(AppTheme.fontHeader()).tracking(2).foregroundColor(.white)
                Spacer()
                Button(action: {
                    if let str = UIPasteboard.general.string { importText = str; if engine.importPack(from: str) { engine.triggerHaptic() } else { showImportAlert = true } } else { showImportAlert = true }
                }) { Image(systemName: "square.and.arrow.down").font(.headline).foregroundColor(.white).padding(8).background(AppTheme.neonBlue).clipShape(Circle()) }
                Button(action: { engine.createNewPack() }) { Image(systemName: "plus").font(.headline).foregroundColor(.black).padding(8).background(AppTheme.neonGold).clipShape(Circle()) }
            }.padding(.horizontal)
            Text("Toca para seleccionar • Mantén para editar").font(.caption).bold().foregroundColor(.gray)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(engine.packs) { pack in
                        PackCard(pack: pack)
                            .onTapGesture {
                                engine.triggerHaptic()
                                engine.togglePackSelection(id: pack.id)
                            }
                            .onLongPressGesture { if !pack.isGenerated { packToEdit = pack } }
                    }
                }.padding()
            }
            MainButton(text: "JUGAR", color: AppTheme.neonGreen) { if let error = engine.startGame() { } }.padding(.horizontal, 20).padding(.bottom, 10)
        }
        .sheet(item: $packToEdit) { pack in PackEditorView(pack: pack, engine: engine, onSave: { engine.updatePack($0) }, onDelete: { engine.deletePack(id: $0) }) }
        .alert("Importar Paquete", isPresented: $showImportAlert) {
            TextField("Pega código aquí", text: $importText)
            Button("Cancelar", role: .cancel) {}
            Button("Importar") { if engine.importPack(from: importText) { engine.triggerHaptic() } }
        } message: { Text("Pega el código del paquete que has copiado.") }
    }
}

struct PackCard: View {
    let pack: WordPack
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Image(systemName: pack.icon).font(.system(size: 32)).foregroundColor(pack.isSelected ? .white : pack.color) // Antes 42
                    .shadow(color: pack.isSelected ? .white.opacity(0.5) : pack.color.opacity(0.3), radius: 8)
                Text(pack.name.uppercased()).font(.caption).fontWeight(.black).foregroundColor(pack.isSelected ? .white : .gray).multilineTextAlignment(.center).lineLimit(1)
                if pack.isAdult { Text("+18").font(.system(size: 8, weight: .black)).padding(4).background(AppTheme.neonRed).cornerRadius(4).foregroundColor(.white) }
            }.frame(maxWidth: .infinity).frame(height: 120).background(pack.isSelected ? pack.color.opacity(0.8) : AppTheme.cardDark).cornerRadius(18).overlay(RoundedRectangle(cornerRadius: 18).stroke(pack.isSelected ? Color.white.opacity(0.6) : pack.color.opacity(0.3), lineWidth: 2)) // Altura reducida de 145 a 120
            if pack.isSelected { Image(systemName: "checkmark.circle.fill").font(.body).foregroundColor(.white).padding(10).shadow(color: .black.opacity(0.3), radius: 4) }
        }.scaleEffect(pack.isSelected ? 1.02 : 1.0).animation(.spring(), value: pack.isSelected)
    }
}

struct PackEditorView: View {
    @State var pack: WordPack
    var engine: GameEngine
    var onSave: (WordPack) -> Void
    var onDelete: (UUID) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var newWord = ""
    @State private var showExport = false
    let colors: [Color] = [.white, .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown, .gray]
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bgDark.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        NeonCard {
                            VStack(spacing: 16) {
                                TextField("Nombre", text: $pack.name).font(AppTheme.fontHeader()).multilineTextAlignment(.center).foregroundColor(.white).accentColor(AppTheme.neonGold)
                                Toggle("Contenido +18", isOn: $pack.isAdult).tint(AppTheme.neonRed).padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 12) { ForEach(colors, id: \.self) { color in Circle().fill(color).frame(width: 32, height: 32).overlay(Circle().stroke(.white, lineWidth: pack.color == color ? 3 : 0)).onTapGesture { let w = pack.words; pack = WordPack(id: pack.id, name: pack.name, icon: pack.icon, color: color, words: w, isSelected: pack.isSelected, isAdult: pack.isAdult) } } }.padding(.horizontal) }
                                ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 12) { ForEach(WordPack.availableIcons, id: \.self) { icon in Image(systemName: icon).font(.body).foregroundColor(pack.icon == icon ? pack.color : .gray).padding(10).background(pack.icon == icon ? AppTheme.cardDark : .clear).clipShape(Circle()).overlay(Circle().stroke(pack.icon == icon ? pack.color : Color.clear, lineWidth: 2)).onTapGesture { pack.icon = icon } } }.padding(.horizontal) }
                            }.padding(18)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PALABRAS (\(pack.words.count))").font(.caption).bold().foregroundColor(.gray).padding(.leading)
                            HStack { TextField("Nueva palabra...", text: $newWord).padding(12).background(AppTheme.cardDark).cornerRadius(10).foregroundColor(.white).accentColor(AppTheme.neonGold); Button(action: { if !newWord.isEmpty { pack.words.append(newWord); newWord = "" } }) { Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(AppTheme.neonGold) } }
                            ForEach(Array(pack.words.enumerated()), id: \.offset) { i, w in HStack { Text(w).font(.body).fontWeight(.medium).foregroundColor(.white); Spacer(); Button(action: { pack.words.remove(at: i) }) { Image(systemName: "trash.fill").foregroundColor(AppTheme.neonRed) } }.padding(12).background(AppTheme.cardDark).cornerRadius(10) }
                        }
                        HStack {
                            Button(action: { onDelete(pack.id); dismiss() }) { Text("ELIMINAR").font(.callout).bold().foregroundColor(AppTheme.neonRed).padding().frame(maxWidth: .infinity).background(AppTheme.neonRed.opacity(0.1)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.neonRed.opacity(0.5))) }
                            Button(action: { UIPasteboard.general.string = engine.exportPack(pack); showExport = true }) { Text("COMPARTIR").font(.callout).bold().foregroundColor(AppTheme.neonBlue).padding().frame(maxWidth: .infinity).background(AppTheme.neonBlue.opacity(0.1)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.neonBlue.opacity(0.5))) }
                        }
                    }.padding()
                }
            }
            .navigationTitle("Editar").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() }.foregroundColor(.gray) }; ToolbarItem(placement: .navigationBarTrailing) { Button("Guardar") { onSave(pack); dismiss() }.bold().foregroundColor(AppTheme.neonGold) } }
            .alert("Copiado", isPresented: $showExport) { Button("OK", role: .cancel){} } message: { Text("Código copiado al portapapeles. Mándaselo a un amigo.") }
        }.preferredColorScheme(.dark)
    }
}

// =========================================================
// MARK: - 9. JUGADORES
// =========================================================

struct PlayerSetupView: View {
    @ObservedObject var engine: GameEngine
    @State private var newName = ""
    var body: some View {
        VStack(spacing: 16) {
            HStack { Button(action: { engine.gameState = .menu }) { Image(systemName: "arrow.left").font(.headline).foregroundColor(.white).padding(8).background(AppTheme.cardDark).clipShape(Circle()) }; Spacer(); Text("JUGADORES").font(AppTheme.fontHeader()).tracking(2).foregroundColor(.white); Spacer(); Text("\(engine.players.count)").font(.headline).foregroundColor(AppTheme.neonBlue) }.padding()
            VStack(spacing: 20) {
                HStack { TextField("Nombre...", text: $newName).padding(12).background(AppTheme.cardDark).cornerRadius(12).foregroundColor(.white).accentColor(AppTheme.neonBlue).font(.body); Button(action: { engine.addPlayer(name: newName); newName = "" }) { Image(systemName: "plus").font(.headline).bold().foregroundColor(.black).frame(width: 44, height: 44).background(AppTheme.neonBlue).cornerRadius(12).shadow(color: AppTheme.neonBlue.opacity(0.4), radius: 6) }.disabled(newName.isEmpty) }.padding(.horizontal)
                ScrollView { LazyVStack(spacing: 10) { ForEach(engine.players) { p in HStack { Image(systemName: "person.fill").font(.body).foregroundColor(AppTheme.neonBlue); Text(p.name).font(.body).bold().foregroundColor(.white); Spacer(); Button(action: { engine.removePlayer(id: p.id) }) { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) } }.padding(12).background(AppTheme.cardDark).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05))) } }.padding(.horizontal) }
                MainButton(text: "SIGUIENTE", color: AppTheme.neonBlue) { engine.triggerHaptic(); engine.gameState = .packSelection }.padding(.horizontal, 20).padding(.bottom, 10)
            }
        }
    }
}

// =========================================================
// MARK: - 10. GAMEPLAY
// =========================================================

struct GameCardView: View {
    @ObservedObject var engine: GameEngine
    @State private var isFlipped = false
    @State private var rotation = 0.0
    var player: Player { engine.players[engine.currentPlayerIndex] }
    var body: some View {
        VStack {
            HStack { Text("TURNO \(engine.currentPlayerIndex + 1)/\(engine.players.count)").font(.subheadline).bold().foregroundColor(.gray); Spacer() }.padding()
            Spacer()
            Text("TURNO DE").font(.caption).bold().tracking(3).foregroundColor(AppTheme.neonGold)
            Text(player.name.uppercased()).font(AppTheme.fontTitle()).foregroundColor(.white).padding(.bottom, 20).shadow(color: AppTheme.neonGold.opacity(0.3), radius: 10)
            ZStack {
                CardBack(role: player.role, word: engine.currentSecretWord, category: engine.currentCategory, hintEnabled: engine.hintEnabled).rotation3DEffect(.degrees(rotation + 180), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 1 : 0)
                CardFront().rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 0 : 1)
            }.frame(height: 380).onTapGesture { if !isFlipped { engine.triggerHaptic(); withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { rotation += 180; isFlipped = true } } } // Altura reducida de 450 a 380
            Spacer()
            if isFlipped { MainButton(text: "OCULTAR Y PASAR", color: .white) { nextStep() }.padding(.horizontal, 40) } else { Text("Pasa el móvil a **\(player.name)**").font(.subheadline).foregroundColor(.gray).padding(.bottom, 40) }
        }
    }
    func nextStep() { withAnimation { rotation = 0; isFlipped = false }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { engine.nextTurn() } }
}

struct CardFront: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24).fill(AppTheme.cardDark)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 2))
            .shadow(color: .black.opacity(0.5), radius: 15)
            .overlay(VStack(spacing: 16) { Image(systemName: "touchid").font(.system(size: 70)).foregroundColor(.white.opacity(0.15)); Text("TOCA PARA REVELAR").font(.subheadline).bold().foregroundColor(.gray) }) // Icono reducido de 90 a 70
    }
}

struct CardBack: View {
    let role: String, word: String, category: String, hintEnabled: Bool
    var roleColor: Color { if role == "Impostor" { return AppTheme.neonRed } else if role == "Mr. White" { return .white } else { return AppTheme.neonBlue } }
    var body: some View {
        RoundedRectangle(cornerRadius: 24).fill(AppTheme.bgDark)
            .shadow(color: roleColor.opacity(0.4), radius: 20)
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(roleColor, lineWidth: 3))
            .overlay(
                VStack(spacing: 20) {
                    Image(systemName: role == "Ciudadano" ? "lock.open.fill" : "eye.slash.fill").font(.system(size: 55)).foregroundColor(roleColor).shadow(color: roleColor.opacity(0.5), radius: 8) // Icono reducido de 70 a 55
                    Text(role.uppercased()).font(AppTheme.fontTitle()).foregroundColor(roleColor).shadow(color: roleColor.opacity(0.5), radius: 8)
                    if role == "Ciudadano" { VStack(spacing: 8) { Text("Tu palabra secreta es").font(.caption).bold().foregroundColor(.gray); Text(word).font(.system(size: 30, weight: .black)).foregroundColor(.white) }.padding(16).background(AppTheme.cardDark).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(roleColor.opacity(0.3))) } // Texto reducido de 36 a 30
                    else if role == "Mr. White" { Text("No sabes la palabra.\n¡Debes adivinarla!").font(.body).multilineTextAlignment(.center).foregroundColor(.white).padding() }
                    else { VStack(spacing: 12) { Text("¡Engaña a todos!").font(.headline).bold().foregroundColor(.white); if hintEnabled { VStack { Text("PISTA").font(.caption2).fontWeight(.black); Text(category).font(.subheadline).fontWeight(.heavy) }.padding(10).background(AppTheme.bgDark).cornerRadius(10).foregroundColor(roleColor).overlay(RoundedRectangle(cornerRadius: 10).stroke(roleColor.opacity(0.5))) } } }
                }
            )
    }
}

// =========================================================
// MARK: - 11. RESULTADOS
// =========================================================

struct ResultView: View {
    @ObservedObject var engine: GameEngine
    @State private var showRoles = false
    @State private var timeRemaining: Int
    @State private var showSecretWord = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(engine: GameEngine) {
        self.engine = engine
        _timeRemaining = State(initialValue: Int(engine.debateDuration * 60))
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            if engine.isTimerEnabled {
                ZStack {
                    Circle().stroke(AppTheme.cardDark, lineWidth: 12)
                    Circle().trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(engine.debateDuration * 60)).stroke(timeRemaining < 10 ? AppTheme.neonRed : AppTheme.neonBlue, style: StrokeStyle(lineWidth: 12, lineCap: .round)).rotationEffect(.degrees(-90)).animation(.linear(duration: 1), value: timeRemaining).shadow(color: (timeRemaining < 10 ? AppTheme.neonRed : AppTheme.neonBlue).opacity(0.4), radius: 8)
                    Text(formatTime(timeRemaining)).font(.system(size: 40, weight: .black, design: .monospaced)).foregroundColor(.white) // Reducido de 50 a 40
                }.frame(width: 180, height: 180).onReceive(timer) { _ in if timeRemaining > 0 { timeRemaining -= 1 } else if timeRemaining == 0 { UINotificationFeedbackGenerator().notificationOccurred(.error); timeRemaining = -1 } }
            } else { VStack { Image(systemName: "infinity").font(.system(size: 80)).foregroundColor(AppTheme.neonGold); Text("TIEMPO ILIMITADO").font(.body).bold().foregroundColor(.gray) } }
            VStack(spacing: 5) { Text("EMPIEZA HABLANDO").font(.caption).fontWeight(.black).tracking(2).foregroundColor(.gray); Text(engine.startingPlayerName).font(.title2).fontWeight(.black).foregroundColor(AppTheme.neonGold) }
            HStack(spacing: 15) {
                Button(action: { showSecretWord.toggle() }) { VStack { Image(systemName: "eye.fill"); Text("Palabra") }.font(.subheadline).padding(10).frame(width: 120).background(AppTheme.cardDark).cornerRadius(12).foregroundColor(.white).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1))) }
                Button(action: { withAnimation { showRoles.toggle() } }) { VStack { Image(systemName: "person.3.fill"); Text("Identidades") }.font(.subheadline).padding(10).frame(width: 120).background(AppTheme.neonBlue.opacity(0.8)).cornerRadius(12).foregroundColor(.white).shadow(color: AppTheme.neonBlue.opacity(0.3), radius: 8) }
            }
            if showSecretWord { Text(engine.currentSecretWord).font(.system(size: 32, weight: .black)).foregroundColor(.white).transition(.scale) } // Reducido de 40 a 32
            if showRoles { ScrollView { VStack(spacing: 8) { ForEach(engine.players) { p in HStack { Text(p.name).font(.subheadline).bold().foregroundColor(.white); Spacer(); Text(p.role).font(.caption).fontWeight(.heavy).foregroundColor(p.role == "Impostor" ? AppTheme.neonRed : (p.role == "Mr. White" ? .white : AppTheme.neonGreen)) }.padding(10).background(AppTheme.cardDark).cornerRadius(10) } } }.frame(height: 120) }
            Spacer()
            HStack(spacing: 15) {
                Button(action: { engine.reset() }) { Text("Menú").font(.headline).bold().foregroundColor(.white).padding().frame(maxWidth: .infinity).background(AppTheme.cardDark).cornerRadius(20) }
                MainButton(text: "Jugar Otra Vez", color: AppTheme.neonGold) { engine.restartGame() }
            }.padding()
        }
    }
    func formatTime(_ s: Int) -> String { String(format: "%02d:%02d", max(0, s)/60, max(0, s)%60) }
}

struct ContentView_Previews: PreviewProvider { static var previews: some View { ContentView() } }
