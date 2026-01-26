//
//  DataSeeder.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 26/12/25.
//

import Foundation
import SwiftData
import SwiftUI

class DataSeeder {
    
    @MainActor
    static func seed(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<CategoryModel>()
            let count = try context.fetchCount(descriptor)
            
            if count == 0 {
                print("🌱 Banco vazio. Criando categorias padrão...")
                
                // ✅ Categorias normais (não recorrentes)
                let categoriasNormais = [
                    "Alimentação", "Transporte", "Lazer", "Saúde",
                    "Educação", "Renda extra", "Compras", "Viagem"
                ]
                
                for nome in categoriasNormais {
                    let categoria = CategoryModel(name: nome)
                    context.insert(categoria)
                }
                
                // ✅ SALÁRIO - Categoria recorrente mensal
                let categoriaSalario = CategoryModel(name: "Salário")
                categoriaSalario.isRecorrente = true
                categoriaSalario.tipoRecorrencia = .mensal
                categoriaSalario.intervaloRecorrencia = 1
                categoriaSalario.valorPadrao = nil
                context.insert(categoriaSalario)
                
                // ✅ CONTAS FIXAS - Categoria recorrente mensal
                let categoriaContasFixas = CategoryModel(name: "Contas Fixas")
                categoriaContasFixas.isRecorrente = true
                categoriaContasFixas.tipoRecorrencia = .mensal
                categoriaContasFixas.intervaloRecorrencia = 1
                categoriaContasFixas.valorPadrao = nil
                context.insert(categoriaContasFixas)
                
                try context.save()
                print("✅ Categorias padrão criadas!")
            } else {
                print("ℹ️ Categorias já existem")
            }
            
        } catch {
            print("❌ Erro ao semear dados: \(error)")
        }
    }
}
