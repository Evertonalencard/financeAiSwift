
import Foundation
import SwiftUI
import SwiftData

@MainActor // ✅ Garante que rode na thread principal (UI)
class ViewModel: ObservableObject {
    
    // Agora armazenamos os modelos do SwiftData
    @Published var categories: [CategoryModel] = []
    @Published var transactions: [TransactionModel] = []
    
    @Published var gastos: Decimal = 0
    @Published var ganhos: Decimal = 0
    @Published var gastosGanhos: [Decimal] = []
    @Published var carregando = false
    
    // O contexto do banco de dados (será injetado)
    private var modelContext: ModelContext?
    
    // MARK: - Setup
    // Chamaremos isso na .onAppear da View passando o contexto
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetch() // Carrega os dados assim que o contexto chegar
    }

    // MARK: - Fetch (Buscar Dados Localmente)
    func fetch() {
        guard let context = modelContext else { return }
        
        do {
            // ✅ Busca no banco local
            let descriptorTransaction = FetchDescriptor<TransactionModel>(sortBy: [SortDescriptor(\.data, order: .reverse)])
            self.transactions = try context.fetch(descriptorTransaction)
            
            let descriptorCategory = FetchDescriptor<CategoryModel>(sortBy: [SortDescriptor(\.name)])
            self.categories = try context.fetch(descriptorCategory)
            
            // Recalcula totais
            calculoGanhos()
            calculoGastos()
            atualizarGastosGanhos()
            
        } catch {
            print("❌ Erro ao buscar dados: \(error)")
        }
    }
    

    // MARK: - Adicionar Transação
    func addTransaction(descricao: String, valor: Decimal, categoria: CategoryModel) {
        guard let context = modelContext else { return }
        
        let novaTransacao = TransactionModel(
            descricao: descricao,
            valor: valor,
            data: Date(),
            category: categoria
        )
        
        // ✅ Se categoria é recorrente, configura recorrência individual
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
        saveContext()
        fetch()
    }

    // ✅ ADICIONAR essa função que estava faltando
    private func saveContext() {
        try? modelContext?.save()
    }




    
    // MARK: - Remover Transação
    func removeTransaction(transaction: TransactionModel) {
        guard let context = modelContext else { return }
        
        context.delete(transaction) // ✅ Remove do banco
        saveContext()
        fetch()
    }
    
    // MARK: - Adicionar Categoria
    func addCategory(nome: String) {
        guard let context = modelContext else { return }
        
        let novaCategoria = CategoryModel(name: nome)
        context.insert(novaCategoria)
        saveContext()
        fetch()
    }
    
    // MARK: - Remover Categoria
    func removeCategory(category: CategoryModel) {
        guard let context = modelContext else { return }
        context.delete(category)
        saveContext()
        fetch()
    }

    // MARK: - Cálculos
    func calculoGanhos() {
        self.ganhos = transactions.filter { $0.valor > 0 }.reduce(0) { $0 + $1.valor }
    }
    
    func calculoGastos() {
        self.gastos = transactions.filter { $0.valor < 0 }.reduce(0) { $0 + $1.valor }
    }
    
    func atualizarGastosGanhos() {
        self.gastosGanhos = [ganhos, abs(gastos)]
    }
    
    // Salva as alterações explicitamente (embora o SwiftData faça autosave)

    
    // MARK: - Cálculos para Gráficos

    // Gastos por categoria
    func gastosPorCategoria() -> [(categoria: String, valor: Decimal)] {
        let gastosDict = Dictionary(grouping: transactions.filter { $0.valor < 0 }, by: { $0.category?.name ?? "Sem categoria" })
        
        return gastosDict.map { (categoria: $0.key, valor: abs($0.value.reduce(0) { $0 + $1.valor })) }
            .sorted { $0.valor > $1.valor }
            .prefix(5)
            .map { $0 }
    }

    // Ganhos por categoria
    func ganhosPorCategoria() -> [(categoria: String, valor: Decimal)] {
        let ganhosDict = Dictionary(grouping: transactions.filter { $0.valor > 0 }, by: { $0.category?.name ?? "Sem categoria" })
        
        return ganhosDict.map { (categoria: $0.key, valor: $0.value.reduce(0) { $0 + $1.valor }) }
            .sorted { $0.valor > $1.valor }
            .prefix(5)
            .map { $0 }
    }

    // Transações recentes (últimos 7 dias)
    func transacoesRecentes() -> [(data: Date, saldo: Decimal)] {
        let calendar = Calendar.current
        let hoje = Date()
        let seteDiasAtras = calendar.date(byAdding: .day, value: -7, to: hoje)!
        
        let transacoesRecentes = transactions
            .filter { $0.data >= seteDiasAtras }
            .sorted { $0.data < $1.data }
        
        var saldoAcumulado: Decimal = 0
        var resultado: [(Date, Decimal)] = []
        
        for transacao in transacoesRecentes {
            saldoAcumulado += transacao.valor
            resultado.append((transacao.data, saldoAcumulado))
        }
        
        return resultado
    }

    // Total de recorrências ativas
    func totalRecorrenciasAtivas() -> Decimal {
        return transactions
            .filter { $0.isRecorrente && $0.recorrenciaAtiva }
            .reduce(0) { $0 + $1.valor }
    }

    // Próximas recorrências (este mês)
    func proximasRecorrencias() -> [(descricao: String, valor: Decimal, data: Date)] {
        let calendar = Calendar.current
        let inicioMes = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let fimMes = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inicioMes)!
        
        return transactions
            .filter { transaction in
                guard transaction.isRecorrente,
                      transaction.recorrenciaAtiva,
                      let proxima = transaction.proximaOcorrencia else { return false }
                return proxima >= inicioMes && proxima <= fimMes
            }
            .map { (descricao: $0.descricao, valor: $0.valor, data: $0.proximaOcorrencia!) }
            .sorted { $0.data < $1.data }
            .prefix(5)
            .map { $0 }
    }

}



    // MARK: - Api
