import Foundation
import SwiftData
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    // ✅ ADICIONAR NO CONTENTVIEWMODEL
    enum PeriodoHistorico: String, CaseIterable {
        case umMes = "Último mês"
        case tresMeses = "Últimos 3 meses"
        case seisMeses = "Últimos 6 meses"
        case umAno = "Último ano"
        case tudo = "Todo histórico"
        
        var icone: String {
            switch self {
            case .umMes: return "1.circle"
            case .tresMeses: return "3.circle"
            case .seisMeses: return "6.circle"
            case .umAno: return "calendar"
            case .tudo: return "infinity"
            }
        }
        
        var meses: Int? {
            switch self {
            case .umMes: return -1
            case .tresMeses: return -3
            case .seisMeses: return -6
            case .umAno: return -12
            case .tudo: return nil
            }
        }
    }

    @Published var periodoSelecionado: PeriodoHistorico = .tresMeses
    
    @Published var transactions: [TransactionModel] = []
    @Published var meses: [String] = []
    @Published var lastMonth = ""
    @Published var isLoading = false
    @Published var hasMoreData = true
    
    // ✅ ADICIONAR: Controle de período
    @Published var limitarPorData = true  // true = últimos 3 meses, false = tudo
    @Published var dataLimite: Date?
    
    private var modelContext: ModelContext?
    private var currentOffset = 0
    private let pageSize = 10
    
    // Configura o contexto (chamado no onAppear da View)
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        
        // ✅ Calcula data limite (3 meses atrás)
        if limitarPorData {
            let calendar = Calendar.current
            self.dataLimite = calendar.date(byAdding: .month, value: -3, to: Date())
        } else {
            self.dataLimite = nil
        }
        
        resetAndFetch()
    }
    
    // ✅ Reseta e busca do zero
    func resetAndFetch() {
        currentOffset = 0
        transactions.removeAll()
        hasMoreData = true
        fetchMore()
    }
    
    // ✅ Busca inicial
    func fetch() {
        resetAndFetch()
    }
    
    // ✅ Carrega mais transações
    func fetchMore() {
        guard let context = modelContext, !isLoading, hasMoreData else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                var descriptor: FetchDescriptor<TransactionModel>
                
                // ✅ Aplica filtro de data se configurado
                if let dataLimite = self.dataLimite {
                    descriptor = FetchDescriptor<TransactionModel>(
                        predicate: #Predicate<TransactionModel> {
                            $0.data >= dataLimite
                        },
                        sortBy: [SortDescriptor(\.data, order: .reverse)]
                    )
                    print("📅 Buscando desde \(dataLimite.formatted(date: .abbreviated, time: .omitted))")
                } else {
                    descriptor = FetchDescriptor<TransactionModel>(
                        sortBy: [SortDescriptor(\.data, order: .reverse)]
                    )
                    print("📅 Buscando todo o histórico")
                }
                
                descriptor.fetchLimit = self.pageSize
                descriptor.fetchOffset = self.currentOffset
                
                let novasTransacoes = try context.fetch(descriptor)
                
                // Se retornou menos que pageSize, acabaram os dados
                if novasTransacoes.count < self.pageSize {
                    self.hasMoreData = false
                }
                
                self.transactions.append(contentsOf: novasTransacoes)
                self.currentOffset += novasTransacoes.count
                
                self.getMonth(transactionArray: self.transactions)
                self.isLoading = false
                
                print("📦 Carregadas \(novasTransacoes.count) transações (total: \(self.transactions.count))")
                
            } catch {
                print("❌ Erro ao buscar transações: \(error)")
                self.isLoading = false
            }
        }
    }
    
    // ✅ NOVA FUNÇÃO: Alternar entre 3 meses e tudo
    func alternarPeriodo() {
        limitarPorData.toggle()
        
        if limitarPorData {
            let calendar = Calendar.current
            dataLimite = calendar.date(byAdding: .month, value: -3, to: Date())
        } else {
            dataLimite = nil
        }
        
        resetAndFetch()
    }
    
    // Lógica para extrair os meses únicos (agora usando Date direto)
    func getMonth(transactionArray: [TransactionModel]) {
        meses.removeAll() // Limpa antes de recalcular
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM" // Extrai apenas o número do mês
        
        for transaction in transactionArray {
            let month = formatter.string(from: transaction.data)
            
            if !meses.contains(month) {
                meses.append(month)
            }
        }
    }
    
    func removeTransaction(transaction: TransactionModel) {
        guard let context = modelContext else { return }
        context.delete(transaction)
        fetch() // Atualiza a lista
    }
    
    func addTransaction(descricao: String, valor: Decimal, categoria: CategoryModel) {
        guard let context = modelContext else { return }
        
        let novaTransacao = TransactionModel(
            descricao: descricao,
            valor: valor,
            data: Date(),
            category: categoria
        )
        
        if categoria.isRecorrente {
            novaTransacao.isRecorrenteIndividual = true
            novaTransacao.recorrenciaAtiva = true
            novaTransacao.tipoRecorrenciaRaw = categoria.tipoRecorrenciaRaw
            novaTransacao.intervaloRecorrencia = categoria.intervaloRecorrencia
            novaTransacao.ehTransacaoAutomatica = false
            
            novaTransacao.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: categoria.tipoRecorrencia,
                intervalo: categoria.intervaloRecorrencia
            )
            
            print("🔄 Transação '\(descricao)' configurada como recorrente individual")
        }
        
        context.insert(novaTransacao)
        
        // ✅ ADICIONAR
        do {
            try context.save()
        } catch {
            print("❌ Erro ao salvar: \(error)")
        }
        
        fetch()
    }
    
    
}

// MARK: - api
////
////  ContentViewModel.swift
////  projetofinal
////
////  Created by Turma02-6 on 14/11/25.
////
//
//import Foundation
//import Combine
//
//final class ContentViewModel: ObservableObject {
//    var meses: [String] = []
//    var lastMonth = ""
//    @Published var transactions: [Transaction] = []
//
//    func getMonth(transactionArray: [Transaction]) {
//        for transaction in transactionArray {
//            let month = String("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))".split(separator: "-")[1])
//
//            if !meses.contains(month) {
//                meses.append(month)
//            }
//        }
//    }
//
//    func removeTransaction(trasaction: Transaction) {
//
//        guard let url = URL(string: "http://192.168.128.31:1880/removeTransaction") else {
//            print("Erro ao criar URL")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//        do {
//            let jsonData = try JSONEncoder().encode(trasaction)
//            request.httpBody = jsonData
//        } catch {
//            print("Erro ao encodar: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Erro: \(error)")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse,
//               (200...299).contains(httpResponse.statusCode) {
//                print("Sucesso!")
//                DispatchQueue.main.async {
//                    self.fetch()
//                }
//            }
//        }.resume()
//    }
//
//    func fetch() {
//        guard let url = URL(string: "http://192.168.128.31:1880/getTransactions") else {
//            print("Erro ao criar URL")
//            return
//        }
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let data = data, error == nil else {
//                print("error")
//                return
//            }
//            do {
//                let parsed = try JSONDecoder().decode([Transaction].self, from: data)
//                DispatchQueue.main.async {
//                    self?.getMonth(transactionArray: parsed)
//                    self?.transactions = parsed
//                }
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//}

