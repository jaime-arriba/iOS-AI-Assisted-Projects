import Foundation
import SwiftUI

@Observable
class WorkoutManager {
    var isTimerRunning = false
    var timeRemaining = 0
    var timer: Timer?
    
    // Iniciar descanso (ej: 90 segundos)
    func startRestTimer(seconds: Int) {
        stopTimer() // Reiniciar si ya existe
        timeRemaining = seconds
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                // Aquí podrías lanzar una notificación o vibración
            }
        }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
