//
//  api-rest-request.swift
//  api_rest_harry-potter
//
//  Created by Turma02 on 29/10/25.
//

import Foundation

struct Category: Codable, Hashable {
    let name: String
}

struct Transaction: Codable, Hashable {
    let _id:String
    let _rev: String
    let descricao: String
    let valor: Double
    let data: Int
    let category:Category
}

struct NovaTransacao: Codable {
    let descricao: String
    let valor: Double
    let data: Int
    let category: Category
}

class ViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categorias: [Category] = []
    var isLoading = false
    
    var usarMock = false
    
    func fetch() {
        
        if usarMock {
                    // Dados mockados para teste
                    self.transactions = [
                        Transaction(_id: "1", _rev: "1", descricao: "Salário", valor: 5000.0, data: 1699747200, category: Category(name: "Renda")),
                        Transaction(_id: "2", _rev: "1", descricao: "Supermercado", valor: 250.0, data: 1699747200, category: Category(name: "Alimentação")),
                        Transaction(_id: "3", _rev: "1", descricao: "Uber", valor: 45.0, data: 1699747200, category: Category(name: "Transporte"))
                    ]
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
    
    func fetchCategorias() {
        
//        if usarMock {
//            
//                    // Categorias mockadas
//                    self.categorias = [
//                        Category(name: "Alimentação"),
//                        Category(name: "Transporte"),
//                        Category(name: "Lazer"),
//                        Category(name: "Saúde"),
//                        Category(name: "Educação"),
//                        Category(name: "Renda"),
//                        Category(name: "Contas"),
//                        Category(name: "Outros")
//                    ]
//                    return
//                }
        
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
                        self?.categorias = parsed
                        
                    }
                } catch {
                    print(error)
                    
                }
            }
            
            task.resume()
        }
    
    

    func addTransaction(descricao: String, valor: Double, categoria: Category) {
        
        if usarMock {
                    // Simular adição local
                    let novaTransacao = Transaction(
                        _id: UUID().uuidString,
                        _rev: "1",
                        descricao: descricao,
                        valor: valor,
                        data: Int(Date().timeIntervalSince1970),
                        category: categoria
                    )
                    self.transactions.append(novaTransacao)
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
    
    func editTransaction(trasaction: Transaction) {
        
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

    
}
