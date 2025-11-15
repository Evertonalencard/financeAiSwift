//
//  ContentViewModel.swift
//  projetofinal
//
//  Created by Turma02-6 on 14/11/25.
//

import Foundation

final class ContentViewModel: ObservableObject {
    var meses: [String] = []
    var lastMonth = ""
    @Published var transactions: [Transaction] = []
    
    func getMonth(transactionArray: [Transaction]) {
        for transaction in transactionArray {
            let month = String("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))".split(separator: "-")[1])
            
            if !meses.contains(month) {
                meses.append(month)
            }
        }
    }
    
    func removeTransaction(trasaction: Transaction) { }
    
    func fetch() {
        guard let url = URL(string: "http://192.168.128.31:1880/getTransactions") else {
            print("Erro ao criar URL")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("error")
                return
            }
            do {
                let parsed = try JSONDecoder().decode([Transaction].self, from: data)
                DispatchQueue.main.async {
                    self?.getMonth(transactionArray: parsed)
                    self?.transactions = parsed
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