////
////  api-rest-request.swift
////  api_rest_harry-potter
////
////  Created by Turma02 on 29/10/25.
////
//
//import Foundation
//import Combine
//
//struct Category: Codable, Hashable {
//    let _id: String
//    let _rev: String
//    let name: String
//}
//
////struct Categories: Codable, Hashable {
//////    let _id: String
//////    let _rev: String
////    let name: String
////}
//
//struct newCategory: Codable, Hashable {
//    let name: String
//}
//
//struct Transaction: Codable, Hashable {
//    let _id:String
//    let _rev: String
//    let descricao: String
//    let valor: Double
//    let data: Int
//    let category:newCategory
//}
//
//struct NovaTransacao: Codable {
//    let descricao: String
//    let valor: Double
//    let data: Int
//    let category: newCategory
//}
//
//class ViewModel: ObservableObject {
//    @Published var categories: [Category] = []
//    @Published var transactions: [Transaction] = []
//    @Published var gastos: Double = 0
//    @Published var ganhos: Double = 0
//    @Published var gastosGanhos: [Double] = []
//    
//    @Published var carregando = false
//    
//    
//    var usarMock = false
//    
//    
//    
//    // MARK: - Fetch Transactions
//    func fetch() {
//        
//        
//        
//        if usarMock {
//            // ✅ Dados mockados para teste
//            self.transactions = [
//                Transaction(_id: "1", _rev: "1", descricao: "Salário", valor: 5000.0, data: 1699747200, category: newCategory(name: "Renda")),
//                Transaction(_id: "2", _rev: "1", descricao: "Supermercado", valor: -250.0, data: 1699747200, category: newCategory(name: "Alimentação")),
//                Transaction(_id: "3", _rev: "1", descricao: "Uber", valor: -45.0, data: 1699747200, category: newCategory(name: "Transporte")),
//                Transaction(_id: "4", _rev: "1", descricao: "Freelance", valor: 1500.0, data: 1699747200, category: newCategory(name: "Renda")),
//                Transaction(_id: "5", _rev: "1", descricao: "Academia", valor: -120.0, data: 1699747200, category: newCategory(name: "Saúde"))
//            ]
//            calculoGanhos()
//            calculoGastos()
//            
//            
//            
//            return
//        }
//        
//        guard let url = URL(string: "http://192.168.128.31:1880/getTransactions") else {
//            print("Erro ao criar URL")
//            
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            
//            guard let data = data, error == nil else {
//                return
//            }
//            
//            do {
//                
//                let parsed = try JSONDecoder().decode([Transaction].self, from: data)
//                
//                DispatchQueue.main.async {
//                    self?.transactions = parsed
//                    self?.calculoGanhos()
//                    self?.calculoGastos()
//                    self?.gastosGanhos = [self?.ganhos ?? 0.0, self?.gastos ?? 0.00]
//                }
//                
//            } catch {
//                print(error)
//            }
//            
//        }
//        
//        task.resume()
//        
//    }
//    
//    // MARK: - Fetch Categories
////    func fetchCategory() {
////        carregando = true
////
////        if usarMock {
////            // ✅ Categorias mockadas
////            self.categories = [
////                Category(_id: "1", _rev: "1", name: "Alimentação"),
////                Category(_id: "2", _rev: "1", name: "Transporte"),
////                Category(_id: "3", _rev: "1", name: "Lazer"),
////                Category(_id: "4", _rev: "1", name: "Saúde"),
////                Category(_id: "5", _rev: "1", name: "Educação"),
////                Category(_id: "6", _rev: "1", name: "Renda"),
////                Category(_id: "7", _rev: "1", name: "Contas"),
////                Category(_id: "8", _rev: "1", name: "Outros")
////            ]
////            return
////        }
////
////        guard let url = URL(string: "http://192.168.128.31:1880/getCategories") else {
////            print("Erro ao criar URL")
////            return
////        }
////
////        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
////
////            guard let data = data, error == nil else {
////                return
////            }
////
////            do {
////
////                let parsed = try JSONDecoder().decode([Category].self, from: data)
////
////                DispatchQueue.main.async {
////                    self?.categories = parsed
////                }
////
////            } catch {
////                print(error)
////            }
////
////        }
////        carregando = false
////        task.resume()
////
////    }
//    
//    func fetchCategory() { // se isso nao funcionar voltar para o anterior
//        DispatchQueue.main.async { self.carregando = true }
//
//        if usarMock {
//            DispatchQueue.main.async {
//                self.categories = [
//                    Category(_id: "1", _rev: "1", name: "Alimentação"),
//                    Category(_id: "2", _rev: "1", name: "Transporte"),
//                    Category(_id: "3", _rev: "1", name: "Lazer"),
//                    Category(_id: "4", _rev: "1", name: "Saúde"),
//                    Category(_id: "5", _rev: "1", name: "Educação"),
//                    Category(_id: "6", _rev: "1", name: "Renda"),
//                    Category(_id: "7", _rev: "1", name: "Contas"),
//                    Category(_id: "8", _rev: "1", name: "Outros")
//                ]
//                self.carregando = false
//            }
//            return
//        }
//
//        guard let url = URL(string: "http://192.168.128.31:1880/getCategories") else {
//            print("Erro ao criar URL")
//            DispatchQueue.main.async { self.carregando = false }
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Erro: \(error)")
//                DispatchQueue.main.async { self.carregando = false }
//                return
//            }
//
//            guard let data = data else {
//                DispatchQueue.main.async { self.carregando = false }
//                return
//            }
//
//            do {
//                let parsed = try JSONDecoder().decode([Category].self, from: data)
//                DispatchQueue.main.async {
//                    self.categories = parsed
//                    self.carregando = false
//                }
//            } catch {
//                print(error)
//                DispatchQueue.main.async { self.carregando = false }
//            }
//        }
//        task.resume()
//    }
//    
//    // MARK: - Add Category
//    func addCategory(nome: String) {
//        
//        if usarMock {
//            // ✅ Simular adição local de categoria
//            let novaCategoria = Category(
//                _id: UUID().uuidString,
//                _rev: "1",
//                name: nome
//            )
//            self.categories.append(novaCategoria)
//            print("✅ Categoria mockada adicionada: \(nome)")
//            return
//        }
//        
//        guard let url = URL(string: "http://192.168.128.31:1880/postCategories") else{
//            print("Erro ao criar URL")
//            return
//        }
//        
//        let novaCategoria = newCategory(
//            name: nome
//        )
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        
//        do {
//            let jsonData = try JSONEncoder().encode(novaCategoria)
//            request.httpBody = jsonData
//        } catch {
//            print("Erro ao encodar: \(error)")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print("Erro: \(error)")
//                return
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse,
//               (200...299).contains(httpResponse.statusCode) {
//                print("Sucesso")
//                DispatchQueue.main.async {
//                    self.fetchCategory()
//                }
//            }
//            
//            
//        }.resume()
//    }
//    
//    // MARK: - Remove Category
//    func removeCategory(categories: Category) {
//        
//        if usarMock {
//            // ✅ Remover categoria localmente
//            self.categories.removeAll { $0._id == categories._id }
//            print("✅ Categoria mockada removida: \(categories.name)")
//            return
//        }
//        
//        guard let url = URL(string: "http://192.168.128.31:1880/removeCategory") else {
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
//            let jsonData = try JSONEncoder().encode(categories)
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
//                    self.fetchCategory()
//                }
//            }
//        }.resume()
//    }
//    
//    // MARK: - Add Transaction
//    func addTransaction(descricao: String, valor: Double, categoria: newCategory) {
//        
//        if usarMock {
//            // ✅ Simular adição local de transação
//            let novaTransacao = Transaction(
//                _id: UUID().uuidString,
//                _rev: "1",
//                descricao: descricao,
//                valor: valor,
//                data: Int(Date().timeIntervalSince1970),
//                category: categoria
//            )
//            self.transactions.append(novaTransacao)
//            calculoGanhos()
//            calculoGastos()
//            print("✅ Transação mockada adicionada: \(descricao)")
//            return
//        }
//        
//        guard let url = URL(string: "http://192.168.128.31:1880/postTransactions") else {
//            print("Erro ao criar URL")
//            return
//        }
//        
//        let novaTransacao = NovaTransacao(
//            descricao: descricao,
//            valor: valor,
//            data: Int(Date().timeIntervalSince1970),
//            category: categoria
//        )
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        
//        do {
//            let jsonData = try JSONEncoder().encode(novaTransacao)
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
//    // MARK: - Remove Transaction
//    func removeTransaction(trasaction: Transaction) {
//        
//        if usarMock {
//            // ✅ Remover transação localmente
//            self.transactions.removeAll { $0._id == trasaction._id }
//            calculoGanhos()
//            calculoGastos()
//            print("✅ Transação mockada removida: \(trasaction.descricao)")
//            return
//        }
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
//    // MARK: - Edit Transaction
//    func editTransaction(trasaction: Transaction) {
//        if usarMock {
//            // ✅ Editar transação localmente
//            if let index = transactions.firstIndex(where: { $0._id == trasaction._id }) {
//                transactions[index] = trasaction
//                calculoGanhos()
//                calculoGastos()
//                print("✅ Transação mockada editada: \(trasaction.descricao)")
//            }
//            return
//        }
//        
//        guard let url = URL(string: "http://192.168.128.31:1880/putTransaction") else {
//            print("Erro ao criar URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
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
//    func calculoGanhos() {
//        
//        //        self.fetch()
//        
//        var ganhos: Double = 0.0
//        
//        
//        for data in transactions {
//            //            print(data.valor)
//            if data.valor > 0 {
//                ganhos += data.valor
//            }
//        }
//        
//        //        print(ganhos)
//        
//        self.ganhos = ganhos
//        
//        if usarMock{
//            atualizarGastosGanhos()
//        }
//    }
//    
//    func calculoGastos()  {
//        
//        //        self.fetch()
//        
//        
//        var gastos: Double = 0.0
//        
//        for data in transactions {
//            //            print(data.valor)
//            if data.valor < 0 {
//                gastos += data.valor
//            }
//        }
//        
//        //        print(gastos)
//        
//        self.gastos = gastos
//        
//        if usarMock{
//            atualizarGastosGanhos()
//        }
//    }
//    
//    // Função auxiliar para atualizar array de gráfico
//    func atualizarGastosGanhos() {
//        self.gastosGanhos = [ganhos, abs(gastos)]
//    }
//    
//    
//}
//
