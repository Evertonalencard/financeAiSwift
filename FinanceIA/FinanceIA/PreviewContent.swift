//
//  PreviewContent.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 26/12/25.
//

import SwiftUI
import SwiftData

@MainActor
struct PreviewHelper {
    
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: TransactionModel.self, CategoryModel.self, configurations: config)
            
            // ✅ Categorias de exemplo (corrigido)
            let catRenda = CategoryModel(name: "Renda")
            let catAlimentacao = CategoryModel(name: "Alimentação")
            let catTransporte = CategoryModel(name: "Transporte")
            let catLazer = CategoryModel(name: "Lazer")
            
            // ✅ Categoria recorrente de exemplo (corrigido)
            let catAluguel = CategoryModel(name: "Aluguel")
            catAluguel.isRecorrente = true
            catAluguel.tipoRecorrencia = .mensal
            catAluguel.intervaloRecorrencia = 1
            catAluguel.valorPadrao = -1200.00
            catAluguel.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: .mensal,
                intervalo: 1
            )
            
            container.mainContext.insert(catRenda)
            container.mainContext.insert(catAlimentacao)
            container.mainContext.insert(catTransporte)
            container.mainContext.insert(catLazer)
            container.mainContext.insert(catAluguel)
            
            // Transações de exemplo
            let t1 = TransactionModel(descricao: "Salário Mensal", valor: 5000.00, data: Date(), category: catRenda)
            t1.isRecorrenteIndividual = true
            t1.recorrenciaAtiva = true
            t1.tipoRecorrenciaRaw = "Mensal"
            t1.intervaloRecorrencia = 1
            t1.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: .mensal,
                intervalo: 1
            )

            let t2 = TransactionModel(descricao: "Supermercado", valor: -450.50, data: Date(), category: catAlimentacao)
            let t3 = TransactionModel(descricao: "Uber", valor: -24.90, data: Date().addingTimeInterval(-86400), category: catTransporte)
            let t4 = TransactionModel(descricao: "Cinema", valor: -60.00, data: Date().addingTimeInterval(-172800), category: catLazer)

            // ✅ Transação recorrente de aluguel
            let t5 = TransactionModel(descricao: "Aluguel - Janeiro", valor: -1200.00, data: Date(), category: catAluguel)
            t5.ehTransacaoAutomatica = true
            t5.recorrenciaAtiva = true

            container.mainContext.insert(t1)
            container.mainContext.insert(t2)
            container.mainContext.insert(t3)
            container.mainContext.insert(t4)
            container.mainContext.insert(t5)
            
            return container
        } catch {
            fatalError("Falha ao criar container de preview: \(error)")
        }
    }()
    
    static var exampleTransaction: TransactionModel {
        let context = container.mainContext
        let descriptor = FetchDescriptor<TransactionModel>()
        let results = try? context.fetch(descriptor)
        return results?.first ?? TransactionModel(descricao: "Erro", valor: 0, data: Date(), category: nil)
    }
}
