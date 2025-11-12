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

struct newCategory: Codable, Hashable {
    let name: String
}

class ViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    func fetch() {
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
    
    func addCategory(nome: String) {
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
                    self.fetch()
                }
            }
            
            
        }.resume()
    }

    func removeCategory(categories: Category) {
        
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
                    self.fetch()
                }
            }
        }.resume()
    }
    
    
}

