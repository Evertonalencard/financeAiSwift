//
//  AdicinarGanho.swift
//  projetofinal
//
//  Created by Éverton Alencar de Lima on 12/11/25.
//

import SwiftUI

struct AdicionarGanho: View {
    @State var categoriaSelecionada: Category?
    @State var titulo = ""
    @State var valor = ""
    @State var valorAux:Int = 0
    @State var ganhoOuGasto = true
    @StateObject var viewModel = ViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack{
            Color.corDeFundo
                .ignoresSafeArea()
            VStack {
                
                if ganhoOuGasto  == false{
                    Text("Adicionar ganho")
                        .font(.title)
                        .foregroundColor(.corTextosBotoes)
                }else{
                    Text("Adicionar gasto")
                        .font(.title)
                        .foregroundColor(.corTextosBotoes)
                }
                
                TextField("", text: $titulo,prompt: Text("Titulo:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                
                TextField("", text: $valor,prompt: Text("Valor:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                    .keyboardType(.decimalPad)
                
                Picker("Selecione a categoria", selection: $categoriaSelecionada){
                    Text("Selecione")
                        .tag(nil as Category?)
                    ForEach(viewModel.categories, id: \.self) { categoriaa in
                        
                        Text(categoriaa.name)
                            .tag(categoriaa as Category?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 350,height: 45)
                .background(Color.corCaixaDeTexto)
                .cornerRadius(10)
                .tint(.corTextosBotoes)
                
                Button("Adicionar") {
                    guard !titulo.isEmpty, !valor.isEmpty else {
                        alertMessage = "Preencha todos os campos"
                        showAlert = true
                        return
                    }
                    
                    guard var valorDouble = Double(valor.replacingOccurrences(of: ",", with: ".")) else {
                        alertMessage = "Valor inválido"
                        showAlert = true
                        return
                    }
                    
                    
                    
                    
                    guard let categoria = categoriaSelecionada else {
                        alertMessage = "Selecione uma categoria"
                        showAlert = true
                        return
                    }
                    if ganhoOuGasto {
                        valorDouble = Double(valor)! * -1
                    }
                    
                    viewModel.addTransaction(
                        descricao: titulo,
                        valor: valorDouble,
                        categoria: categoria
                    )
                    
                    titulo = ""
                    valor = ""
                }
                
                .font(.system(size: 25))
                .foregroundColor(.black)
                .frame(width: 350,height: 66)
                .background(.verdeClarinho)
                .cornerRadius(20)
                .padding(.top,30)
                
                
                
                
                Spacer()
            }
        }
        .onAppear(){
            viewModel.fetch()
            viewModel.fetchCategory()
        }
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        
        
        
    }
}


#Preview {
    AdicionarGanho()
}
