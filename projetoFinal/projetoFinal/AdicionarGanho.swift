//
//  AdicionarGanho.swift
//  projetoFinal
//
//  Created by Turma02-22 on 10/11/25.
//

import SwiftUI

struct AdicionarGanho: View {
    // Source - https://stackoverflow.com/a
    // Posted by BigMountainStudio.com, modified by community. See post 'Timeline' for change history
    // Retrieved 2025-11-10, License - CC BY-SA 4.0

    var body: some View {
        @State var nome = ""
        @State var valor = ""
        @State var categoria = ""
        
            VStack {
                
                Text("Adicionar ganho")
                        .font(.title)
                        .foregroundColor(.corTextosBotoes)
                
                Spacer()
               
                
                TextField("", text: $nome,prompt: Text("Nome:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                
                TextField("", text: $valor,prompt: Text("valor:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                    .keyboardType(.phonePad)
                    
//                TextField("", text: $categoria,prompt: Text(":").font(.system(size: 25))
//                    .foregroundColor(.corTextosBotoes))
//                    .padding()
//                    .frame(width: 350,height: 45)
//                    .background(Color.corCaixaDeTexto)
//                    .cornerRadius(10)
//                    .padding(.bottom,20)
                
                
                    
                Button("Adicionar") {
                    
                }
                .font(.system(size: 25))
                .foregroundColor(.black)
                .frame(width: 350,height: 66)
                .background(.corBotoes)
                .cornerRadius(10)
                .padding(.top,30)
                    
                    
                    
                    
                    
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Gradient(colors: [.corDeFundo]))
            
            
        
    }
}

#Preview {
    AdicionarGanho()
}
