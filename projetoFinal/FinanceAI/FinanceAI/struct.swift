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

struct NovaTransacao: Codable {
    let descricao: String
    let valor: Double
    let data: Int
    let category: Category
}

struct Transaction: Codable, Hashable {
    let _id: String
    let _rev: String
    let descricao: String
    let valor: Double
    let data: Int
    let category:Category
}

class ViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categorias: [Category] = []
    @Published var gastos: Double = 0
    @Published var ganhos: Double = 0
    @Published var gastosGanhos: [Double] = []
    
    func fetch() {
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
                    self?.calculoGanhos()
                    self?.calculoGastos()
                    self?.gastosGanhos.append(self?.ganhos ?? 0)
                    self?.gastosGanhos.append(self?.gastos ?? 0)
                }
                
                
            } catch {
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    func fetchCategorias() {
       
        
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
    }
    
    func addCategory(nome: String) {
        guard let url = URL(string: "http://192.168.128.31:1880/postCategories") else{
            print("Erro ao criar URL")
            return
        }
        
        let novaCategoria = Category(
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
                    self.fetch()
                }
            }
        }.resume()
    }
}
