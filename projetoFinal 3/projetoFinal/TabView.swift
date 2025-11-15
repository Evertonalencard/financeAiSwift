//
//  TabView.swift
//  projetofinal
//
//  Created by Éverton Alencar de Lima on 13/11/25.
//

import SwiftUI

struct Principal: View {
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.corCaixaDeTexto
    }
    var body: some View {
        TabView {
            TelaInicialView()
                .environmentObject(ViewModel())
                .tabItem {
                    Label("", systemImage: "house")
                }
                .padding()
            ContentView()
                .environmentObject(ContentViewModel())
                .tabItem{Label("", systemImage: "arrow.up.arrow.down")}
            IADasFinancas()
                .tabItem { Label("", systemImage: "message.fill") }
            categorias()
                .environmentObject(ViewModel())
                .tabItem{
                    Label("",systemImage: "distribute.vertical")
                }
        }
        .tint(.corTextosBotoes)
        
        
    }
}

#Preview {
    Principal()
}
