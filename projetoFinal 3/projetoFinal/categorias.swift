//
//  categorias.swift
//  projetofinal
//
//  Created by Turma02-9 on 11/11/25.
//

import SwiftUI

struct SheetView: View{
    @Environment(\.dismiss) var dismiss
    
    @State var nome = ""
    @State var viewModel = ViewModel()
    var body: some View{
        
        ZStack{
            Color.corDeFundo
                .ignoresSafeArea()
            
            VStack{
                Text("Adicionar Categoria")
                    .font(.title)
                    .foregroundColor(.corTextosBotoes)
                    .padding(.top,50)
                
           
                
                TextField("", text: $nome, prompt:
                            Text("Nome:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                .foregroundColor(.corTextosBotoes)
                .font(.system(size: 25))
                .padding()
                .frame(width: 350,height: 45)
                .background(Color.corCaixaDeTexto)
                .cornerRadius(10)
                .padding(.bottom,20)
                
                Button("Adicionar") {
                    viewModel.addCategory(nome: nome)
                }
                .font(.system(size: 25))
                .foregroundColor(.black)
                .frame(width: 350,height: 66)
                .background(.verdeClarinho)
                .cornerRadius(10)
                .padding(.top,30)
                
                Spacer()
                
            }
        }
        .onAppear(){
            viewModel.fetchCategory()
        }
    }
    
    
}

struct categorias: View {
    @State private var dissapearSheet = false
    @StateObject var viewModel = ViewModel()
    
    
    var body: some View {
        
        ZStack {
            Color.corDeFundo
                .ignoresSafeArea()
            VStack {
                Text("Categorias")
                    .font(.title)
                    .foregroundColor(.corTextosBotoes)
                ScrollView {
                    ForEach(viewModel.categories, id: \.self) {
                        category in
                        HStack{
                            Text(category.name)
                            Spacer()
                            Button() {
                                viewModel.removeCategory(categories: category)
                            } label: {
                                Image(systemName:"trash")
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .foregroundColor(.corTextosBotoes)
                        .foregroundColor(.corTextosBotoes)
                        .font(.system(size: 30))
                        .padding(.leading, 20)
                        .frame(width: 350, height: 50)
                        .background(Color.corCaixaDeTexto)
                        .cornerRadius(10)
                        
                        .padding(.bottom,16)
                        .padding(.horizontal)
                    }
                }
                if viewModel.carregando { // aplicar isloadingi
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .safeAreaPadding(.top, 20)
                }
                
                Spacer()
                Button("Criar nova categoria") {
                    dissapearSheet.toggle()
                }.sheet(isPresented: $dissapearSheet) {
                    SheetView()
                        .presentationDetents([.fraction(0.45)])
                }
                
                .font(.system(size:25))
                .foregroundColor(.black)
                .frame(width: 350,height: 66)
                .background(.verdeClarinho)
                .cornerRadius(20)
                .padding(.bottom)
                
            }
            
            
            
        }
        .onAppear {
            viewModel.fetchCategory()
        }
        
    }
}
#Preview {
    categorias()
    //    SheetView()
}

