//
//  RecurrenceManager.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 24/01/26.
//

import Foundation
import SwiftData

@MainActor
class RecurrenceManager {
    
    /// Verifica e cria todas as recorrências pendentes
    static func verificarRecorrencias(context: ModelContext) {
        if UserDefaults.jaVerificouRecorrenciaHoje() {
            print("ℹ️ Recorrências já verificadas hoje")
            return
        }
        
        print("🔍 Iniciando verificação de recorrências...")
        
        verificarCategoriasComValorPadrao(context: context)
        verificarTransacoesIndividuais(context: context)
        
        do {
            try context.save()
            UserDefaults.lastRecurrenceCheck = Date()
            print("✅ Verificação de recorrências concluída")
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
    }
    
    // MARK: - Categorias com Valor Padrão
    
    private static func verificarCategoriasComValorPadrao(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<CategoryModel>()
            let todasCategorias = try context.fetch(descriptor)
            
            // ✅ Filtra em memória
            let categoriasRecorrentes = todasCategorias.filter {
                $0.isRecorrente == true && $0.valorPadrao != nil
            }
            
            for categoria in categoriasRecorrentes {
                processarCategoriaComValorPadrao(categoria: categoria, context: context)
            }
            
        } catch {
            print("❌ Erro ao buscar categorias: \(error)")
        }
    }
    
    private static func processarCategoriaComValorPadrao(categoria: CategoryModel, context: ModelContext) {
        guard let proximaOcorrencia = categoria.proximaOcorrencia,
              let valorPadrao = categoria.valorPadrao else { return }
        
        let agora = Date()
        
        if proximaOcorrencia <= agora {
            if !existeTransacaoAutomaticaHoje(categoria: categoria, context: context) {
                criarTransacaoAutomatica(categoria: categoria, valor: valorPadrao, context: context)
                
                categoria.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                    from: agora,
                    tipo: categoria.tipoRecorrencia,
                    intervalo: categoria.intervaloRecorrencia
                )
                
                print("📅 Próxima ocorrência de '\(categoria.name)': \(categoria.proximaOcorrencia?.formatted(date: .numeric, time: .omitted) ?? "N/A")")
            }
        }
    }
    
    private static func criarTransacaoAutomatica(categoria: CategoryModel, valor: Decimal, context: ModelContext) {
        let descricao = "\(categoria.name) - \(categoria.tipoRecorrencia.rawValue)"
        
        let transacao = TransactionModel(
            descricao: descricao,
            valor: valor,
            data: Date(),
            category: categoria
        )
        
        transacao.ehTransacaoAutomatica = true
        transacao.isRecorrenteIndividual = false
        transacao.recorrenciaAtiva = true
        
        context.insert(transacao)
        print("🔄 Transação automática criada: \(descricao) - \(valor)")
    }
    
    private static func existeTransacaoAutomaticaHoje(categoria: CategoryModel, context: ModelContext) -> Bool {
        let (inicio, fim) = limitesDoDiaAtual()
        let categoriaID = categoria.id
        
        do {
            let descriptor = FetchDescriptor<TransactionModel>()
            let todas = try context.fetch(descriptor)
            
            // ✅ Filtra em memória
            let automaticasHoje = todas.filter { t in
                t.ehTransacaoAutomatica == true &&
                t.category?.id == categoriaID &&
                t.data >= inicio &&
                t.data < fim
            }
            
            return !automaticasHoje.isEmpty
            
        } catch {
            print("❌ Erro ao verificar duplicatas: \(error)")
            return false
        }
    }
    
    // MARK: - Transações Individuais
    
    private static func verificarTransacoesIndividuais(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<TransactionModel>()
            let todas = try context.fetch(descriptor)
            
            // ✅ Filtra em memória
            let recorrentes = todas.filter {
                $0.isRecorrenteIndividual == true && $0.recorrenciaAtiva == true
            }
            
            for transacao in recorrentes {
                processarTransacaoIndividual(transacao: transacao, context: context)
            }
            
        } catch {
            print("❌ Erro ao buscar transações individuais: \(error)")
        }
    }
    
    private static func processarTransacaoIndividual(transacao: TransactionModel, context: ModelContext) {
        guard let proximaOcorrencia = transacao.proximaOcorrencia else { return }
        
        let agora = Date()
        
        if proximaOcorrencia <= agora {
            if !existeOcorrenciaHoje(transacao: transacao, context: context) {
                criarNovaOcorrencia(de: transacao, context: context)
            }
        }
    }
    
    private static func criarNovaOcorrencia(de transacao: TransactionModel, context: ModelContext) {
        let nova = TransactionModel(
            descricao: transacao.descricao,
            valor: transacao.valor,
            data: Date(),
            category: transacao.category
        )
        
        nova.isRecorrenteIndividual = true
        nova.recorrenciaAtiva = true
        nova.tipoRecorrenciaRaw = transacao.tipoRecorrenciaRaw
        nova.intervaloRecorrencia = transacao.intervaloRecorrencia
        nova.ehTransacaoAutomatica = false
        
        if let intervalo = transacao.intervaloRecorrencia,
           let tipoRaw = transacao.tipoRecorrenciaRaw,
           let tipo = TipoRecorrencia(rawValue: tipoRaw) {
            nova.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: tipo,
                intervalo: intervalo
            )
        }
        
        context.insert(nova)
        
        // ✅ Desativa a original
        transacao.isRecorrenteIndividual = false
        transacao.recorrenciaAtiva = false
        transacao.proximaOcorrencia = nil
        
        print("🔄 Nova ocorrência criada: \(transacao.descricao)")
        print("⏸️ Transação original desativada")
    }
    
    private static func existeOcorrenciaHoje(transacao: TransactionModel, context: ModelContext) -> Bool {
        let (inicio, fim) = limitesDoDiaAtual()
        let descricaoOriginal = transacao.descricao
        let valorOriginal = transacao.valor
        
        do {
            let descriptor = FetchDescriptor<TransactionModel>()
            let todas = try context.fetch(descriptor)
            
            let hoje = todas.filter { t in
                t.descricao == descricaoOriginal &&
                t.valor == valorOriginal &&
                t.data >= inicio &&
                t.data < fim
            }
            
            return hoje.count > 1
            
        } catch {
            print("❌ Erro ao verificar duplicatas: \(error)")
            return false
        }
    }
    
    // MARK: - Helpers
    
    private static func limitesDoDiaAtual() -> (inicio: Date, fim: Date) {
        let calendar = Calendar.current
        let inicio = calendar.startOfDay(for: Date())
        let fim = calendar.date(byAdding: .day, value: 1, to: inicio)!
        return (inicio, fim)
    }
}
