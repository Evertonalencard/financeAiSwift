//
//  api-rest-request.swift
//  api_rest_harry-potter
//
//  Created by Turma02 on 29/10/25.
//

import Foundation

struct Category: Codable, Hashable {
    let _id: String
    let _rev: String
    let name: String
}

//struct Categories: Codable, Hashable {
////    let _id: String
////    let _rev: String
//    let name: String
//}

struct newCategory: Codable, Hashable {
    let name: String
}

struct Transaction: Codable, Hashable {
    let _id:String
    let _rev: String
    let descricao: String
    let valor: Double
    let data: Int
    let category:newCategory
}

struct NovaTransacao: Codable {
    let descricao: String
    let valor: Double
    let data: Int
    let category: newCategory
}

class ViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var transactions: [Transaction] = []
    @Published var gastos: Double = 0
    @Published var ganhos: Double = 0
    @Published var gastosGanhos: [Double] = []
    
    var isLoading = false
    var usarMock = true
    
    
    
    // MARK: - Fetch Transactions
    func fetch() {
        
        if usarMock {
            // ✅ Dados mockados para teste
            self.transactions = [
                Transaction(_id: "1", _rev: "1", descricao: "Salário", valor: 5000.0, data: 1699747200, category: newCategory(name: "Renda")),
                Transaction(_id: "2", _rev: "1", descricao: "Supermercado", valor: -250.0, data: 1699747200, category: newCategory(name: "Alimentação")),
                Transaction(_id: "3", _rev: "1", descricao: "Uber", valor: -45.0, data: 1699747200, category: newCategory(name: "Transporte")),
                Transaction(_id: "4", _rev: "1", descricao: "Freelance", valor: 1500.0, data: 1699747200, category: newCategory(name: "Renda")),
                Transaction(_id: "5", _rev: "1", descricao: "Academia", valor: -120.0, data: 1699747200, category: newCategory(name: "Saúde"))
            ]
            calculoGanhos()
            calculoGastos()
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/getTransactions") else {
            print("Erro ao criar URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                
                let parsed = try JSONDecoder().decode([Transaction].self, from: data)
                
                DispatchQueue.main.async {
                    self?.transactions = parsed
                }
                
            } catch {
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    
    // MARK: - Fetch Categories
    func fetchCategory() {
        
        if usarMock {
            // ✅ Categorias mockadas
            self.categories = [
                Category(_id: "1", _rev: "1", name: "Alimentação"),
                Category(_id: "2", _rev: "1", name: "Transporte"),
                Category(_id: "3", _rev: "1", name: "Lazer"),
                Category(_id: "4", _rev: "1", name: "Saúde"),
                Category(_id: "5", _rev: "1", name: "Educação"),
                Category(_id: "6", _rev: "1", name: "Renda"),
                Category(_id: "7", _rev: "1", name: "Contas"),
                Category(_id: "8", _rev: "1", name: "Outros")
            ]
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/getCategories") else {
            print("Erro ao criar URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                
                let parsed = try JSONDecoder().decode([Category].self, from: data)
                
                DispatchQueue.main.async {
                    self?.categories = parsed
                }
                
            } catch {
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    
    // MARK: - Add Category
    func addCategory(nome: String) {
        
        if usarMock {
            // ✅ Simular adição local de categoria
            let novaCategoria = Category(
                _id: UUID().uuidString,
                _rev: "1",
                name: nome
            )
            self.categories.append(novaCategoria)
            print("✅ Categoria mockada adicionada: \(nome)")
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/postCategories") else{
            print("Erro ao criar URL")
            return
        }
        
        let novaCategoria = newCategory(
            name: nome
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(novaCategoria)
            request.httpBody = jsonData
        } catch {
            print("Erro ao encodar: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Sucesso")
                DispatchQueue.main.async {
                    self.fetchCategory()
                }
            }
            
            
        }.resume()
    }
    
    // MARK: - Remove Category
    func removeCategory(categories: Category) {
        
        if usarMock {
            // ✅ Remover categoria localmente
            self.categories.removeAll { $0._id == categories._id }
            print("✅ Categoria mockada removida: \(categories.name)")
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/removeCategory") else {
            print("Erro ao criar URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(categories)
            request.httpBody = jsonData
        } catch {
            print("Erro ao encodar: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Sucesso!")
                DispatchQueue.main.async {
                    self.fetchCategory()
                }
            }
        }.resume()
    }
    
    // MARK: - Add Transaction
    func addTransaction(descricao: String, valor: Double, categoria: newCategory) {
        
        if usarMock {
            // ✅ Simular adição local de transação
            let novaTransacao = Transaction(
                _id: UUID().uuidString,
                _rev: "1",
                descricao: descricao,
                valor: valor,
                data: Int(Date().timeIntervalSince1970),
                category: categoria
            )
            self.transactions.append(novaTransacao)
            calculoGanhos()
            calculoGastos()
            print("✅ Transação mockada adicionada: \(descricao)")
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/postTransactions") else {
            print("Erro ao criar URL")
            return
        }
        
        let novaTransacao = NovaTransacao(
            descricao: descricao,
            valor: valor,
            data: Int(Date().timeIntervalSince1970),
            category: categoria
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(novaTransacao)
            request.httpBody = jsonData
        } catch {
            print("Erro ao encodar: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Sucesso!")
                DispatchQueue.main.async {
                    self.fetch()
                }
            }
        }.resume()
    }
    
    // MARK: - Remove Transaction
    func removeTransaction(trasaction: Transaction) {
        
        if usarMock {
            // ✅ Remover transação localmente
            self.transactions.removeAll { $0._id == trasaction._id }
            calculoGanhos()
            calculoGastos()
            print("✅ Transação mockada removida: \(trasaction.descricao)")
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/removeTransaction") else {
            print("Erro ao criar URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(trasaction)
            request.httpBody = jsonData
        } catch {
            print("Erro ao encodar: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Sucesso!")
                DispatchQueue.main.async {
                    self.fetch()
                }
            }
        }.resume()
    }
    
    // MARK: - Edit Transaction
    func editTransaction(trasaction: Transaction) {
        if usarMock {
            // ✅ Editar transação localmente
            if let index = transactions.firstIndex(where: { $0._id == trasaction._id }) {
                transactions[index] = trasaction
                calculoGanhos()
                calculoGastos()
                print("✅ Transação mockada editada: \(trasaction.descricao)")
            }
            return
        }
        
        guard let url = URL(string: "http://192.168.128.31:1880/putTransaction") else {
            print("Erro ao criar URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let jsonData = try JSONEncoder().encode(trasaction)
            request.httpBody = jsonData
        } catch {
            print("Erro ao encodar: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("Sucesso!")
                DispatchQueue.main.async {
                    self.fetch()
                }
            }
        }.resume()
    }
    
    func calculoGanhos() {
        
        //        self.fetch()
        
        var ganhos: Double = 0.0
        
        
        for data in transactions {
            //            print(data.valor)
            if data.valor > 0 {
                ganhos += data.valor
            }
        }
        
        //        print(ganhos)
        
        self.ganhos = ganhos
        
        if usarMock{
            atualizarGastosGanhos()
        }
    }
    
    func calculoGastos()  {
        
        //        self.fetch()
        
        
        var gastos: Double = 0.0
        
        for data in transactions {
            //            print(data.valor)
            if data.valor < 0 {
                gastos += data.valor
            }
        }
        
        //        print(gastos)
        
        self.gastos = gastos
        
        if usarMock{
            atualizarGastosGanhos()
        }
    }
    
    // Função auxiliar para atualizar array de gráfico
    func atualizarGastosGanhos() {
        self.gastosGanhos = [ganhos, abs(gastos)]
    }
    
    
}


