//
//  FinanceIaModels.swift
//  FinanceIA
//

import Foundation
import SwiftData

// MARK: - Tipo de Recorrência
enum TipoRecorrencia: String, Codable, CaseIterable {  // ✅ Adicione CaseIterable
    case nenhuma = "Nenhuma"
    case diaria = "Diária"
    case semanal = "Semanal"
    case mensal = "Mensal"
    case anual = "Anual"
    case personalizada = "Personalizada"
}


// MARK: - Categoria
@Model
class CategoryModel {
    @Attribute(.unique) var id: UUID
    var name: String
    
    // Recorrência da categoria
    var isRecorrente: Bool
    var tipoRecorrenciaRaw: String
    var intervaloRecorrencia: Int
    var valorPadrao: Decimal?
    var proximaOcorrencia: Date?
    
    @Relationship(deleteRule: .cascade)
    var transactions: [TransactionModel]?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.isRecorrente = false
        self.tipoRecorrenciaRaw = TipoRecorrencia.nenhuma.rawValue
        self.intervaloRecorrencia = 1
        self.valorPadrao = nil
        self.proximaOcorrencia = nil
    }
    
    var tipoRecorrencia: TipoRecorrencia {
        get { TipoRecorrencia(rawValue: tipoRecorrenciaRaw) ?? .nenhuma }
        set { tipoRecorrenciaRaw = newValue.rawValue }
    }
    
    static func calcularProximaOcorrencia(from data: Date, tipo: TipoRecorrencia, intervalo: Int) -> Date? {
        let calendar = Calendar.current
        
        switch tipo {
        case .nenhuma:
            return nil
        case .diaria:
            return calendar.date(byAdding: .day, value: intervalo, to: data)
        case .semanal:
            return calendar.date(byAdding: .weekOfYear, value: intervalo, to: data)
        case .mensal:
            return calendar.date(byAdding: .month, value: intervalo, to: data)
        case .anual:
            return calendar.date(byAdding: .year, value: intervalo, to: data)
        case .personalizada:
            return calendar.date(byAdding: .day, value: intervalo, to: data)
        }
    }
}

// MARK: - Transação
@Model
class TransactionModel {
    @Attribute(.unique) var id: UUID
    var descricao: String
    var valor: Decimal
    var data: Date
    
    // ✅ Sistema de recorrência individual
    var isRecorrenteIndividual: Bool
    var recorrenciaAtiva: Bool
    var tipoRecorrenciaRaw: String?
    var intervaloRecorrencia: Int?
    var proximaOcorrencia: Date?
    var ehTransacaoAutomatica: Bool
    
    var category: CategoryModel?
    
    init(descricao: String, valor: Decimal, data: Date, category: CategoryModel?) {
        self.id = UUID()
        self.descricao = descricao
        self.valor = valor
        self.data = data
        self.category = category
        self.isRecorrenteIndividual = false
        self.recorrenciaAtiva = false
        self.tipoRecorrenciaRaw = nil
        self.intervaloRecorrencia = nil
        self.proximaOcorrencia = nil
        self.ehTransacaoAutomatica = false
    }
    
    var tipoRecorrencia: TipoRecorrencia {
        get {
            if let raw = tipoRecorrenciaRaw {
                return TipoRecorrencia(rawValue: raw) ?? .nenhuma
            }
            return .nenhuma
        }
    }
    
    // ✅ Propriedade computada: é recorrente se for individual OU se a categoria tem valor padrão e é automática
    var isRecorrente: Bool {
        return isRecorrenteIndividual || ehTransacaoAutomatica
    }
}
