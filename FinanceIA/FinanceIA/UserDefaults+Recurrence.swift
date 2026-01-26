//
//  UserDefaults+Recurrence.swift.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 24/01/26.
//

//
//  UserDefaults+Recurrence.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 24/01/26.
//

import Foundation

extension UserDefaults {
    private static let lastRecurrenceCheckKey = "lastRecurrenceCheckDate"
    
    static var lastRecurrenceCheck: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastRecurrenceCheckKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastRecurrenceCheckKey)
        }
    }
    
    static func jaVerificouRecorrenciaHoje() -> Bool {
        guard let ultimaVerificacao = lastRecurrenceCheck else { return false }
        
        let calendar = Calendar.current
        return calendar.isDateInToday(ultimaVerificacao)
    }
    
    /// ⚠️ Apenas para debug - reseta a verificação
    static func resetarVerificacaoRecorrencia() {
        UserDefaults.standard.removeObject(forKey: lastRecurrenceCheckKey)
        print("🔄 Verificação de recorrência resetada")
    }
}
