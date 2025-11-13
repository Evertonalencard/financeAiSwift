//
//  ContentView.swift
//  FinanceAI
//
//  Created by Turma02-6 on 11/11/25.
//

import SwiftUI
import Charts

struct CustomDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        return context.maxDetentValue - 1
    }
}

struct ContentView: View {
    @State private var showingSheetGasto = false
    @State private var showingSheetGanho = false

    @StateObject var dados = ViewModel()
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.brown, Color.brown.opacity(0.1)])
    }
    @State var ganhos: Double = 0
    @State var gastos: Double = 0
    @State var clicouGanho: Bool = true
    @State var clicouGasto: Bool = false
    // let dadosCompletos = dados.transactions
    
    
    var body: some View {
        ZStack {
            Color.corDeFundo
            
            VStack {
                Text("Finance AI")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundStyle(Color.corTextosBotoes)
                VStack (alignment: .leading) {
                    Text("Saldo")
                        .foregroundStyle(Color.corTextosBotoes)
                        .font(.title2)
                    ZStack (alignment: .leading) {
                        Rectangle()
                            .frame(width: 360, height: 50)
                            .foregroundColor(.corBotoes)
                            .cornerRadius(10)
                        Text("R$ \(String(format: "%.2f", dados.ganhos + dados.gastos))")
                            .foregroundStyle(Color.corTextosBotoes)
                            .padding(.horizontal)
                    }
                }
                HStack {
                    VStack (alignment: .leading)  {
                        Text("Ganhos")
                            .foregroundStyle(Color.corTextosBotoes)
                            .font(.title2)
                        ZStack (alignment: .leading) {
                            Rectangle()
                                .frame(width: 150, height: 50)
                                .foregroundColor(.corBotoes)
                                .cornerRadius(10)
                            Text("R$ \(String(format: "%.2f", dados.ganhos))")
                                .foregroundStyle(Color.corTextosBotoes)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    Spacer()
                    VStack (alignment: .leading) {
                        Text("Gastos")
                            .foregroundStyle(Color.corTextosBotoes)
                            .font(.title2)
                        ZStack (alignment: .leading) {
                            Rectangle()
                                .frame(width: 150, height: 50)
                                .foregroundColor(.corBotoes)
                                .cornerRadius(10)
                            Text("R$ \(String(format: "%.2f", dados.gastos))")
                                .foregroundStyle(Color.corTextosBotoes)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    
                }
                .padding(.horizontal)
                // BUSSOLA FINANCEIRA
                VStack  {
                    Text("Bússola Financeira")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .bold()
                        .foregroundStyle(Color.corTextosBotoes)
                    ZStack {
                        Chart(Array(dados.gastosGanhos.enumerated()), id: \.offset) { index, dado in
                            BarMark(
                                x: .value("", index),
                                y: .value("\(dado)", abs(dado))
                            )
                            .foregroundStyle(index == 1 ? Color.red : Color.corBotoes)
                            
                        }
                        .chartXScale(domain: -1...2)
                        .frame(width: 300, height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    
                }
                .padding()
                HStack {
                    Spacer()
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 130, height: 130)
                        .foregroundStyle(Color.corTextosBotoes)
                        .onTapGesture {
                            showingSheetGanho.toggle()
                            clicouGanho = false
                        }.sheet(isPresented: $showingSheetGanho) {
                            AdicionarGanho(ganhoOuGasto: $clicouGanho)
                                .presentationDetents([
                                    .custom(CustomDetent.self)
                                ])
                                .presentationDetents([.fraction(0.5)])
                        }
                    
                    Spacer()
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 130, height: 130)
                        .foregroundStyle(Color.corBotoes)
                        .onTapGesture {
                            showingSheetGasto.toggle()
                            clicouGasto = true
                        }.sheet(isPresented: $showingSheetGasto) {
                            AdicionarGanho(ganhoOuGasto: $clicouGasto)
                                .presentationDetents([
                                    .custom(CustomDetent.self)
                                ])
                                .presentationDetents([.fraction(0.5)])
                        }
                    Spacer()
                }
            }
            .onAppear() {
                dados.fetch()
                
            }
        }.ignoresSafeArea()
        
        
    }
    
    
}



#Preview {
    ContentView()
}
