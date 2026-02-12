//
//  AdicinarGanho.swift
//  projetofinal
//
//  Created by Éverton Alencar de Lima on 12/11/25.
//

import SwiftUI
import SwiftData

struct AdicionarGanho: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext // ✅ Contexto
    
    @State var categoriaSelecionada: CategoryModel? // ✅ Tipo Model
    @State var titulo = ""
    @State var valor = ""
    @State var ganhoOuGasto = true
    
    @StateObject var viewModel = ViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack{
            if #available(iOS 26.0, *){
                // Novo Fundo Gradiente
                LinearGradient(
                    colors: [Color.corDeFundo, Color.corDeFundo2], // Um verde bem escuro indo pro preto
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Círculos de luz para dar o efeito "Liquid" atrás do vidro (opcional, mas fica lindo)
                Circle()
                    .fill(Color.bolaVerde.opacity(0.1))
                    .glassedEffect(in: .capsule, interactive: true)
                    .frame(width: 410, height: 410)
                    .offset(x: -100, y: -300)
                
                Circle()
                    .fill(Color.bolaAzul.opacity(0.1)) // Um toque de azul para contraste
                    .glassedEffect(in: .capsule, interactive: true)
                    .frame(width: 360, height: 360)
                    .offset(x: 100, y: 300)
                
            }else{
                // Novo Fundo Gradiente
                LinearGradient(
                    colors: [Color.corDeFundo, Color.corDeFundo2], // Um verde bem escuro indo pro preto
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Círculos de luz para dar o efeito "Liquid" atrás do vidro (opcional, mas fica lindo)
                Circle()
                    .fill(Color.bolaVerde.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: -100, y: -300)
                
                Circle()
                    .fill(Color.bolaAzul.opacity(0.3)) // Um toque de azul para contraste
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: 100, y: 200)
            }
            VStack {
                Text(ganhoOuGasto ? "Adicionar gasto" : "Adicionar ganho")
                    .font(.title)
                    .foregroundColor(.corTextosBotoes)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView{
                    if #available(iOS 26.0, *){
                        VStack (alignment: .leading) {
                            Text("Título").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto.opacity(0.1))
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                TextField("", text: $titulo)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .padding()
                                    .frame(height: 45)
                                
                            }.padding(.bottom,20)
                            
                        }.padding(.horizontal,20)
                        
                        
                        
                        VStack (alignment: .leading) {
                            Text("Valor").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto.opacity(0.1))
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                TextField("", text: $valor)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .padding()
                                    .frame(height: 45)
                                    .keyboardType(.decimalPad)
                            }.padding(.bottom,20)
                        }
                        .padding(.horizontal,20)
                        
                        
                        // CATEGORIA
                        VStack  (alignment: .leading){
                            Text("Categoria").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto.opacity(0.1))
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                Picker("Selecione a categoria", selection: $categoriaSelecionada){
                                    Text("Selecione").tag(nil as CategoryModel?)
                                    ForEach(viewModel.categories) { categoria in
                                        Text(categoria.name).tag(categoria as CategoryModel?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(height: 45)
                                .frame(maxWidth: .infinity)
                                .tint(.corTextosBotoes)
                                
                            }
                        }.padding(.horizontal,20)
                    } else{
                        VStack (alignment: .leading) {
                            Text("Título").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto)
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                TextField("", text: $titulo)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .padding()
                                    .frame(height: 45)
                                
                            }.padding(.bottom,20)
                            
                        }.padding(.horizontal,20)
                        
                        
                        
                        VStack (alignment: .leading) {
                            Text("Valor").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto)
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                TextField("", text: $valor)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .padding()
                                    .frame(height: 45)
                                    .keyboardType(.decimalPad)
                            }.padding(.bottom,20)
                        }
                        .padding(.horizontal,20)
                        
                        
                        // CATEGORIA
                        VStack  (alignment: .leading){
                            Text("Categoria").font(.title).foregroundStyle(Color.corTextosBotoes)
                            ZStack{
                                Rectangle()
                                    .foregroundColor(Color.corCaixaDeTexto)
                                    .frame(height: 45)
                                    .cornerRadius(100)
                                    .glassedEffect(in: .capsule, interactive: true)
                                Picker("Selecione a categoria", selection: $categoriaSelecionada){
                                    Text("Selecione").tag(nil as CategoryModel?)
                                    ForEach(viewModel.categories) { categoria in
                                        Text(categoria.name).tag(categoria as CategoryModel?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(height: 45)
                                .frame(maxWidth: .infinity)
                                .tint(.corTextosBotoes)
                                
                            }
                        }.padding(.horizontal,20)
                    }
                    Button {
                        guard !titulo.isEmpty, !valor.isEmpty else {
                            alertMessage = "Preencha todos os campos"; showAlert = true; return
                        }
                        // 1. Troca vírgula por ponto (padrão US para conversão)
                        let valorFormatado = valor.replacingOccurrences(of: ",", with: ".")
                        
                        guard var valorDecimal = Decimal(string: valorFormatado) else {
                            alertMessage = "Valor inválido"; showAlert = true; return
                        }
                        
                        guard let categoria = categoriaSelecionada else {
                            alertMessage = "Selecione uma categoria"; showAlert = true; return
                        }
                        
                        // 3. Ajusta o sinal
                            if ganhoOuGasto { // Se for gasto
                                valorDecimal = abs(valorDecimal) * -1
                            } else { // Se for ganho
                                valorDecimal = abs(valorDecimal)
                            }
                        
                        // ✅ Chama a função atualizada da ViewModel
                        viewModel.addTransaction(
                            descricao: titulo,
                            valor: valorDecimal,
                            categoria: categoria
                        )
                        
                        titulo = ""; valor = ""; dismiss()
                    } label: {
                        HStack{
                            Image(systemName: "plus.circle")
                            Text("Adicionar")
                                .font(.system(size: 25))
                                
                        }
                        .foregroundStyle(.black)
                        .frame(height: 66)
                        .frame(maxWidth: .infinity)
                        .background(Color.verdeClarinho)
                        .cornerRadius(20)
                    }
                    .padding(EdgeInsets(top: 30, leading: 22, bottom: 30, trailing: 22))
                    
                    Spacer()
                }
            }
        }
        .onAppear(){
            // ✅ Injeta o contexto
            viewModel.setContext(modelContext)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}



#Preview {
    // Testa tanto o modo de Ganho quanto de Gasto
    VStack {
        AdicionarGanho(ganhoOuGasto: true) // Gasto
        Divider()
        AdicionarGanho(ganhoOuGasto: false) // Ganho
    }
    .modelContainer(PreviewHelper.container)
}
