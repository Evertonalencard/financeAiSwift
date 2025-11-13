//
//  ContentView.swift
//  finance ai
//
//  Created by Turma02 on 10/11/25.
//

import SwiftUI

struct optionsWindow: View {
    
    var viewModel = ViewModel()
    @State var transaction: Transaction
    //    @Binding var showingSheet: Bool
    
    var body: some View {
        ZStack {
            Color.white
            VStack {
                
                Button () {
                    //                    showingSheet == true
                    print("OI")
                } label: {
                    HStack {
                        Text("Editar")
                        Image(systemName: "pencil.line")
                    }
                    .foregroundColor(.black)
                }
                
                Button() {
                    viewModel.removeTransaction(trasaction: transaction)
                } label: {
                    HStack {
                        Text("Deletar")
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
                
            }
        }
    }
    
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    @State var meses : [String] = []
    //    @State var showingSheet: Bool = false
    
    var monthsArray: [String: String] = [
        "12": "Dezembro",
        "11": "Novembro",
        "10": "Outubro",
        "09": "Setembro",
        "08": "Agosto",
        "07": "Julho",
        "06": "Junho",
        "05": "Maio",
        "04": "Abril",
        "03": "Março",
        "02": "Fevereiro",
        "01": "Janeiro",
    ]
    
    @State var lastMonth = ""
    
    func isMonthDifferent(transaction: Transaction) -> Bool {
        let month = String("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))".split(separator: "-")[1])
        
        return(month != lastMonth)
    }
    
    func getMonth(transaction: Transaction) -> String {
        let month = String("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))".split(separator: "-")[1])
        
        if (isMonthDifferent(transaction:transaction)) {
            lastMonth = month
        }
        
        return(month)
    }
    
    func getMonth(transactionArray: [Transaction]) {
        for transaction in transactionArray {
            let month = String("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))".split(separator: "-")[1])
            
            if !meses.contains(month) {
                meses.append(month)
            }
        }
    }
    
    var body: some View {
        
        let sortedTransactions = viewModel.transactions.sorted {
            $0.data < $1.data
        }
        
        ZStack {
            Color.corDeFundo
                .ignoresSafeArea()
            VStack {
                Text("Histórico de Finanças")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundStyle(.corTextosBotoes)
                
                ScrollView {
                    VStack {
                        ForEach(monthsArray.sorted(by: { $0.key < $1.key }), id: \.key){ key, value in
                            
                            if(meses.contains(key)){
                                HStack{
                                    Text(value)
                                        .safeAreaPadding(.top, 10)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.corTextosBotoes)
                                        .padding(.leading, 20)
                                    Spacer()
                                }
                                
                                ForEach(sortedTransactions, id: \.self) {
                                    
                                    
                                    transaction in
                                    
                                    if(getMonth(transaction: transaction) == key){
                                        
                                        VStack {
                                            
                                            ZStack {
                                                
                                                if (transaction.valor < 0) {
                                                    Color.corVermelhoApagar
                                                } else {
                                                    Color.corCaixaDeTexto
                                                }
                                                
                                                HStack {
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(transaction.descricao)
                                                            .font(.system(size: 22))
                                                            .foregroundColor(Color.corTextosBotoes)
                                                        Text(transaction.category.name)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(Color.corTextosBotoes)
                                                    }
                                                    Spacer()
                                                    VStack {
                                                        Text(String(format: "%.2f", transaction.valor))
                                                            .font(.system(size: 18))
                                                            .foregroundColor(Color.corTextosBotoes)
                                                        Spacer()
                                                    }
                                                    .safeAreaPadding(.vertical, 15)
                                                    
                                                    
                                                    VStack {
                                                        Menu {
                                                            optionsWindow(transaction:transaction)
                                                        } label: {
                                                            HStack {
                                                                Image(systemName: "ellipsis")
                                                                    .rotationEffect(.init(degrees: 90))
                                                                    .foregroundColor(.corTextosBotoes)
                                                                    .frame(height: 1)
                                                            }
                                                            .padding(2)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                    }
                                                    .safeAreaPadding(.top, 16)
                                                    
                                                }
                                                .safeAreaPadding(.horizontal, 8)
                                            }
                                            .cornerRadius(5)
                                            .padding(2)
                                            .safeAreaPadding(.horizontal, 20)
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                    .padding(10)
                }
                
            }
        }
        //        .sheet(isPresented: $showingSheet, content: {
        //            editTransaction()
        //        })
        .onAppear() {
            viewModel.fetch()
            
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false){ _ in
                getMonth(transactionArray: viewModel.transactions)
            }
        }
    }
    
}

#Preview {
    ContentView()
}


//Text("\(Date(timeIntervalSince1970: TimeInterval(transaction.data)))")
